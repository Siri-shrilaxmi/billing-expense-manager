from paddleocr import PaddleOCR
import sys
import json

if len(sys.argv) != 2:
    print("Usage: python ocr.py <image>")
    sys.exit(1)

image_path = sys.argv[1]

ocr = PaddleOCR(
    use_angle_cls=True,
    lang="en"
)

result = ocr.ocr(image_path, cls=True)

ocr_output = []

for line in result[0]:

    box = line[0]
    text = line[1][0]
    confidence = float(line[1][1])

    xs = [p[0] for p in box]
    ys = [p[1] for p in box]

    left = min(xs)
    right = max(xs)
    top = min(ys)
    bottom = max(ys)

    words = text.split()

    if len(words) == 0:
        continue

    total_width = right - left
    word_width = total_width / len(words)

    for i, word in enumerate(words):

        word_left = int(left + i * word_width)
        word_right = int(left + (i + 1) * word_width)

        ocr_output.append({
            "text": word,
            "confidence": confidence,
            "left": word_left,
            "top": int(top),
            "right": word_right,
            "bottom": int(bottom)
        })

print(json.dumps(ocr_output))