"""FastAPI app for the delivery-time prediction service."""

from fastapi import FastAPI

from prediction import load_bundle, predict_delivery_time
from schemas import DeliveryPredictionRequest, DeliveryPredictionResponse

app = FastAPI(
    title="Delivery Time Prediction API",
    description="Predicts food delivery time (minutes) from courier, order, and location data.",
    version="1.0.0",
)

# Load once at startup, not on every request -- the model/scaler never change between requests
model_bundle = load_bundle()


@app.get("/")
def health_check():
    return {"status": "ok", "message": "Delivery Time Prediction API is running"}


@app.post("/predict", response_model=DeliveryPredictionResponse)
def predict(request: DeliveryPredictionRequest):
    predicted_minutes = predict_delivery_time(
        delivery_person_age=request.delivery_person_age,
        delivery_person_ratings=request.delivery_person_ratings,
        restaurant_latitude=request.restaurant_latitude,
        restaurant_longitude=request.restaurant_longitude,
        delivery_latitude=request.delivery_latitude,
        delivery_longitude=request.delivery_longitude,
        type_of_order=request.type_of_order.value,
        type_of_vehicle=request.type_of_vehicle.value,
        bundle=model_bundle,
    )
    return DeliveryPredictionResponse(predicted_delivery_time_minutes=round(predicted_minutes, 2))
