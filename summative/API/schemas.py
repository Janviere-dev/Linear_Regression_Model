"""Pydantic request/response schemas for the delivery-time prediction API."""

from enum import Enum

from pydantic import BaseModel, Field


class TypeOfOrder(str, Enum):
    snack = "Snack"
    drinks = "Drinks"
    buffet = "Buffet"
    meal = "Meal"


class TypeOfVehicle(str, Enum):
    motorcycle = "motorcycle"
    scooter = "scooter"
    electric_scooter = "electric_scooter"
    bicycle = "bicycle"


class DeliveryPredictionRequest(BaseModel):
    delivery_person_age: int = Field(
        ..., ge=15, le=50,
        description="Courier's age in years (15-50, matching the training data range)",
    )
    delivery_person_ratings: float = Field(
        ..., ge=1.0, le=5.0,
        description="Courier's average rating, 1.0-5.0 stars",
    )
    restaurant_latitude: float = Field(..., ge=-90, le=90, description="Restaurant's latitude")
    restaurant_longitude: float = Field(..., ge=-180, le=180, description="Restaurant's longitude")
    delivery_latitude: float = Field(..., ge=-90, le=90, description="Delivery destination's latitude")
    delivery_longitude: float = Field(..., ge=-180, le=180, description="Delivery destination's longitude")
    type_of_order: TypeOfOrder
    type_of_vehicle: TypeOfVehicle


class DeliveryPredictionResponse(BaseModel):
    predicted_delivery_time_minutes: float


class NewDeliveryRecord(DeliveryPredictionRequest):

    actual_delivery_time_minutes: float = Field(
        ..., ge=1.0, le=300.0,
        description="The real, observed delivery time for this record (minutes)",
    )


class RetrainResponse(BaseModel):
    rows_added: int
    total_training_rows: int
    model_name: str
    test_mse: float
    test_r2: float
