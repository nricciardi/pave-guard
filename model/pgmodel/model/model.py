import json
import sys
import os
from typing import Dict
from pymongo import MongoClient

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from datetime import datetime, UTC
import joblib
from sklearn.model_selection import train_test_split
from pgmodel.constants import MONGODB_ENDPOINT, DATABASE_NAME, RawFeatureName, FeatureName, DataframeKey
from pgmodel.dataset.database_middleware import DatabaseFetcher
from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.preprocess.preprocessor import Preprocessor
from sklearn.base import BaseEstimator
from sklearn.tree import DecisionTreeRegressor
import pandas as pd
from sklearn.metrics import mean_squared_error
from prophet import Prophet


sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))


def is_maintenance_for_road(maintenance, location) -> bool:
    return maintenance["road"] == location["road"] and maintenance["city"] == location["city"] and maintenance["county"] == location["county"] and maintenance["state"] == location["state"]


def final_dataset() -> tuple[pd.DataFrame, pd.DataFrame]:
    dbfetcher = DatabaseFetcher()

    static_guard_telemetries = list(dbfetcher.static_guard_telemetries_data().values())
    locations, crack_telemetries, pothole_telemetries = dbfetcher.dynamic_guard_telemetries_data()
    maintenance_operations = dbfetcher.maintenance_operations()
    for maintenance in maintenance_operations:
        maintenance["date"] = pd.to_datetime(maintenance["date"])

    db_total_crack: list[pd.DataFrame] = []
    db_total_pothole: list[pd.DataFrame] = []

    for location, crack_telemetries_of_loc, pothole_telemetries_of_loc in zip(locations, crack_telemetries, pothole_telemetries):

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
            crack, pothole = Preprocessor().process(telemetries, location, maintenances)
            db_total_crack.append(crack)
            db_total_pothole.append(pothole)

        except KeyError as key_error:
            print("error:", key_error)
            print(location)

    db_total_crack = pd.concat(db_total_crack, ignore_index=True)
    db_total_pothole = pd.concat(db_total_pothole, ignore_index=True)

    return db_total_crack, db_total_pothole

def build_prophets_datasets(location: dict):
    dbfetcher = DatabaseFetcher()

    static_guard_telemetries = dbfetcher.static_guard_telemetries_data(location)

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



class PaveGuardModel:

    models_info_file_name = "models_info.json"
    crack_model_file_name = "crack_model"
    pothole_model_file_name = "pothole_model"

    def __init__(self, crack_model: BaseEstimator, pothole_model: BaseEstimator,
                 test_size: float = 0.25):

        self.crack_model = crack_model
        self.pothole_model = pothole_model
        self.test_size = test_size
        self.performances = None

    def train(self, X_crack: pd.DataFrame, y_crack: pd.Series, X_pothole: pd.DataFrame, y_pothole: pd.Series) -> dict:

        X_train_crack, X_test_crack, y_train_crack, y_test_crack = train_test_split(X_crack, y_crack, test_size=self.test_size)

        X_train_pothole, X_test_pothole, y_train_pothole, y_test_pothole = train_test_split(X_pothole, y_pothole, test_size=self.test_size)

        self.__fit_crack_model(X_train_crack, y_train_crack)
        self.__fit_pothole_model(X_train_pothole, y_train_pothole)

        self.performances = {
            "crack_model_performance": self.__eval_crack_model(X_test_crack, y_test_crack),
            "pothole_model_performance": self.__eval_crack_model(X_test_pothole, y_test_pothole),
        }

        return self.performances

    def predict(self, location: dict, n_months: int = 12):       # TODO: county can be None

        n_days = n_months * 30

        prophets_datasets = build_prophets_datasets(location)

        prophets_predictions: Dict[str, pd.DataFrame] = {}

        for feature, df in prophets_datasets.items():
            df['ds'] = pd.to_datetime(df['ds']).dt.tz_localize(None)

            prophet_model = Prophet()

            prophet_model.fit(df)

            future = prophet_model.make_future_dataframe(periods=n_days)

            forecast = prophet_model.predict(future)

            prophets_predictions[feature] = forecast

        # TODO: prediction


        final_crack_predictions = []
        final_pothole_predictions = []

        assert len(final_crack_predictions), n_months
        assert len(final_pothole_predictions), n_months

        return final_crack_predictions, final_pothole_predictions



    def __fit_crack_model(self, X: pd.DataFrame, y: pd.Series):
        self.crack_model.fit(X, y)

    def __fit_pothole_model(self, X: pd.DataFrame, y: pd.Series):
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
    mongodb_client = MongoClient(MONGODB_ENDPOINT)

    dbfetcher = DatabaseFetcher()

    static_guards = dbfetcher.static_guards()

    crack_telemetries = dbfetcher.crack_telemetries_by_date()
    crack_telemetries = crack_telemetries.rename(columns={
        "metadata_road": "road",
        "metadata_city": "city",
        "metadata_county": "county",
        "metadata_state": "state",
    })

    # pothole_telemetries = dbfetcher.pothole_telemetries_by_date()
    # pothole_telemetries = pothole_telemetries.rename(columns={
    #     "metadata_road": "road",
    #     "metadata_city": "city",
    #     "metadata_county": "county",
    #     "metadata_state": "state",
    # })

    # TODO: may be empty

    # print(crack_telemetries.columns)
    # print(pothole_telemetries.columns)

    # crack_telemetries_aggregated_by_location = crack_telemetries.groupby(["road", "city", "county", "state"])["severity"].mean()
    # pothole_telemetries_aggregated_by_location = pothole_telemetries.groupby(["road", "city", "county", "state"])["severity"].mean()

    # final_crack_predictions, final_pothole_predictions = model.predict(location)
    #
    # db_collection = mongodb_client[DATABASE_NAME].predictions
    #
    # db_collection.replace_one(location, {
    #     "updatedAt": str(datetime.now(UTC)),
    #     "crackSeverityPredictions": final_crack_predictions,
    #     "potholeSeverityPredictions": final_pothole_predictions,
    #     **location
    # })

    # print(crack_telemetries_aggregated_by_location)





if __name__ == '__main__':

    model = PaveGuardModel(
        crack_model=DecisionTreeRegressor(),
        pothole_model=DecisionTreeRegressor(),
    )

    make_and_upload_daily_predictions(model)

    crack_dataset, pothole_dataset = final_dataset()

    X_crack = crack_dataset.drop(columns=[FeatureName.TARGET])
    X_pothole = pothole_dataset.drop(columns=[FeatureName.TARGET])
    y_crack = crack_dataset[FeatureName.TARGET]
    y_pothole = pothole_dataset[FeatureName.TARGET]

    model.train(X_crack, y_crack, X_pothole, y_pothole)

    output_path = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/model/saved_model"
    models_info_file_path = model.save_model_db(output_path)

    updated_at = model.restore_model(models_info_file_path)

    print("last updated:", updated_at)