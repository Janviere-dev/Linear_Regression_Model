"""FastAPI app for the delivery-time prediction service."""

from fastapi import FastAPI

app = FastAPI(
    title="Delivery Time Prediction API",
    description="Predicts food delivery time (minutes) from courier, order, and location data.",
    version="1.0.0",
)


@app.get("/")
def health_check():
    return {"status": "ok", "message": "Delivery Time Prediction API is running"}
