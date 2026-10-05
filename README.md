# RiverLabs

A RiverLabs marketing site with a FastAPI backend and a Vue 3 + Vite frontend.

## Run locally

Start the API in one terminal:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Start the frontend in another terminal:

```bash
npm install
npm run dev
```

Open the URL printed by Vite (usually `http://localhost:5173`). The frontend proxies `/api` requests to the backend at `http://127.0.0.1:8000`. FastAPI's interactive API docs are available at `http://127.0.0.1:8000/docs`.

## Project layout

```text
.
├── main.py             # FastAPI application and starter endpoints
├── requirements.txt    # Python dependencies
├── package.json        # Frontend scripts and dependencies
├── vite.config.js      # Vue plugin and local API proxy
├── index.html
└── src/
    ├── App.vue         # Dashboard shell and views
    ├── main.js         # Vue application entry point
    └── style.css       # Responsive design system
```

The API exposes `GET /api/health` and `GET /api/overview`. The RiverLabs homepage, hero preview, and expertise section are built in Vue.
