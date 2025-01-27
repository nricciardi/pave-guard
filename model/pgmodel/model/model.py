import json
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))
from datetime import datetime, UTC
import joblib
from sklearn.model_selection import train_test_split
from pgmodel.constants import MONGODB_ENDPOINT, DATABASE_NAME, RawFeatureName, FeatureName
from pgmodel.dataset.database_middleware import DatabaseFetcher
from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.preprocess.preprocessor import Preprocessor
from sklearn.base import BaseEstimator
from sklearn.ensemble import RandomForestClassifier
import pandas as pd
from sklearn.metrics import f1_score


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

    def train(self, X: pd.DataFrame, y_crack: pd.Series, y_pothole: pd.Series) -> dict:

        X_train_crack, X_test_crack, y_train_crack, y_test_crack = train_test_split(X, y_crack,
                                                            stratify=y_crack,
                                                            test_size=self.test_size)

        X_train_pothole, X_test_pothole, y_train_pothole, y_test_pothole = train_test_split(X, y_crack,
                                                                                    stratify=y_crack,
                                                                                    test_size=self.test_size)

        self.__fit_crack_model(X, y_train_crack)
        self.__fit_pothole_model(X, y_train_pothole)

        self.performances = {
            "crack_model_performance": self.__eval_crack_model(X_test_crack, y_test_crack),
            "pothole_model_performance": self.__eval_crack_model(X_test_pothole, y_test_pothole),
        }

        return self.performances


    def __fit_crack_model(self, X: pd.DataFrame, y: pd.Series):
        self.crack_model.fit(X, y)

    def __fit_pothole_model(self, X: pd.DataFrame, y: pd.Series):
        self.pothole_model.fit(X, y)

    def __eval_crack_model(self, X: pd.DataFrame, y: pd.Series) -> float:
        y_pred = self.crack_model.predict(X)

        return f1_score(y, y_pred)

    def __eval_pothole_model(self, X: pd.DataFrame, y: pd.Series) -> float:
        y_pred = self.pothole_model.predict(X)

        return f1_score(y, y_pred)


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
            "updated_at": datetime.now(UTC)
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




if __name__ == '__main__':

    model = PaveGuardModel(
        crack_model=RandomForestClassifier(),
        pothole_model=RandomForestClassifier(),
    )

    crack_dataset, poth_dataset = final_dataset()

    print(crack_dataset)

    X_crack = crack_dataset.drop(columns=[FeatureName.TARGET])
    X_poth = poth_dataset.drop(columns=[FeatureName.TARGET])
    Y_crack = crack_dataset[FeatureName.TARGET]
    Y_pothole = poth_dataset[FeatureName.TARGET]

    model.fit(X, Y_crack, Y_pothole)

    output_path = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/model/saved_model"
    models_info_file_path = model.save_model_db(output_path)

    updated_at = model.restore_model(models_info_file_path)

    print(updated_at)

