"""Retrain the delivery-time model using the cleaned  dataset and new records."""

import os
import joblib
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from prediction import BUNDLE_PATH, haversine_km

API_DIR = os.path.dirname(__file__)
CLEANED_DATA_PATH = os.path.join(
    API_DIR, "..", "linear_regression", "data", "cleaned_deliverytime.csv"
)
NUMERIC_COLS = ["Delivery_person_Age", "Delivery_person_Ratings", "distance_km"]


def retrain_model(new_records: list[dict]) -> dict:
    """Append new labeled records to the cleaned dataset, retrain, and save the model.
    Each dict must have: delivery_person_age, delivery_person_ratings,
    restaurant_latitude, restaurant_longitude, delivery_latitude, delivery_longitude,
    type_of_order, type_of_vehicle, actual_delivery_time_minutes.
    """
    base_df = pd.read_csv(CLEANED_DATA_PATH)

    new_rows = []
    for r in new_records:
        distance_km = haversine_km(
            r["restaurant_latitude"], r["restaurant_longitude"],
            r["delivery_latitude"], r["delivery_longitude"],
        )
        new_rows.append({
            "Delivery_person_Age": r["delivery_person_age"],
            "Delivery_person_Ratings": r["delivery_person_ratings"],
            "Type_of_order": r["type_of_order"],
            "Type_of_vehicle": r["type_of_vehicle"],
            "Time_taken(min)": r["actual_delivery_time_minutes"],
            "distance_km": distance_km,
        })

    new_df = pd.DataFrame(new_rows, columns=base_df.columns)
    combined_df = pd.concat([base_df, new_df], ignore_index=True)
    combined_df.to_csv(CLEANED_DATA_PATH, index=False)  

    encoded_df = pd.get_dummies(
        combined_df, columns=["Type_of_order", "Type_of_vehicle"], drop_first=True
    )

    X = encoded_df.drop(columns=["Time_taken(min)"])
    y = encoded_df["Time_taken(min)"]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    scaler = StandardScaler()
    X_train[NUMERIC_COLS] = scaler.fit_transform(X_train[NUMERIC_COLS])
    X_test[NUMERIC_COLS] = scaler.transform(X_test[NUMERIC_COLS])

    model = RandomForestRegressor(max_depth=8, n_estimators=100, random_state=42, n_jobs=-1)
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    test_mse = mean_squared_error(y_test, y_pred)
    test_r2 = r2_score(y_test, y_pred)

    bundle = {
        "model": model,
        "model_name": "Random Forest",
        "scaler": scaler,
        "numeric_cols": NUMERIC_COLS,
        "feature_columns": list(X_train.columns),
    }
    joblib.dump(bundle, BUNDLE_PATH)

    return {
        "bundle": bundle,
        "rows_added": len(new_rows),
        "total_training_rows": len(combined_df),
        "model_name": "Random Forest",
        "test_mse": float(test_mse),
        "test_r2": float(test_r2),
    }
