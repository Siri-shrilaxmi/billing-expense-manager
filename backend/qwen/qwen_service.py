import io
import json
import re
import time

import torch
from PIL import Image
from transformers import (
    AutoProcessor,
    Qwen2VLForConditionalGeneration,
)
from qwen_vl_utils import process_vision_info


class QwenService:

    MODEL_NAME = "Qwen/Qwen2-VL-2B-Instruct"

    def __init__(self):

        print()
        print("========================================")
        print("Loading Qwen2-VL model...")
        print("========================================")

        # ----------------------------------------------------
        # DEVICE
        # ----------------------------------------------------

        self.device = torch.device(
            "cuda"
            if torch.cuda.is_available()
            else "cpu"
        )

        print(f"Device: {self.device}")

        # ----------------------------------------------------
        # IMAGE RESOLUTION
        # ----------------------------------------------------

        min_pixels = 256 * 28 * 28
        max_pixels = 2048 * 28 * 28

        self.processor = AutoProcessor.from_pretrained(
            self.MODEL_NAME,
            min_pixels=min_pixels,
            max_pixels=max_pixels,
            use_fast=True,
        )

        # ----------------------------------------------------
        # PRECISION
        # ----------------------------------------------------

        if (
            torch.cuda.is_available()
            and torch.cuda.is_bf16_supported()
        ):

            dtype = torch.bfloat16

            print("Using BF16")

        elif torch.cuda.is_available():

            dtype = torch.float16

            print("Using FP16")

        else:

            dtype = torch.float32

            print("Using CPU FP32")

        # ----------------------------------------------------
        # ATTENTION
        # ----------------------------------------------------

        attn_impl = "sdpa"

        try:

            import flash_attn

            attn_impl = "flash_attention_2"

            print("Flash Attention 2 available")

        except ImportError:

            print("Flash Attention 2 not available")
            print("Using SDPA")

        # ----------------------------------------------------
        # LOAD MODEL
        # ----------------------------------------------------

        print("Loading model weights...")

        self.model = (
            Qwen2VLForConditionalGeneration.from_pretrained(
                self.MODEL_NAME,
                torch_dtype=dtype,
                attn_implementation=attn_impl,
                device_map=(
                    "auto"
                    if torch.cuda.is_available()
                    else "cpu"
                ),
            )
        )

        self.model.eval()

        print()
        print("========================================")
        print("Qwen2-VL model loaded successfully.")
        print(f"Device: {self.model.device}")
        print("========================================")
        print()

    # ========================================================
    # MAIN APPLICATION ENTRY POINT
    # ========================================================

    def predict_bytes(self, image_bytes):

        total_start = time.perf_counter()

        # ----------------------------------------------------
        # VALIDATE IMAGE BYTES
        # ----------------------------------------------------

        if image_bytes is None or len(image_bytes) == 0:

            raise ValueError(
                "Image bytes are empty."
            )

        # ----------------------------------------------------
        # DECODE IMAGE
        # ----------------------------------------------------

        image = Image.open(
            io.BytesIO(image_bytes)
        ).convert("RGB")

        print()
        print("========================================")
        print("Qwen received image")
        print(f"Image size: {image.size}")
        print("Running inference...")
        print("========================================")

        # ----------------------------------------------------
        # PROMPT
        #
        # This is intentionally kept the same as the older
        # version that produced better extraction accuracy.
        # ----------------------------------------------------

        prompt = """You are a receipt OCR assistant. Extract the following details from the receipt image and output strict JSON only:
{
  "merchant": "Name of the store or restaurant",
  "date_time": "Date and time of transaction",
  "total_cost": "Final total amount paid"
}
If a value is not found, leave the string empty."""

        # ----------------------------------------------------
        # QWEN MESSAGE
        # ----------------------------------------------------

        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "image": image,
                    },
                    {
                        "type": "text",
                        "text": prompt,
                    },
                ],
            }
        ]

        # ----------------------------------------------------
        # PREPARE INPUT
        # ----------------------------------------------------

        preparation_start = time.perf_counter()

        text = self.processor.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
        )

        image_inputs, video_inputs = process_vision_info(
            messages
        )

        inputs = self.processor(
            text=[text],
            images=image_inputs,
            videos=video_inputs,
            padding=True,
            return_tensors="pt",
        )

        inputs = inputs.to(
            self.model.device
        )

        preparation_time = (
            time.perf_counter()
            - preparation_start
        )

        # ----------------------------------------------------
        # GENERATION
        # ----------------------------------------------------

        generation_start = time.perf_counter()

        with torch.no_grad():

            generated = self.model.generate(
                **inputs,
                max_new_tokens=256,
                do_sample=False,
                return_dict_in_generate=True,
                output_scores=True,
            )

        generation_time = (
            time.perf_counter()
            - generation_start
        )

        # ----------------------------------------------------
        # REMOVE INPUT TOKENS
        # ----------------------------------------------------

        generated_ids = generated.sequences

        generated_ids_trimmed = [
            output_ids[len(input_ids):]
            for input_ids, output_ids in zip(
                inputs.input_ids,
                generated_ids,
            )
        ]

        # ----------------------------------------------------
        # DECODE QWEN OUTPUT
        # ----------------------------------------------------

        output_text = self.processor.batch_decode(
            generated_ids_trimmed,
            skip_special_tokens=True,
        )[0].strip()

        print()
        print("========== QWEN RAW OUTPUT ==========")
        print(output_text)
        print("======================================")

        # ----------------------------------------------------
        # PARSE JSON
        # ----------------------------------------------------

        result = self._parse_json(
            output_text
        )

        # ----------------------------------------------------
        # GENERATION CONFIDENCE
        # ----------------------------------------------------

        result["generation_confidence"] = (
            self._calculate_generation_confidence(
                generated.scores,
                generated_ids_trimmed[0],
            )
        )

        # ----------------------------------------------------
        # TIMING
        # ----------------------------------------------------

        result["timing"] = {

            "preparation_seconds": round(
                preparation_time,
                3,
            ),

            "generation_seconds": round(
                generation_time,
                3,
            ),

            "total_seconds": round(
                time.perf_counter()
                - total_start,
                3,
            ),
        }

        # ----------------------------------------------------
        # FINAL RESULT
        # ----------------------------------------------------

        print()
        print("========== QWEN PARSED OUTPUT ==========")

        print(
            json.dumps(
                result,
                indent=2,
                ensure_ascii=False,
            )
        )

        print("=========================================")
        print()

        return result

    # ========================================================
    # JSON PARSER
    # ========================================================

    def _parse_json(
        self,
        output_text,
    ):

        cleaned = output_text.strip()

        # ----------------------------------------------------
        # REMOVE ```json
        # ----------------------------------------------------

        cleaned = re.sub(
            r"^```json\s*",
            "",
            cleaned,
            flags=re.IGNORECASE,
        )

        # ----------------------------------------------------
        # REMOVE ```
        # ----------------------------------------------------

        cleaned = re.sub(
            r"^```\s*",
            "",
            cleaned,
        )

        cleaned = re.sub(
            r"\s*```$",
            "",
            cleaned,
        )

        cleaned = cleaned.strip()

        # ----------------------------------------------------
        # DIRECT JSON PARSE
        # ----------------------------------------------------

        try:

            result = json.loads(
                cleaned
            )

        except json.JSONDecodeError:

            # ------------------------------------------------
            # TRY TO FIND JSON OBJECT INSIDE OUTPUT
            # ------------------------------------------------

            match = re.search(
                r"\{.*\}",
                cleaned,
                flags=re.DOTALL,
            )

            if match:

                try:

                    result = json.loads(
                        match.group(0)
                    )

                except json.JSONDecodeError:

                    return {
                        "merchant": "",
                        "date_time": "",
                        "total_cost": "",
                        "raw_output": output_text,
                        "parse_error": True,
                    }

            else:

                return {
                    "merchant": "",
                    "date_time": "",
                    "total_cost": "",
                    "raw_output": output_text,
                    "parse_error": True,
                }

        # ----------------------------------------------------
        # RETURN ONLY EXPECTED FIELDS
        # ----------------------------------------------------

        return {

            "merchant": str(
                result.get(
                    "merchant",
                    "",
                )
            ),

            "date_time": str(
                result.get(
                    "date_time",
                    "",
                )
            ),

            "total_cost": str(
                result.get(
                    "total_cost",
                    "",
                )
            ),
        }

    # ========================================================
    # GENERATION CONFIDENCE
    # ========================================================

    def _calculate_generation_confidence(
        self,
        scores,
        generated_ids,
    ):

        if not scores:
            return None

        probabilities = []

        for step, score in enumerate(scores):

            if step >= len(generated_ids):
                break

            token_id = generated_ids[step]

            logits = score[0]

            probabilities_tensor = (
                torch.softmax(
                    logits,
                    dim=-1,
                )
            )

            token_probability = (
                probabilities_tensor[
                    token_id
                ].item()
            )

            probabilities.append(
                token_probability
            )

        if not probabilities:
            return None

        # ----------------------------------------------------
        # GEOMETRIC MEAN OF TOKEN PROBABILITIES
        # ----------------------------------------------------

        log_sum = sum(
            torch.log(
                torch.tensor(p)
            ).item()

            for p in probabilities

            if p > 0
        )

        confidence = torch.exp(
            torch.tensor(
                log_sum
                / len(probabilities)
            )
        ).item()

        return round(
            confidence,
            4,
        )