"""Load the best-performing delivery-time model and make a prediction.
"""

import math
import os
import joblib
import pandas as pd

BUNDLE_PATH = os.path.join(os.path.dirname(__file__), "model_bundle.joblib")


def load_bundle(path: str = BUNDLE_PATH) -> dict:
    return joblib.load(path)

# Great-circle distance between two lat/long points, in kilometers.
def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    return r * 2 * math.asin(math.sqrt(a))


def predict_delivery_time(
    delivery_person_age: float,
    delivery_person_ratings: float,
    restaurant_latitude: float,
    restaurant_longitude: float,
    delivery_latitude: float,
    delivery_longitude: float,
    type_of_order: str,
    type_of_vehicle: str,
    bundle: dict | None = None,
) -> float:
    # Predict delivery time in minutes 
    if bundle is None:
        bundle = load_bundle()

    model = bundle["model"]
    scaler = bundle["scaler"]
    numeric_cols = bundle["numeric_cols"]
    feature_columns = bundle["feature_columns"]

    distance_km = haversine_km(
        restaurant_latitude, restaurant_longitude, delivery_latitude, delivery_longitude
    )

    row = {col: False for col in feature_columns}
    row["Delivery_person_Age"] = delivery_person_age
    row["Delivery_person_Ratings"] = delivery_person_ratings
    row["distance_km"] = distance_km

    order_col = f"Type_of_order_{type_of_order}"
    vehicle_col = f"Type_of_vehicle_{type_of_vehicle}"
    if order_col in row:
        row[order_col] = True
    if vehicle_col in row:
        row[vehicle_col] = True

    X = pd.DataFrame([row], columns=feature_columns)
    X[numeric_cols] = scaler.transform(X[numeric_cols])

    return float(model.predict(X)[0])


if __name__ == "__main__":
    prediction = predict_delivery_time(
        delivery_person_age=30,
        delivery_person_ratings=4.7,
        restaurant_latitude=12.9716,
        restaurant_longitude=77.5946,
        delivery_latitude=13.0350,
        delivery_longitude=77.6431,
        type_of_order="Snack",
        type_of_vehicle="motorcycle",
    )
    print(f"Predicted delivery time: {prediction:.2f} minutes")
