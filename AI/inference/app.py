import os
import io
# Disable oneDNN optimizations to avoid the informational oneDNN message and
# reduce potential numerical differences. Set this before importing TensorFlow.
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")
# Reduce TensorFlow C++ logging (0=ALL,1=INFO,2=WARNING,3=ERROR)
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")

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

DEFAULT_MODEL_NAME = "model.h5"
MODEL_PATH = os.environ.get("MODEL_PATH")
if not MODEL_PATH:
    # prefer explicit default name, otherwise pick the first .h5 in the folder
    candidate = os.path.join(os.path.dirname(__file__), DEFAULT_MODEL_NAME)
    if os.path.exists(candidate):
        MODEL_PATH = candidate
    else:
        # search for any .h5 file in the inference folder
        files = [f for f in os.listdir(os.path.dirname(__file__)) if f.lower().endswith('.h5')]
        MODEL_PATH = os.path.join(os.path.dirname(__file__), files[0]) if files else None
IMAGE_SIZE = (224, 224)

model = None


@app.get("/health")
async def health():
    return {"status": "ok"}

# Define class labels in the same order the model was trained to output.
# Update these names if your trained model uses different class ordering.
# Short codes correspond to dataset folders: CaS, CoS, Gum, MC, OC, OLP, OT
CLASS_LABELS = [
    "CaS",
    "CoS",
    "Gum",
    "MC",
    "OC",
    "OLP",
    "OT",
]

# Optional human-friendly names (adjust if you have a canonical list)
HUMAN_LABELS = {
    "CaS": "CaS",
    "CoS": "Commissural Stomatitis",
    "Gum": "Gingival Condition",
    "MC": "Mucocele",
    "OC": "Oral Cancer",
    "OLP": "Oral Lichen Planus",
    "OT": "Other",
}

def load_model():
    global model
    if model is None:
        if not MODEL_PATH or not os.path.exists(MODEL_PATH):
            raise RuntimeError(f"Model file not found. Checked MODEL_PATH={MODEL_PATH}")
        # Load for inference only (avoid compiling metrics which aren't needed)
        try:
            model = tf.keras.models.load_model(MODEL_PATH, compile=False)
        except Exception:
            # Fallback to default load to propagate any original exceptions
            model = tf.keras.models.load_model(MODEL_PATH)
    return model


@app.on_event("startup")
async def startup_event():
    try:
        # Diagnostic info: print chosen model path and any .h5 files in folder
        print(f"MODEL_PATH={MODEL_PATH}")
        try:
            files = [f for f in os.listdir(os.path.dirname(__file__)) if f.lower().endswith('.h5')]
            print("Found .h5 files:", files)
        except Exception as _:
            pass

        load_model()
        print("Model loaded")
    except Exception as e:
        import traceback
        print(f"Failed loading model: {e}")
        traceback.print_exc()


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

        # Normalize preds into a 1-D probability array safely
        if isinstance(preds, np.ndarray):
            if preds.ndim == 2 and preds.shape[0] == 1:
                probs = preds[0]
            elif preds.ndim == 1:
                probs = preds
            else:
                # fallback: try first row or flatten
                probs = np.ravel(preds)[0:len(CLASS_LABELS)] if preds.size >= len(CLASS_LABELS) else np.ravel(preds)
        else:
            # not an ndarray (unexpected) — coerce to numpy
            probs = np.array(preds, dtype=np.float32)

        # Ensure there is at least one probability
        if probs.size == 0:
            raise RuntimeError("Model returned empty predictions")

        # Select top index and probability and guard against NaN/inf
        top_idx = int(np.nanargmax(probs))
        raw_conf = float(probs[top_idx]) if np.isfinite(probs[top_idx]) else 0.0

        # Compute percentage, clamp to [0, 100], and return as integer percent
        confidence_pct = min(max(raw_conf * 100.0, 0.0), 100.0)
        confidence_pct = int(round(confidence_pct))

        label_code = CLASS_LABELS[top_idx] if top_idx < len(CLASS_LABELS) else f"class_{top_idx}"
        label_name = HUMAN_LABELS.get(label_code, label_code)

        return {
            "diagnosis": label_name,
            "confidence": confidence_pct
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
