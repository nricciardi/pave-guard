from datetime import datetime, timedelta

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

    def arrayCount(self, array: np.ndarray) -> int:
        return array.size

    def getGroups(self, data_timestamps: pd.DataFrame, feature_name: str) -> dict:
        grouped_by_day = {}
        for day, group in data_timestamps.groupby(data_timestamps.index.date):
            grouped_by_day[day] = group[feature_name].dropna().tolist()
        return grouped_by_day

    def getDays(self, days: np.ndarray) -> int:
        days = pd.to_datetime(days)
        return (
            (days.max() - days.min()).days
        )

    def getStorms(self, rainfall_timestamps: pd.DataFrame,
                  rain_name: str = RawFeatureName.RAINFALL,
                  storm_lower_bound: float = 30.) -> int:

        df = pd.DataFrame(rainfall_timestamps, index=pd.to_datetime(rainfall_timestamps.index))
        grouped_day = self.getGroups(rainfall_timestamps, rain_name)

        for day in grouped_day.keys():
            grouped_day[day] = sum(grouped_day[day])

        return sum([
            1 if value >= storm_lower_bound else 0 for value in grouped_day.values()
        ])

    def getDeltaTemperatures(self, data_timestamps: pd.DataFrame,
                             temperatures_name: str = RawFeatureName.TEMPERATURE) -> float:

        df = pd.DataFrame(data_timestamps, index=pd.to_datetime(data_timestamps.index))
        grouped_by_day = self.getGroups(data_timestamps, temperatures_name)

        for day in grouped_by_day.keys():
            grouped_by_day[day] = max(grouped_by_day[day]) - min(grouped_by_day[day])

        return sum([
            val for val in grouped_by_day.values()
        ]) / len(grouped_by_day.keys())

    def transitDuringRainfall(self, df: pd.DataFrame, is_raining: str = FeatureName.IS_RAINING,
                              length_name: str = FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL) -> int:

        df = df[pd.notna(df[length_name])]
        df = df[df[is_raining] == 1]
        return self.arrayCount(
            df[is_raining]
        )

    def transitHeavyDuringRainfall(self, df: pd.DataFrame, is_raining: str = FeatureName.IS_RAINING,
                              length_name: str = FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL) -> int:

        df = df[pd.notna(df[length_name])]
        df = df[self.isVehicleHeavy(df[length_name])]
        df = df[df[is_raining] == 1]
        return self.arrayCount(
            df[is_raining]
        )

    def isRainingAtTime(self, data: np.ndarray, timestamp: datetime, delta: timedelta = timedelta(minutes=5)):
        return ((data >= timestamp - delta) &
                (data <= timestamp + delta)).any()

    def isVehicleHeavy(self, vehicle_length: float) -> bool:
        return vehicle_length >= 4

    def process(self, raw_dataset: pd.DataFrame) -> pd.DataFrame:

        dataset = pd.DataFrame(columns=[feat for feat in FeatureName])

        dataset[FeatureName.TEMPERATURE_MEAN] = self.arrayMean(raw_dataset[RawFeatureName.TEMPERATURE.value])
        dataset[FeatureName.HUMIDITY_MEAN] = self.arrayMean(raw_dataset[RawFeatureName.HUMIDITY.value])
        dataset[FeatureName.DAYS] = self.getDays(raw_dataset.index)
        dataset[FeatureName.SUBZERO_TEMPERATURE_MEAN] = self.subzeroTemperatureMean(raw_dataset[RawFeatureName.TEMPERATURE.value])
        dataset[FeatureName.RAINFALL_QUANTITY] = self.arraySum(raw_dataset[RawFeatureName.RAINFALL.value])
        # TODO: Solve these
        # dataset[FeatureName.STORM_TOTAL] = self.getStorms(raw_dataset[RawFeatureName.RAINFALL.value])
        # dataset[FeatureName.DELTA_TEMPERATURE] = self.getDeltaTemperatures(raw_dataset[[RawFeatureName.TEMPERATURE.value]])

        dataset[FeatureName.TRANSIT_TOTAL] = self.arrayCount(raw_dataset[RawFeatureName.TRANSIT_TIME.value])

        heavy_transit: np.ndarray = np.array(1 for length in raw_dataset[RawFeatureName.TRANSIT_LENGTH.value] if self.isVehicleHeavy(length))
        dataset[FeatureName.IS_RAINING] = np.array(
            [1 if self.isRainingAtTime(raw_dataset[RawFeatureName.RAINFALL.value], pd.to_datetime(timestamp)) else 0 for timestamp in dataset.index]
        )

        dataset[FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL] = self.arrayCount(heavy_transit)
        dataset[FeatureName.TRANSIT_DURING_RAINFALL] = self.transitDuringRainfall(dataset)
        dataset[FeatureName.HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL] = self.transitHeavyDuringRainfall(dataset)

        dataset[FeatureName.CRACK_SEVERITY] = self.arrayMean(raw_dataset[RawFeatureName.CRACK.value])
        dataset[FeatureName.POTHOLE_SEVERITY] = self.arraySum(raw_dataset[RawFeatureName.POTHOLE.value])

        return dataset
