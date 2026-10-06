"""RiverLabs API entry point."""

from datetime import datetime, timezone
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse, Response

WEB_ROOT = Path(__file__).resolve().parent / "dist"

app = FastAPI(
    title="RiverLabs API",
    description="The API behind your RiverLabs workspace.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health", tags=["system"])
def health_check() -> dict[str, str]:
    """Return API status and server time for health checks."""
    return {"status": "ok", "service": "riverlabs-api", "timestamp": datetime.now(timezone.utc).isoformat()}


@app.get("/api/overview", tags=["workspace"])
def get_overview() -> dict[str, object]:
    """Provide starter data for the workspace overview screen."""
    return {
        "workspace": "RiverLabs",
        "period": "Last 30 days",
        "metrics": [
            {"label": "Total revenue", "value": "$48,294", "change": "+12.8%", "direction": "up"},
            {"label": "Active customers", "value": "2,847", "change": "+8.2%", "direction": "up"},
            {"label": "Conversion rate", "value": "4.38%", "change": "+0.6%", "direction": "up"},
            {"label": "Avg. order value", "value": "$169.80", "change": "−2.4%", "direction": "down"},
        ],
        "activity": [
            {"name": "Olivia Rhye", "initials": "OR", "action": "placed an order", "detail": "Order #RL-2841", "amount": "$248.00", "time": "2 min ago", "tone": "violet"},
            {"name": "Phoenix Baker", "initials": "PB", "action": "subscribed to Pro", "detail": "Monthly plan", "amount": "$29.00", "time": "18 min ago", "tone": "blue"},
            {"name": "Lana Steiner", "initials": "LS", "action": "placed an order", "detail": "Order #RL-2840", "amount": "$184.50", "time": "42 min ago", "tone": "peach"},
            {"name": "Demi Wilkinson", "initials": "DW", "action": "joined your workspace", "detail": "Team invitation", "amount": "—", "time": "1 hr ago", "tone": "green"},
        ],
    }


@app.get("/api/{path:path}", include_in_schema=False)
def unknown_api_route(path: str) -> JSONResponse:
    """Keep unknown API URLs from falling through to the Vue application."""
    return JSONResponse(status_code=404, content={"detail": "Not found"})


@app.get("/{path:path}", include_in_schema=False)
def serve_frontend(path: str = "") -> Response:
    """Serve the built Vue app and support its client-side routes."""
    if not WEB_ROOT.is_dir():
        return JSONResponse(status_code=503, content={"detail": "Frontend build is not available"})

    root = WEB_ROOT.resolve()
    requested_file = (root / path).resolve()
    if root not in requested_file.parents and requested_file != root:
        requested_file = root / "index.html"
    if not requested_file.is_file():
        requested_file = root / "index.html"
    return FileResponse(requested_file)
