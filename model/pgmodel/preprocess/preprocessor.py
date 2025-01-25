from datetime import datetime, timedelta

import pandas as pd
import numpy as np

from pgmodel.constants import FeatureName, RawFeatureName


class Preprocessor:

    def subzero_temperature_mean(self, temperatures: np.ndarray) -> float:
        temperatures = temperatures[temperatures < 0]
        if temperatures.size == 0:
            return 0
        return self.array_mean(temperatures)

    def array_mean(self, array: np.ndarray) -> float:
        array = array[~np.isnan(array)]
        return array.mean(axis=0)

    def array_sum(self, array: np.ndarray) -> float:
        return array.sum(axis=0)

    def array_count(self, array: np.ndarray) -> int:
        return array.size

    def get_groups(self, data_timestamps: pd.DataFrame) -> dict:
        grouped_by_day = {}
        for day, group in data_timestamps.groupby(data_timestamps.index.date):
            grouped_by_day[day] = group.dropna().tolist()
        return grouped_by_day

    def get_days(self, days: np.ndarray) -> int:
        days = pd.to_datetime(days)
        return (
            (days.max() - days.min()).days
        )

    def get_storms(self, rainfall_timestamps: pd.DataFrame,
                  rain_name: str = RawFeatureName.RAINFALL.value,
                  storm_lower_bound: float = 30.) -> int:

        df = pd.DataFrame(rainfall_timestamps, index=pd.to_datetime(rainfall_timestamps.index))
        grouped_day = self.get_groups(rainfall_timestamps)

        for day in grouped_day.keys():
            grouped_day[day] = sum(grouped_day[day])

        return sum([
            1 if value >= storm_lower_bound else 0 for value in grouped_day.values()
        ])

    def get_delta_temperatures(self, data_timestamps: pd.DataFrame,
                             temperatures_name: str = RawFeatureName.TEMPERATURE.value) -> float:

        df = pd.DataFrame(data_timestamps, index=pd.to_datetime(data_timestamps.index))
        grouped_by_day = self.get_groups(data_timestamps)

        for day in grouped_by_day.keys():
            grouped_by_day[day] = (max(grouped_by_day[day]) - min(grouped_by_day[day])) if len(grouped_by_day[day]) > 0 else 0

        return sum([
            val for val in grouped_by_day.values()
        ]) / len(grouped_by_day.keys())

    def transit_during_rainfall(self, df: pd.DataFrame, is_raining: str = FeatureName.IS_RAINING.value,
                              length_name: str = RawFeatureName.TRANSIT_LENGTH.value) -> int:

        df = df[pd.notna(df[length_name])]
        df = df[df[is_raining] == 1]
        return self.array_count(
            df[is_raining]
        )

    def transit_heavy_during_rainfall(self, df: pd.DataFrame, is_raining: str = FeatureName.IS_RAINING.value,
                              length_name: str = RawFeatureName.TRANSIT_LENGTH.value) -> int:

        df = df[pd.notna(df[length_name])]
        df = df[self.is_vehicle_heavy(df[length_name])]
        df = df[df[is_raining] == 1]
        return self.array_count(
            df[is_raining]
        )

    def is_raining_at_time(self, data: np.ndarray, timestamp: datetime, delta: timedelta = timedelta(minutes=10)):
        return ((data >= timestamp - delta) &
                (data <= timestamp + delta)).any()

    def is_vehicle_heavy(self, vehicle_length: float) -> bool:
        return vehicle_length >= 4

    def is_row_to_process(self, row: pd.Series) -> bool:
        is_crack_present = pd.notna(row[RawFeatureName.CRACK.value])
        # TODO: Keep in mind road maintenance
        return is_crack_present

    def process(self, raw_dataset: pd.DataFrame, consecutive_measures_only: bool = True) -> pd.DataFrame:

        index_list = []
        # Group by day and process each group
        grouped = raw_dataset.groupby(raw_dataset.index.date)
        for day, group in grouped:
            non_null_indices = group[group[RawFeatureName.CRACK.value].notnull()].index
            if RawFeatureName.CRACK.value in group and not non_null_indices.empty:
                index_list.append(non_null_indices[0])
                first_occurrence_index = non_null_indices[0]
                mean_crack_severity = group[RawFeatureName.CRACK.value].mean()
                raw_dataset.loc[group.index[0:], RawFeatureName.CRACK.value] = np.nan
                raw_dataset.at[first_occurrence_index, RawFeatureName.CRACK.value] = mean_crack_severity
        raw_dataset = raw_dataset.dropna(how='all')

        return self.partition_and_process(raw_dataset, index_list, consecutive_measures_only=consecutive_measures_only)


    def partition_and_process(self, raw_dataset: pd.DataFrame, index_list: list, consecutive_measures_only: bool = True) -> pd.DataFrame:

        rows = []

        for i in range(0, len(index_list) - 1):
            index = index_list[i]
            row = raw_dataset.loc[index]
            if not self.is_row_to_process(row):
                continue
            # Set the first row, I look for another one
            for j in range(i+1, i+2 if consecutive_measures_only else len(index_list)):
                last_index = index_list[j]
                last_row = raw_dataset.loc[last_index]
                if not self.is_row_to_process(last_row):
                    continue
                processed_row = self.process_single_row(raw_dataset.loc[index:last_index])
                processed_row[FeatureName.CRACK_SEVERITY] = row[RawFeatureName.CRACK.value]
                processed_row[FeatureName.TARGET] = last_row[RawFeatureName.CRACK.value]
                rows.append(processed_row.iloc[0])

        return pd.DataFrame(rows)

    def process_single_row(self, raw_dataset: pd.DataFrame) -> pd.DataFrame:

        dataset = pd.DataFrame(index=[0])

        dataset[FeatureName.TEMPERATURE_MEAN] = self.array_mean(raw_dataset[RawFeatureName.TEMPERATURE.value])
        dataset[FeatureName.HUMIDITY_MEAN] = self.array_mean(raw_dataset[RawFeatureName.HUMIDITY.value])
        dataset[FeatureName.DAYS] = self.get_days(raw_dataset.index)
        dataset[FeatureName.SUBZERO_TEMPERATURE_MEAN] = self.subzero_temperature_mean(raw_dataset[RawFeatureName.TEMPERATURE.value])
        dataset[FeatureName.RAINFALL_QUANTITY] = self.array_sum(raw_dataset[RawFeatureName.RAINFALL.value])

        dataset[FeatureName.STORM_TOTAL] = self.get_storms(raw_dataset[RawFeatureName.RAINFALL.value])
        dataset[FeatureName.DELTA_TEMPERATURE] = self.get_delta_temperatures(raw_dataset[RawFeatureName.TEMPERATURE.value])

        dataset[FeatureName.TRANSIT_TOTAL] = self.array_count(raw_dataset[RawFeatureName.TRANSIT_TIME.value])

        heavy_transit: np.ndarray = np.array([1 for length in raw_dataset[RawFeatureName.TRANSIT_LENGTH.value] if self.is_vehicle_heavy(length)])
        raw_dataset.loc[:, FeatureName.IS_RAINING.value] = np.array(
            [1 if self.is_raining_at_time(raw_dataset[~np.isnan(raw_dataset[RawFeatureName.RAINFALL.value])].index, pd.to_datetime(timestamp)) else 0 for timestamp in raw_dataset.index]
        )

        dataset[FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL] = self.array_count(heavy_transit)
        dataset[FeatureName.TRANSIT_DURING_RAINFALL] = self.transit_during_rainfall(raw_dataset)
        dataset[FeatureName.HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL] = self.transit_heavy_during_rainfall(raw_dataset)

        dataset[FeatureName.CRACK_SEVERITY] = self.array_mean(raw_dataset[RawFeatureName.CRACK.value])
        dataset[FeatureName.POTHOLE_SEVERITY] = self.array_sum(raw_dataset[RawFeatureName.POTHOLE.value])

        return dataset
