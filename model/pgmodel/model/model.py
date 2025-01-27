import sys
import os
from datetime import datetime, UTC
import pymongo
import joblib
from sklearn.model_selection import train_test_split
from pgmodel.constants import MONGODB_ENDPOINT, DATABASE_NAME, RawFeatureName
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


def final_dataset() -> pd.DataFrame:
    dbfetcher = DatabaseFetcher()

    static_guard_telemetries = list(dbfetcher.static_guard_telemetries_data().values())
    locations, crack_telemetries, pothole_telemetries = dbfetcher.dynamic_guard_telemetries_data()
    maintenance_operations = dbfetcher.maintenance_operations()
    for maintenance in maintenance_operations:
        maintenance["date"] = pd.to_datetime(maintenance["date"])

    db_total: list[pd.DataFrame] = []

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
            telemetries = Preprocessor().process(telemetries, location, maintenances)
            db_total.append(telemetries)

        except KeyError as key_error:
            print("error:", key_error)
            print(location)

    db_total = pd.DataFrame(db_total)

    return db_total


class PaveGuardModel:

    def __init__(self, crack_model_name: str, crack_model: BaseEstimator, pothole_model_name: str, pothole_model: BaseEstimator,
                 mongodb_endpoint: str = MONGODB_ENDPOINT, test_size: float = 0.25):
        self.crack_model = crack_model
        self.pothole_model = pothole_model
        self.mongodb_endpoint = mongodb_endpoint
        self.crack_model_name = crack_model_name
        self.pothole_model_name = pothole_model_name
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




    def save_model_db(self):
        client = pymongo.MongoClient(self.mongodb_endpoint)
        db = client[DATABASE_NAME]
        collection = db["model_weights"]

        document = {
            "crack_model_name": self.crack_model_name,
            "pothole_model_name": self.pothole_model_name,
            "crack_model_weights": joblib.dumps(self.crack_model),
            "pothole_model_weights": joblib.dumps(self.pothole_model),
            "updated_at": datetime.now(UTC)
        }

        collection.insert_one(document)
        print("model saved")





if __name__ == '__main__':

    model = PaveGuardModel(
        crack_model_name="random_forest",
        crack_model=RandomForestClassifier(),
        pothole_model_name="random_forest",
        pothole_model=RandomForestClassifier(),
    )

    dataset = final_dataset()

    print(dataset)

    X = dataset.drop(columns=[RawFeatureName.CRACK.value, RawFeatureName.POTHOLE.value])
    Y_crack = dataset[RawFeatureName.CRACK.value]
    Y_pothole = dataset[RawFeatureName.POTHOLE.value]

    model.fit(X, Y_crack, Y_pothole)

    model.save_model_db()

