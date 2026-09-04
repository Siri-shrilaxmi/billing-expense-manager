import io

from fastapi import FastAPI, HTTPException, Request
from PIL import Image

from qwen_service import QwenService


app = FastAPI(
    title="Bill Management Qwen Service"
)


# ============================================================
# QWEN INITIALIZATION
# ============================================================

print()
print("========================================")
print("Starting Qwen backend...")
print("========================================")


# IMPORTANT:
#
# QwenService is created ONCE.
#
# Therefore the model is loaded once when this Python
# process starts.
#
# Requests do NOT create another QwenService.
#
qwen_service = QwenService()


print("========================================")
print("Qwen backend is ready.")
print("Waiting for images...")
print("========================================")


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health():

    return {
        "status": "ok",
        "model": QwenService.MODEL_NAME,
        "loaded": True,
    }


# ============================================================
# IMAGE ANALYSIS
# ============================================================

@app.post("/analyze")
async def analyze(request: Request):

    # Receive the raw image bytes.
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
    # Send directly to the already-loaded Qwen service
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
        print("=========================================")

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )