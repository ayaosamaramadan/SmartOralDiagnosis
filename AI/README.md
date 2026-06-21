## Download AI Models
The trained AI models are too large for GitHub.  
You can download them from the link below:

👉 [Click here to download the model](https://drive.google.com/drive/folders/1FsvGKNSxdHr-JESXSUGp_zihy6A7Klf0?usp=drive_link)

How to run the inference service and connect it to the backend
------------------------------------------------------------

1) Place the model file

- Download the model from the link above. Put the model file in `AI/inference/` and name it `model.h5`, or set `MODEL_PATH` to the downloaded path.

2) Quick automatic download (Windows PowerShell)

Run the helper script from the `AI/inference` folder to download the model using `gdown`:

```powershell
Set-Location 'C:\path\to\SmartOralDiagnosis\AI\inference'
.\download_model.ps1
```

3) Start the Python inference service (FastAPI)

```powershell
# inside AI/inference
.\.venv\Scripts\Activate.ps1    # activate the venv created by the download script
pip install -r requirements.txt
$env:MODEL_PATH = "$PWD\model.h5"   # optional if model.h5 is in the same folder
uvicorn app:app --host 0.0.0.0 --port 8001
```

The service exposes `POST /predict` and accepts a single form-file field named `image` (returns JSON: `{ "predictions": [...] }`).

4) Configure the backend to talk to the inference service

- Set `BackEnd/appsettings.json` `AIService:BaseUrl` to the running service (default is `http://localhost:8001/`).
- Or set environment variable `AI_SERVICE_BASEURL`:

```powershell
#$env:AI_SERVICE_BASEURL = "http://localhost:8001/"
```

5) Call the backend endpoint (passes image to AI service)

- Backend endpoint: `POST /api/ai/predict` (requires JWT because backend uses global auth policy).

Example `curl` (via backend, requires a valid JWT):

```bash
curl -X POST "NEXT_BACKEND_SERVER/api/ai/predict" \
	-H "Authorization: Bearer <YOUR_JWT>" \
	-F "image=@/path/to/photo.jpg"
```

PowerShell example using `Invoke-RestMethod`:

```powershell
#$token = '<YOUR_JWT>'
#Invoke-RestMethod -Uri 'NEXT_BACKEND_SERVER/api/ai/predict' -Method Post -Headers @{ Authorization = "Bearer $token" } -Form @{ image = Get-Item 'C:\path\to\photo.jpg' }
```

6) Direct test to Python service (no JWT required)

```bash
curl -X POST "http://localhost:8001/predict" -F "image=@/path/to/photo.jpg"
```

Notes
- Keep the AI service separated if you expect heavy models, GPU usage, or different dependency stacks. The backend only forwards the image and returns the AI service’s JSON response.
- If you want the backend to accept anonymous AI requests (for quick testing), I can add `[AllowAnonymous]` to `AIController.Predict` — let me know.
