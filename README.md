# Delivery Time Prediction  Linear Regression Summative

**Mission:** Empower local e-commerce and logistics platforms with intelligent, data-driven arrival estimates that optimize driver scheduling, lower operational overhead, and build long-term customer trust through transparency.

**Problem:** Dispatchers and customers lack a reliable way to know how long a delivery will actually take. This project predicts delivery time from courier, order, and distance data so platforms can generate accurate ETAs and intervene on likely delays before they happen.


**Dataset:** `deliverytime.csv`  45,593 raw rows of food deliveries across multiple Indian cities (Indore, Bangalore, Coimbatore, Chennai, and others), with courier age/rating, restaurant and drop-off GPS coordinates, order type, vehicle type, and the actual recorded delivery time. https://www.kaggle.com/datasets/rajatkumar30/food-delivery-time

This model's learned patterns are specific to India, but the *system* built around it isn't: the same cleaning approach, distance-based feature engineering, and model pipeline apply to any country's delivery data. The API's `/retrain` endpoint lets this exact deployed system adapt to real local data for example from African logistics platforms like Jumia, Vuba Vuba or Glovo without rebuilding anything, making it a practical starting point for markets, including across Africa, that currently struggle to estimate delivery time accurately.

## Repository structure

```
summative/
├── linear_regression/
│   ├── multivariate.ipynb        # EDA, cleaning, feature engineering, model comparison
│   └── data/
│       ├── deliverytime.csv          # raw source data
│       └── cleaned_deliverytime.csv  # post-cleaning, pre-encoding -- base for retraining
├── API/
│   ├── main.py               # FastAPI app: /predict, /retrain, CORS
│   ├── schemas.py             # Pydantic request/response schemas + Enums
│   ├── prediction.py          # loads the saved model, exposes predict_delivery_time()
│   ├── retrain.py             # retrains on cleaned data + new records, saves model
│   ├── model_bundle.joblib    # saved best model + scaler + feature schema
│   ├── requirements.txt       # for Render (generated via `uv export`)
│   └── runtime.txt            # pins Python version for Render
├── FlutterApp/
└── pyproject.toml
```

## Model (notebook: `summative/linear_regression/multivariate.ipynb`)

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
predictions in API are preprocessed identically to training.

### Running the notebook

1. Install [uv](https://docs.astral.sh/uv/getting-started/installation/) if you
   don't already have it.
2. From the repo root, install dependencies:
   ```bash
   cd linear_regression_model/summative
   uv sync
   ```
   This creates a `.venv` here and installs everything in `pyproject.toml`,
   including `ipykernel` (needed to run the notebook itself).
3. Open `linear_regression/multivariate.ipynb`:
   - **VSCode**: open the file, click the kernel picker (top-right corner), and
     select the Python interpreter at `summative/.venv/bin/python`.
   - **JupyterLab**: `uv run --with jupyterlab jupyter lab`, then open the
     notebook from the browser tab that launches.
4. Use **"Restart Kernel and Run All Cells"** for a clean run top to bottom.

`data/deliverytime.csv` is already included in the repo, so no separate download
is needed before running the notebook.

## API

**Live API:** https://delivery-time-prediction-api.onrender.com
**Swagger UI (interactive docs, testable in-browser):** https://delivery-time-prediction-api.onrender.com/docs

Built with FastAPI, hosted free on Render. Endpoints:

- `POST /predict` takes courier age/rating, restaurant, delivery coordinates, order
  type, and vehicle type; computes the Haversine distance internally and returns a
  predicted delivery time in minutes. Every field has an enforced type and a realistic
  range constraint (Pydantic `Field(ge=..., le=...)`); `type_of_order` and
  `type_of_vehicle` are `Enum`s, so invalid values are rejected before the model ever
  runs, with a structured `422` response listing every violation.
- `POST /retrain` accepts one or more new labeled records (the same fields as
  `/predict`, plus the real observed `actual_delivery_time_minutes`). New records are
  permanently appended to the cleaned training data, the model is refit on the full
  updated dataset (same winning hyperparameters found in the notebook: Random Forest,
  `max_depth=8`, `n_estimators=100`), and the running server's in-memory model is
  swapped immediately  no restart needed for the update to take effect.

**CORS:** configured with an explicit origin list rather than a wildcard (`*`). CORS
only restricts browser-based callers (it checks the `Origin` header) it never
affects the native Flutter mobile app, since mobile apps don't send one.
Restricting origins therefore costs nothing in practice while avoiding a wildcard:
`allow_credentials=False` (no cookies/auth tokens used), `allow_methods` limited to
`GET`/`POST` (all this API exposes), `allow_headers` limited to `Content-Type`.

**Known limitation:** Render's free tier has no persistent disk. `/retrain` works
correctly on the live server, but data/model updates written since the last deploy
are lost if the free instance restarts (which Render does automatically after
inactivity). A production deployment would need a real database or persistent volume
to make retraining durable across restarts.

### Running the API locally

The steps above describe the live, deployed API -- no setup needed to use it. To run
your own local copy instead (e.g. to test changes before deploying):

```bash
git clone <this-repo-url>
cd linear_regression_model/summative/API
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Then open `http://127.0.0.1:8000/docs` for the same Swagger UI, running locally.
`requirements.txt` is a plain-pip export of this project's dependencies (generated
via `uv export`), so this works with just Python and `pip` -- `uv` isn't required
to run it, only to develop it. `model_bundle.joblib` and `cleaned_deliverytime.csv`
are already committed to the repo, so no extra setup or training step is needed
before the API can serve predictions.

## Flutter App

A single-page mobile app (`summative/FlutterApp/`) that calls the live API above.
8 input fields matching `DeliveryPredictionRequest` exactly (courier age, rating,
restaurant/delivery coordinates, order type, vehicle type),a **Predict** button,
and a persistent result/error display area.

### Running it

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) if you
   don't already have it, and confirm it's set up correctly:
   ```bash
   flutter doctor
   ```
2. Get dependencies:
   ```bash
   cd summative/FlutterApp
   flutter pub get
   ```
3. Connect a device:
   - **Physical Android phone**: enable Developer Options (Settings → About Phone →
     tap "Build Number" 7 times), then enable USB Debugging under Developer Options,
     then connect via USB and accept the "Allow USB debugging?" prompt.
   - **Android emulator**: start one from Android Studio, or `flutter emulators launch <id>`.
4. Confirm your device is detected:
   ```bash
   flutter devices
   ```
5. Run the app:
   ```bash
   flutter run
   ```

No local backend setup is needed the app talks directly to the live Render API
(`ApiService.baseUrl` in `lib/services/api_service.dart`), so it works as soon as
it's installed on a device with internet access.

## Video Demo

**YouTube Video:** https://youtu.be/Z9tcbrS-7es

