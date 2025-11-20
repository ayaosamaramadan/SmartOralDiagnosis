import os
import io
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import numpy as np
import tensorflow as tf

app = FastAPI(title="AI Inference Service")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_PATH = os.environ.get("MODEL_PATH", os.path.join(os.path.dirname(__file__), "model.h5"))
IMAGE_SIZE = (224, 224)

model = None


def load_model():
    global model
    if model is None:
        if not os.path.exists(MODEL_PATH):
            raise RuntimeError(f"Model file not found at {MODEL_PATH}")
        model = tf.keras.models.load_model(MODEL_PATH)
    return model


@app.on_event("startup")
async def startup_event():
    try:
        load_model()
        print("Model loaded")
    except Exception as e:
        print(f"Failed loading model: {e}")


@app.post("/predict")
async def predict(image: UploadFile = File(...)):
    try:
        contents = await image.read()
        img = Image.open(io.BytesIO(contents)).convert("RGB")
        img = img.resize(IMAGE_SIZE)
        arr = np.array(img).astype(np.float32) / 255.0
        arr = np.expand_dims(arr, axis=0)  # batch dim

        m = load_model()
        preds = m.predict(arr)

        # If model outputs logits or probabilities, try to make them JSON serializable
        preds_list = preds.tolist()
        return {"predictions": preds_list}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
