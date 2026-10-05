"""RiverLabs API entry point."""

from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

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
