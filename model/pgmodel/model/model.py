import sys
import os
from pgmodel.dataset.database_middleware import DatabaseFetcher
from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.preprocess.preprocessor import Preprocessor
import pandas as pd
from sklearn.base import BaseEstimator
from sklearn.tree import DecisionTreeClassifier
import pandas as pd


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

    def __init__(self, crack_model: BaseEstimator, pothole_model: BaseEstimator):
        self.crack_model = crack_model
        self.pothole_model = pothole_model

    def fit(self, X: pd.DataFrame, Y_crack: pd.Series, Y_pothole: pd.Series):
        self.crack_model.fit(X, Y_crack)
        self.pothole_model.fit(X, Y_pothole)









if __name__ == '__main__':

    model = PaveGuardModel(
        crack_model=DecisionTreeClassifier(),
        pothole_model=DecisionTreeClassifier(),
    )

    dataset = final_dataset()

    print(dataset)

