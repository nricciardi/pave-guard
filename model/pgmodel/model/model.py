import json
import sys
import os
from concurrent.futures import ProcessPoolExecutor
from typing import Dict

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from datetime import datetime, UTC
import joblib
from sklearn.model_selection import train_test_split
from pgmodel.constants import RawFeatureName, FeatureName, DataframeKey
from pgmodel.dataset.database_middleware import DatabaseFetcher, DatabaseFiller
from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.preprocess.preprocessor import Preprocessor
from sklearn.base import BaseEstimator
from sklearn.tree import DecisionTreeRegressor
from sklearn.neighbors import KNeighborsRegressor
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.svm import SVR
from sklearn.model_selection import GridSearchCV
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, Normalizer, RobustScaler
from sklearn.feature_selection import SelectKBest
import pandas as pd
from sklearn.metrics import mean_squared_error
from prophet import Prophet

def is_maintenance_for_road(maintenance, location) -> bool:
    return maintenance["road"] == location["road"] and maintenance["city"] == location["city"] and maintenance["county"] == location["county"] and maintenance["state"] == location["state"]


def generate_final_dataset_by_location(location: dict, crack_telemetries_of_loc, pothole_telemetries_of_loc, static_guard_telemetries: list, maintenance_operations: list, num_final_rows: int):       #

    # location, crack_telemetries_of_loc, pothole_telemetries_of_loc, static_guard_telemetries, maintenance_operations, num_final_rows = data

    print(f"processing: {location}")

    if crack_telemetries_of_loc.empty or pothole_telemetries_of_loc.empty:
        return None

    try:
        crack_severity = crack_telemetries_of_loc.rename(columns={"severity": "crack"})
        pothole_severity = pothole_telemetries_of_loc.rename(columns={"severity": "pothole"})
        telemetries = [df for df in static_guard_telemetries if not df.empty]
        telemetries.append(crack_severity)
        telemetries.append(pothole_severity)

        location["latitude"] = (crack_severity["latitude"].mean() + pothole_severity["latitude"].mean()) / 2
        location["longitude"] = (crack_severity["longitude"].mean() + pothole_severity["longitude"].mean()) / 2

        maintenances = [maintenance for maintenance in maintenance_operations if
                        is_maintenance_for_road(maintenance, location)]

        telemetries = DatasetGenerator.telemetries_to_dataframe(telemetries)
        crack, pothole = Preprocessor().process(telemetries, location, maintenances, num_final_rows=num_final_rows)

        return crack, pothole

    except KeyError as key_error:
        print("KEY ERROR:", key_error)
        print(location)
        raise key_error

def final_dataset(dump: bool = False, output_path: str | None = None, plot: bool = False, num_final_rows: int = 0) -> tuple[pd.DataFrame, pd.DataFrame]:

    print("generating final dataset (train dataset)...")
    if(num_final_rows < 0):
        raise ValueError("num_final_rows must be >= 0")

    dbfetcher = DatabaseFetcher()

    static_guard_telemetries = list(dbfetcher.static_guard_telemetries_data().values())
    locations, crack_telemetries, pothole_telemetries = dbfetcher.dynamic_guard_telemetries_data()
    num_final_rows = int(num_final_rows / len(locations))
    maintenance_operations = dbfetcher.maintenance_operations()
    for maintenance in maintenance_operations:
        maintenance["date"] = pd.to_datetime(maintenance["date"])

    with ProcessPoolExecutor(max_workers=os.cpu_count()) as executor:

        db_total_crack: list[pd.DataFrame] = []
        db_total_pothole: list[pd.DataFrame] = []
        futures = []

        for location, crack_telemetries_of_loc, pothole_telemetries_of_loc in zip(locations, crack_telemetries, pothole_telemetries):
            futures.append(
                executor.submit(
                    generate_final_dataset_by_location,
                    location,
                    crack_telemetries_of_loc,
                    pothole_telemetries_of_loc,
                    static_guard_telemetries,
                    maintenance_operations,
                    num_final_rows
                )
            )

        for future in futures:
            result = future.result()

            if result is not None:
                crack, pothole = result

                crack = crack.drop(columns=[FeatureName.POTHOLE_SEVERITY.value])
                crack = crack.rename({FeatureName.CRACK_SEVERITY.value: "initial_severity"})
                db_total_crack.append(crack)

                pothole = pothole.drop(columns=[FeatureName.CRACK_SEVERITY.value])
                pothole = pothole.rename({FeatureName.POTHOLE_SEVERITY.value: "initial_severity"})
                db_total_pothole.append(pothole)


        if db_total_crack:
            db_total_crack = pd.concat(db_total_crack, ignore_index=True)
        else:
            db_total_crack = pd.DataFrame()

        if db_total_pothole:
            db_total_pothole = pd.concat(db_total_pothole, ignore_index=True)
        else:
            db_total_pothole = pd.DataFrame()

        if dump:
            print("dump csv")
            db_total_crack.to_csv(os.path.join(output_path, "crack_train_dataset.csv"), index=False)
            db_total_pothole.to_csv(os.path.join(output_path, "pothole_train_dataset.csv"), index=False)

        if plot:
            import seaborn as sns
            import matplotlib.pyplot as plt

            sns.heatmap(db_total_crack.corr(), annot=True)
            plt.show()

            sns.heatmap(db_total_pothole.corr(), annot=True)
            plt.show()


        return db_total_crack, db_total_pothole

def build_prophets_datasets(static_guard_id: str):
    dbfetcher = DatabaseFetcher()

    static_guard_telemetries = dbfetcher.static_guard_telemetries_data(static_guard_id=static_guard_id)

    datasets = {}

    datasets[RawFeatureName.TEMPERATURE.value] = static_guard_telemetries[DataframeKey.TEMPERATURE.value][["timestamp", "temperature"]]
    datasets[RawFeatureName.TEMPERATURE.value] = datasets[RawFeatureName.TEMPERATURE.value].rename(columns={"timestamp": "ds", "temperature": "y"})

    datasets[RawFeatureName.HUMIDITY.value] = static_guard_telemetries[DataframeKey.HUMIDITY.value][["timestamp", "humidity"]]
    datasets[RawFeatureName.HUMIDITY.value] = datasets[RawFeatureName.HUMIDITY.value].rename(columns={"timestamp": "ds", "humidity": "y"})

    datasets[RawFeatureName.RAINFALL.value] = static_guard_telemetries[DataframeKey.RAINFALL.value][["timestamp", "mm"]]
    datasets[RawFeatureName.RAINFALL.value] = datasets[RawFeatureName.RAINFALL.value].rename(columns={"timestamp": "ds", "mm": "y"})

    datasets[RawFeatureName.TRANSIT_TIME.value] = static_guard_telemetries[DataframeKey.TRANSIT.value][["timestamp", "transitTime"]]
    datasets[RawFeatureName.TRANSIT_TIME.value] = datasets[RawFeatureName.TRANSIT_TIME.value].rename(columns={"timestamp": "ds", "transitTime": "y"})

    datasets[RawFeatureName.TRANSIT_VELOCITY.value] = static_guard_telemetries[DataframeKey.TRANSIT.value][["timestamp", "velocity"]]
    datasets[RawFeatureName.TRANSIT_VELOCITY.value] = datasets[RawFeatureName.TRANSIT_VELOCITY.value].rename(columns={"timestamp": "ds", "velocity": "y"})

    datasets[RawFeatureName.TRANSIT_LENGTH.value] = static_guard_telemetries[DataframeKey.TRANSIT.value][["timestamp", "length"]]
    datasets[RawFeatureName.TRANSIT_LENGTH.value] = datasets[RawFeatureName.TRANSIT_LENGTH.value].rename(columns={"timestamp": "ds", "length": "y"})

    return datasets


def process_whole_telemetries(data: Dict[str, Dict[str, pd.DataFrame]], ids_modulated: Dict[str, float], n_days: int) -> tuple[
    pd.DataFrame, pd.DataFrame]:
    telemetry_types = data[list(data.keys())[0]].keys()
    my_dfs = {}

    for idk in data.keys():
        my_dfs[idk] = {}
        for telemetry_type in data[idk].keys():
            my_dfs[idk][telemetry_type] = data[idk][telemetry_type][["yhat", "ds"]].copy()
            my_dfs[idk][telemetry_type] = my_dfs[idk][telemetry_type].rename(
                columns={"yhat": telemetry_type, "ds": "timestamp"})
            my_dfs[idk][telemetry_type]["modulation"] = ids_modulated[idk]

    dfs = [
        pd.concat([my_dfs[idk][telemetry_type] for idk in data.keys()]) for telemetry_type in telemetry_types
    ]

    df = DatasetGenerator.telemetries_to_dataframe(dfs, n_days=n_days)
    df["maintenance"] = 0
    rainfall_indices = df.loc[~df[RawFeatureName.RAINFALL.value].isna()].index
    df.loc[:, FeatureName.IS_RAINING.value] = df.index.to_series().apply(
            lambda timestamp: int(Preprocessor().is_raining_at_time(rainfall_indices, pd.to_datetime(timestamp)))
        )
    df["storm"] = 0
    grouped_by_day = df[[FeatureName.IS_RAINING.value, RawFeatureName.RAINFALL.value]].groupby(df.index.date)
    for day, group in grouped_by_day:
        first_occurrence_index = group.index[0]
        if(group[RawFeatureName.RAINFALL.value].sum() > 10.):
            df.loc[first_occurrence_index, "storm"] = 1
    single_row = Preprocessor().process_single_row(df)

    crack_row = single_row.drop(columns=[FeatureName.POTHOLE_SEVERITY.value]).copy()
    crack_row = crack_row.rename({FeatureName.CRACK_SEVERITY.value: "initial_severity"})

    pothole_row = single_row.drop(columns=[FeatureName.CRACK_SEVERITY.value]).copy()
    pothole_row = pothole_row.rename({FeatureName.POTHOLE_SEVERITY.value: "initial_severity"})

    return crack_row, pothole_row

def build_eval_data(crack: float, pothole: float, data: Dict[str, Dict[str, pd.DataFrame]], ids_modulated: Dict[str, float], n_days: int) -> tuple[
    pd.DataFrame, pd.DataFrame]:

    crack_record, pothole_record = process_whole_telemetries(data, ids_modulated, n_days)

    crack_record[FeatureName.CRACK_SEVERITY.value] = crack
    crack_record[FeatureName.POTHOLE_SEVERITY.value] = pothole

    pothole_record[FeatureName.CRACK_SEVERITY.value] = crack
    pothole_record[FeatureName.POTHOLE_SEVERITY.value] = pothole

    return crack_record, pothole_record


class PaveGuardModel:

    models_info_file_name = "models_info.json"
    crack_model_file_name = "crack_model"
    pothole_model_file_name = "pothole_model"

    def __init__(self, crack_model: BaseEstimator, crack_param_grid: dict, pothole_model: BaseEstimator, pothole_param_grid: dict,
                 test_size: float = 0.25):

        self.crack_param_grid = crack_param_grid
        self.pothole_param_grid = pothole_param_grid
        self.prophet_predictions_cache: Dict[str, Dict[str, pd.DataFrame]] = {}
        self.raw_crack_model = crack_model
        self.raw_pothole_model = pothole_model
        self.crack_model = None
        self.pothole_model = None
        self.test_size = test_size
        self.performances = None

    def train(self, X_crack: pd.DataFrame, y_crack: pd.Series, X_pothole: pd.DataFrame, y_pothole: pd.Series) -> dict:

        X_train_crack, X_test_crack, y_train_crack, y_test_crack = train_test_split(X_crack, y_crack, test_size=self.test_size)

        X_train_pothole, X_test_pothole, y_train_pothole, y_test_pothole = train_test_split(X_pothole, y_pothole, test_size=self.test_size)

        print("fit crack model...")
        self.__fit_crack_model(X_train_crack, y_train_crack)

        print("fit pothole model...")
        self.__fit_pothole_model(X_train_pothole, y_train_pothole)

        self.performances = {
            "crack_model_performance": self.__eval_crack_model(X_test_crack, y_test_crack),
            "pothole_model_performance": self.__eval_pothole_model(X_test_pothole, y_test_pothole),
        }

        return self.performances

    def clear_cache(self):
        self.prophet_predictions_cache = {}

    def _single_predict(self, latitude: float, longitude: float, crack: int, pothole: int, n_months):

        day_in_a_month = 30
        n_days = day_in_a_month * n_months

        dbfetcher = DatabaseFetcher()

        static_guards = dbfetcher.static_guards()

        modulations = Preprocessor.get_modulated_ids(static_guards, latitude, longitude)

        for static_guard_id in modulations.keys():

            if static_guard_id in self.prophet_predictions_cache:
                print(f"data of SG:{static_guard_id} are already in cache")
                continue

            prophets_datasets = build_prophets_datasets(static_guard_id)

            prophets_predictions: Dict[str, pd.DataFrame] = {}

            for feature, df in prophets_datasets.items():
                df['ds'] = pd.to_datetime(df['ds']).dt.tz_localize(None)

                prophet_model = Prophet()

                prophet_model.fit(df)

                future = prophet_model.make_future_dataframe(periods=n_days)

                forecast = prophet_model.predict(future)

                prophets_predictions[feature] = forecast

            self.prophet_predictions_cache[static_guard_id] = prophets_predictions


        n_days = 0

        final_crack_predictions: list[float] = []
        final_pothole_predictions: list[float] = []

        for m in range(n_months):

            n_days += day_in_a_month
            crack_features, pothole_features = build_eval_data(crack, pothole, self.prophet_predictions_cache, modulations, n_days)

            print(f"predict {m + 1} month using:")
            # print("crack_features:")
            # print(crack_features.columns)
            # print(crack_features.iloc[0].to_list())

            crack_pred = self.crack_model.predict(crack_features)
            pothole_pred = self.pothole_model.predict(pothole_features)

            print(f"prediction:\ncrack: {crack_pred}\npothole: {pothole_pred}")

            crack_pred = float(crack_pred[0])
            pothole_pred = float(pothole_pred[0])

            final_crack_predictions.append(max(0, min(100, crack_pred)))
            final_pothole_predictions.append(max(0, min(100, pothole_pred)))


        assert len(final_crack_predictions), n_months
        assert len(final_pothole_predictions), n_months

        return final_crack_predictions, final_pothole_predictions


    def predict(self, dynamic_guard_transits: pd.DataFrame, n_months: int = 12) -> list[dict]:

        self.prophet_predictions_cache = {}

        predictions: list[dict] = []

        for dynamic_guard_transit in dynamic_guard_transits.to_dict(orient="records"):

            print("predict using:")
            print(dynamic_guard_transit)

            final_crack_predictions, final_pothole_predictions = self._single_predict(
                latitude=dynamic_guard_transit["latitude"],
                longitude=dynamic_guard_transit["longitude"],
                crack=dynamic_guard_transit["crack"],
                pothole=dynamic_guard_transit["pothole"],
                n_months=n_months
            )

            predictions.append({
                "road": dynamic_guard_transit["road"],
                "city": dynamic_guard_transit["city"],
                "county": dynamic_guard_transit["county"],
                "state": dynamic_guard_transit["state"],
                "crackSeverityPredictions": list(final_crack_predictions),
                "potholeSeverityPredictions": list(final_pothole_predictions)
            })


        return predictions



    def __fit_crack_model(self, X: pd.DataFrame, y: pd.Series):
        self.crack_model = GridSearchCV(estimator=self.raw_crack_model, param_grid=self.crack_param_grid, scoring="neg_mean_squared_error")
        self.crack_model.fit(X, y)

    def __fit_pothole_model(self, X: pd.DataFrame, y: pd.Series):
        self.pothole_model = GridSearchCV(estimator=self.raw_pothole_model, param_grid=self.pothole_param_grid, scoring="neg_mean_squared_error")
        self.pothole_model.fit(X, y)

    def __eval_crack_model(self, X: pd.DataFrame, y: pd.Series) -> float:
        y_pred = self.crack_model.predict(X)

        return mean_squared_error(y, y_pred)

    def __eval_pothole_model(self, X: pd.DataFrame, y: pd.Series) -> float:
        y_pred = self.pothole_model.predict(X)

        return mean_squared_error(y, y_pred)


    def save_model_db(self, output_dir_path: str) -> str:


        models_info_output_file_path = os.path.join(output_dir_path, self.models_info_file_name)
        crack_model_output_file_path = os.path.join(output_dir_path, self.crack_model_file_name)
        pothole_model_output_file_path = os.path.join(output_dir_path, self.pothole_model_file_name)

        joblib.dump(self.crack_model, crack_model_output_file_path)
        joblib.dump(self.pothole_model, pothole_model_output_file_path)

        models_info = {
            "crack_model_path": crack_model_output_file_path,
            "pothole_model_path": pothole_model_output_file_path,
            "performances": self.performances,
            "updated_at": str(datetime.now(UTC))
        }

        with open(models_info_output_file_path, "w") as info_file:
            json.dump(models_info, info_file, indent=4)

        return models_info_output_file_path

    def restore_model(self, models_info_file_path: str) -> datetime.date:

        with open(models_info_file_path, "r") as models_info_file:
            models_info = json.load(models_info_file)

            self.crack_model = joblib.load(models_info["crack_model_path"])
            self.pothole_model = joblib.load(models_info["pothole_model_path"])

            return models_info["updated_at"]




def make_and_upload_daily_predictions(model: PaveGuardModel):

    dbfetcher = DatabaseFetcher()

    crack_telemetries = dbfetcher.crack_telemetries_by_date()

    if crack_telemetries.empty:
        crack_telemetries = pd.DataFrame(
            columns=["road", "city", "county", "state", "crack", "latitude", "longitude"])
    else:
        crack_telemetries = crack_telemetries.drop(columns=["timestamp"]).rename(columns={
            "metadata_road": "road",
            "metadata_city": "city",
            "metadata_county": "county",
            "metadata_state": "state",
            "severity": "crack"
        })

    pothole_telemetries = dbfetcher.pothole_telemetries_by_date()

    if pothole_telemetries.empty:
        pothole_telemetries = pd.DataFrame(
            columns=["road", "city", "county", "state", "pothole", "latitude", "longitude"])
    else:
        pothole_telemetries = pothole_telemetries.drop(columns=["timestamp"]).rename(columns={
            "metadata_road": "road",
            "metadata_city": "city",
            "metadata_county": "county",
            "metadata_state": "state",
            "severity": "pothole"
        })

    crack_agg = crack_telemetries.groupby(['road', 'city', 'county', 'state'], as_index=False).agg({
        'crack': 'mean',
        'latitude': 'mean',
        'longitude': 'mean'
    })

    pothole_agg = pothole_telemetries.groupby(['road', 'city', 'county', 'state'], as_index=False).agg({
        'pothole': 'mean',
        'latitude': 'mean',
        'longitude': 'mean'
    })

    data = pd.merge(crack_agg, pothole_agg, on=['road', 'city', 'county', 'state'], how='outer').fillna(0)

    data['latitude'] = data[['latitude_x', 'latitude_y']].mean(axis=1)
    data['longitude'] = data[['longitude_x', 'longitude_y']].mean(axis=1)

    data = data.drop(columns=['latitude_x', 'latitude_y', 'longitude_x', 'longitude_y'])

    if data.empty:
        print("no data")

    predictions = model.predict(data, n_months=12)

    for prediction in predictions:

        prediction = {
            "updatedAt": str(datetime.now(UTC)),
            **prediction
        }

        print(f"upload prediction: {prediction}")

        dbfiller = DatabaseFiller()
        dbfiller.upload_prediction(prediction)

    print("=== REPORT ===")
    for start, prediction in zip(data.to_dict(orient="records"), predictions):
        print(f"{start['crack']} -> {prediction['crackSeverityPredictions']}")
        print(f"{start['pothole']} -> {prediction['potholeSeverityPredictions']}")



def train(model: PaveGuardModel, output_path: str, csvs = False):

    if csvs:
        crack_dataset, pothole_dataset = pd.read_csv(f"{output_path}/crack_train_dataset.csv"), pd.read_csv(f"{output_path}/pothole_train_dataset.csv")

    else:
        crack_dataset, pothole_dataset = final_dataset(dump=True, output_path=output_path, plot=False, num_final_rows=3000)

    X_crack = crack_dataset.drop(columns=[FeatureName.TARGET.value])
    X_pothole = pothole_dataset.drop(columns=[FeatureName.TARGET.value])
    y_crack = crack_dataset[FeatureName.TARGET.value]
    y_pothole = pothole_dataset[FeatureName.TARGET.value]

    model.train(X_crack, y_crack, X_pothole, y_pothole)

    models_info_file_path = model.save_model_db(output_path)

    return model


if __name__ == '__main__':
    output_path_fil = "C:\\Users\\filip\\Desktop\\Universita\\Anno IV - Semestre I\\IOT\\pave-guard\\model\\pgmodel\\model\\saved_model"
    models_info_file_path_fil = f"{output_path_fil}\\models_info.json"
    output_path_nic = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/model/saved_model"
    models_info_file_path_nic = f"{output_path_nic}/models_info.json"

    model = PaveGuardModel(
        crack_model=Pipeline(steps=[
            # ("preprocessing", StandardScaler()),
            # ("kbest", SelectKBest()),
            ("model", LinearRegression())      # criterion=""
        ]),
        crack_param_grid={
            # "model__positive": [True, False],

            # "kbest__k": range(3, 10),

            # "model__criterion": ("squared_error", "friedman_mse", "absolute_error", "poisson"),
            # "model__max_depth": (None, 2, 5, 7),
            # "model__max_leaf_nodes": (None, 2, 5, 7),

            # "model__n_estimators": (10, 50, 100),

            # "model__n_neighbors": range(1, 10),
            # "model__weights": ("uniform", "distance", None),
            # "model__algorithm": ("auto", "ball_tree", "kd_tree", "brute"),

            # "model__C": (0.1, 0.4, 0.7, 1, 1.2, 1.5),
            # "model__kernel": ("linear", "rbf"),
            # "model__epsilon": (0.05, 0.1, 0.15, 0.2),

        },
        pothole_model=Pipeline(steps=[
            # ("preprocessing", StandardScaler()),
            # ("kbest", SelectKBest()),
            ("model", LinearRegression())  # criterion=""
        ]),
        pothole_param_grid={
            # "model__positive": [True, False],

            # "kbest__k": range(3, 10),

            # "model__criterion": ("squared_error", "friedman_mse", "absolute_error", "poisson"),
            # "model__max_depth": (None, 2, 5, 7),
            # "model__max_leaf_nodes": (None, 2, 5, 7),

            # "model__n_estimators": (10, 50, 100),

            # "model__n_neighbors": range(1, 10),
            # "model__weights": ("uniform", "distance", None),
            # "model__algorithm": ("auto", "ball_tree", "kd_tree", "brute"),

            # "model__C": (0.1, 0.4, 0.7, 1, 1.2, 1.5),
            # "model__kernel": ("linear", "rbf"),
            # "model__epsilon": (0.05, 0.1, 0.15, 0.2),
        }
    )

    # train(model, output_path_nic, csvs=False)
    train(model, output_path_fil, csvs=False)

    updated_at = model.restore_model(models_info_file_path_fil)
    model.clear_cache()

    print("last updated:", updated_at)

    print(model.crack_model.best_params_)
    print(model.pothole_model.best_params_)

    print("Performance:")
    print(model.performances)

    crack_columns = list("<FeatureName.TEMPERATURE_MEAN: 'temperature_mean'>, <FeatureName.DELTA_TEMPERATURE: 'delta_temperature'>, <FeatureName.HUMIDITY_MEAN: 'humidity_mean'>, <FeatureName.DAYS: 'days'>, <FeatureName.RAINFALL_QUANTITY: 'rainfall_quantity'>, <FeatureName.STORM_TOTAL: 'storm_total'>, <FeatureName.TRANSIT_TOTAL: 'transit_total'>, <FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL: 'heavy_vehicles_transit_total'>, <FeatureName.TRANSIT_DURING_RAINFALL: 'transit_during_rainfall'>, <FeatureName.HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL: 'heavy_vehicles_transit_during_rainfall'>, <FeatureName.CRACK_SEVERITY: 'crack_severity'>, <FeatureName.POTHOLE_SEVERITY: 'pothole_severity'>".split(","))
    pothole_columns = list("<FeatureName.TEMPERATURE_MEAN: 'temperature_mean'>, <FeatureName.DELTA_TEMPERATURE: 'delta_temperature'>, <FeatureName.HUMIDITY_MEAN: 'humidity_mean'>, <FeatureName.DAYS: 'days'>, <FeatureName.RAINFALL_QUANTITY: 'rainfall_quantity'>, <FeatureName.STORM_TOTAL: 'storm_total'>, <FeatureName.TRANSIT_TOTAL: 'transit_total'>, <FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL: 'heavy_vehicles_transit_total'>, <FeatureName.TRANSIT_DURING_RAINFALL: 'transit_during_rainfall'>, <FeatureName.HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL: 'heavy_vehicles_transit_during_rainfall'>, <FeatureName.CRACK_SEVERITY: 'crack_severity'>, <FeatureName.POTHOLE_SEVERITY: 'pothole_severity'>".split(","))

    crack_weights = model.crack_model.best_estimator_[-1].coef_
    pothole_weights = model.pothole_model.best_estimator_[-1].coef_

    print("crack model:")
    print(json.dumps(dict(zip(crack_columns, crack_weights)), indent=4))

    print("pothole model:")
    print(json.dumps(dict(zip(pothole_columns, pothole_weights)), indent=4))


    make_and_upload_daily_predictions(model)