# Delivery Time Prediction — Linear Regression Summative

**Mission:** Empower local e-commerce and logistics platforms with intelligent, data-driven arrival estimates that optimize driver scheduling, lower operational overhead, and build long-term customer trust through transparency.

**Problem:** Dispatchers and customers lack a reliable way to know how long a delivery will actually take. This project predicts delivery time from courier, order, and distance data so platforms can generate accurate ETAs and intervene on likely delays before they happen.

**Dataset:** `deliverytime.csv`  45,593 raw rows of food deliveries across multiple Indian cities (Indore, Bangalore, Coimbatore, Chennai, and others), with courier age/rating, restaurant and drop-off GPS coordinates, order type, vehicle type, and the actual recorded delivery time. <!-- TODO: add the exact Kaggle/source URL here -->

## Repository structure

```
summative/
├── linear_regression/
│   ├── multivariate.ipynb   # EDA, cleaning, feature engineering, model comparison
│   └── data/
│       └── deliverytime.csv
├── API/
│   ├── prediction.py        # loads the saved model, exposes predict_delivery_time()
│   └── model_bundle.joblib  # saved best model + scaler + feature schema
├── FlutterApp/          
└── pyproject.toml
```

## Task 1 — Model (notebook: `summative/linear_regression/multivariate.ipynb`)

Cleaned 45,593 raw rows down to 41,953 after fixing sign-corrupted coordinates and
dropping unrecoverable placeholder GPS values; engineered a `distance_km` feature
(Haversine distance between restaurant and drop-off point) to replace 4 raw lat/long
columns. Compared 4 regression algorithms on the same standardized, one-hot-encoded
data:

- **SGD Regressor** (stochastic gradient descent trained via `partial_fit` with a
  manual epoch loop to produce the train/test loss curve)
- **Linear Regression** (closed-form)
- **Decision Tree** (tuned `max_depth` via grid search to fix severe overfitting)
- **Random Forest** (tuned `max_depth`/`n_estimators` via grid search)

The best model (lowest test MSE) is saved to `summative/API/model_bundle.joblib`
along with the fitted `StandardScaler` and the exact feature column schema, so
predictions in Task 2 are preprocessed identically to training.

