# Smart Caption Generator

Fast, lightweight Instagram caption generator. Flutter frontend + FastAPI backend powered by Google Gemini 1.5 Flash.

## Backend (FastAPI + Gemini)

Location: `backend/`

### Endpoints
- `POST /generate-captions` – multipart upload: field `file` (image). Returns:
  ```json
  { "captions": ["...", "...", "..."] }
  ```
- `GET /health` – health check

### Local Setup
1. Create virtual env and install deps:
   ```bash
   cd backend
   python -m venv .venv && . .venv/Scripts/activate  # Windows PowerShell: . .venv/Scripts/Activate.ps1
   pip install -r requirements.txt
   ```
2. Set env:
   ```bash
   setx GEMINI_API_KEY "YOUR_API_KEY"
   # or create backend/.env with GEMINI_API_KEY=...
   ```
3. Run server:
   ```bash
   uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Deploy
- Vercel: already configured
  - `api/index.py` exposes `app`
  - `vercel.json` routes all to Python function
  - Add `GEMINI_API_KEY` in Vercel Project Settings → Environment Variables
- Render: create a new Web Service
  - Build: `pip install -r backend/requirements.txt`
  - Start: `uvicorn backend.main:app --host 0.0.0.0 --port $PORT`
  - Env: add `GEMINI_API_KEY`

## Frontend (Flutter)

### Features
- Pick from gallery or camera
- Uploads image to backend `/generate-captions`
- Displays 3 selectable captions; tap to copy and save

### Config
Update API base URL when building release:
```dart
// In lib/services/caption_api.dart you can set API_BASE_URL at build time
// flutter run --dart-define=API_BASE_URL=https://your-deployment.vercel.app
```

### Run
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

## Notes
- Env var: `GEMINI_API_KEY` (kept outside VCS). See `backend/main.py`.
- The backend sanitizes Gemini output and enforces exactly 3 short captions.
