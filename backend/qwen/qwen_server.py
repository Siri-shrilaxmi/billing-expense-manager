import io

from fastapi import FastAPI, HTTPException, Request
from PIL import Image

from qwen_service import QwenService


app = FastAPI(
    title="Bill Management Qwen Service"
)


# ============================================================
# LOAD QWEN ONCE
# ============================================================

print()
print("========================================")
print("Starting Qwen backend...")
print("========================================")

qwen_service = QwenService()

print()
print("========================================")
print("Qwen backend is ready.")
print("Waiting for images...")
print("========================================")


# ============================================================
# HEALTH
# ============================================================

@app.get("/health")
def health():

    return {
        "status": "ok",
        "model": QwenService.MODEL_NAME,
        "loaded": True,
    }


# ============================================================
# ANALYZE IMAGE
# ============================================================

@app.post("/analyze")
async def analyze(request: Request):

    image_bytes = await request.body()

    if not image_bytes:

        raise HTTPException(
            status_code=400,
            detail="Empty image",
        )

    # --------------------------------------------------------
    # Validate image
    # --------------------------------------------------------

    try:

        image = Image.open(
            io.BytesIO(image_bytes)
        )

        image.verify()

    except Exception:

        raise HTTPException(
            status_code=400,
            detail="Invalid image",
        )

    # --------------------------------------------------------
    # QWEN
    # --------------------------------------------------------

    try:

        result = qwen_service.predict_bytes(
            image_bytes
        )

        return result

    except Exception as e:

        print()
        print("========== QWEN REQUEST FAILED ==========")
        print(str(e))
        print("==========================================")
        print()

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )