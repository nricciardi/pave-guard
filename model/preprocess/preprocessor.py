import pandas as pd
import numpy as np

from model.constants import FeatureName, RawFeatureName


class Preprocessor:

    def subzeroTemperatureMean(self, temperatures: np.ndarray) -> float:
        return self.arrayMean(temperatures[temperatures < 0])

    def arrayMean(self, array: np.ndarray) -> float:
        array = array[np.isnan(array)]
        return array.mean(axis=0)

    def arraySum(self, array: np.ndarray) -> float:
        return array.sum(axis=0)

    def getDays(self, days: np.ndarray) -> int:
        days = pd.to_datetime(days)
        return (
            (days.max() - days.min()).days
        )

    def getStorms(self, rainfall_timestamps: pd.DataFrame,
                  rain_name: str = RawFeatureName.RAINFALL,
                  storm_lower_bound: float = 30.) -> int:

        df = pd.DataFrame(rainfall_timestamps, index=pd.to_datetime(rainfall_timestamps.index))
        grouped_day = {}
        for day, group in rainfall_timestamps.groupby(rainfall_timestamps.index.date):
            grouped_day[day] = group[rain_name].dropna().tolist()

        for day in grouped_day.keys():
            grouped_day[day] = sum(grouped_day[day])

        return sum([
            1 if value >= storm_lower_bound else 0 for value in grouped_day.values()
        ])

    def process(self, raw_dataset: pd.DataFrame) -> pd.DataFrame:

        dataset = pd.DataFrame()

        dataset[FeatureName.TEMPERATURE_MEAN] = self.arrayMean(raw_dataset[RawFeatureName.TEMPERATURE])
        dataset[FeatureName.HUMIDITY_MEAN] = self.arrayMean(raw_dataset[RawFeatureName.HUMIDITY])
        dataset[FeatureName.DAYS] = self.getDays(raw_dataset.index)
        dataset[FeatureName.SUBZERO_TEMPERATURE_MEAN] = self.subzeroTemperatureMean(raw_dataset[RawFeatureName.TEMPERATURE])
        dataset[FeatureName.RAINFALL_QUANTITY] = self.arraySum(raw_dataset[RawFeatureName.RAINFALL])
        dataset[FeatureName.STORM_TOTAL] = self.getStorms(raw_dataset[[RawFeatureName.RAINFALL]])

        # TODO
        """
            DELTA_TEMPERATURE = "delta_temperature"
            HEAVY_VEHICLES_TRANSIT_TOTAL = "heavy_vehicles_transit_total"
            TRANSIT_TOTAL = "transit_total"
            TRANSIT_DURING_RAINFALL = "transit_during_rainfall"
            HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL = "heavy_vehicles_transit_during_rainfall"
            POTHOLE_SEVERITY = "pothole_severity"
            CRACK_SEVERITY = "crack_severity"
        """

        return dataset
