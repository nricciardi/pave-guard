import math
from datetime import datetime, timedelta

import pandas as pd
import numpy as np
from pandas import DatetimeIndex

from pgmodel.constants import FeatureName, RawFeatureName, M

class Preprocessor:

    def subzero_temperature_mean(self, temperatures: np.ndarray, weights: np.ndarray | None) -> float:
        indexes = temperatures < 0
        temperatures = temperatures[temperatures < 0]
        weights = weights[indexes]
        if temperatures.size == 0:
            return 0
        return self.array_mean(temperatures, weights)

    def array_mean(self, array: np.ndarray, weights: np.ndarray | None) -> float:
        if weights is None:
            weights = np.ones_like(array)
        valid_indices = ~np.isnan(array)
        array = array[valid_indices]
        weights = weights[valid_indices]
        if weights.sum() == 0:
            return np.nan
        else:
            return np.average(array, weights=weights)

    def array_sum(self, array: np.ndarray, weight: np.ndarray | None) -> float:
        if weight is None:
            weight = np.ones_like(array)
        valid_indices = ~np.isnan(array)
        array = array[valid_indices]
        weight = weight[valid_indices]
        return np.sum(array * weight)

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
                  storm_lower_bound: float = 10.) -> int:

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
        if is_raining not in df.columns:
            return 0
        df = df[df[is_raining] == 1]
        return self.array_count(
            df[is_raining]
        )

    def transit_heavy_during_rainfall(self, df: pd.DataFrame, is_raining: str = FeatureName.IS_RAINING.value,
                              length_name: str = RawFeatureName.TRANSIT_LENGTH.value) -> int:

        df = df[pd.notna(df[length_name])]
        df = df[self.is_vehicle_heavy(df[length_name])]
        if is_raining not in df.columns:
            return 0
        df = df[df[is_raining] == 1]
        return self.array_count(
            df[is_raining]
        )

    def is_raining_at_time(self, data: np.ndarray, timestamp: datetime, delta: timedelta = timedelta(minutes=10)):
        return ((data >= timestamp - delta) &
                (data <= timestamp + delta)).any()

    def is_vehicle_heavy(self, vehicle_length: float) -> bool:
        return vehicle_length >= 7.5

    def is_row_to_process(self, row: pd.Series, feature_name: str) -> bool:
        is_crack_present = pd.notna(row[feature_name])
        return is_crack_present

    @staticmethod
    def is_road_in_range(road_lat: float, road_lon: float, lat: float, lon: float) -> bool:
        modulation = Preprocessor.compute_modulation(road_lat, road_lon, lat, lon)
        return modulation > 0
    
    @staticmethod
    def compute_modulation(road_lat: float, road_lon: float, lat: float, lon: float) -> float:
        # Degrees to meters
        lat_diff_meters = (road_lat - lat) * 111320
        lon_diff_meters = (road_lon - lon) * 40075000 * np.cos(np.radians(lat)) / 360
        distance = np.sqrt(lat_diff_meters ** 2 + lon_diff_meters ** 2)
        return max(0, 1 - distance / M)
    
    @staticmethod
    # Supposed ids = {"id": {"latitude": float, "longitude": float}}
    def get_modulated_ids(ids: dict[str, dict[str, float]], location_lat: float, location_lon: float) -> dict[str, float]:
        ids_to_ret = {
            static_guard_id: Preprocessor.compute_modulation(location_lat, location_lon, lat_long["latitude"], lat_long["longitude"])
            for static_guard_id, lat_long in ids.items()
        }

        return ids_to_ret

    def process(self, raw_dataset: pd.DataFrame, location: dict[str, float], maintenances: list[dict],
                consecutive_measures_only: bool = False, num_final_rows: int = 0) -> pd.DataFrame:

        index_list_crack = []
        index_list_pothole = []
        var_tel_lon = "longitude"
        var_tel_lat = "latitude"
        location_lon = location["longitude"]
        location_lat = location["latitude"]
        raw_dataset.loc[:, 'modulation'] = raw_dataset.apply(
            lambda row: self.compute_modulation(location_lat, location_lon, row[var_tel_lat], row[var_tel_lon]), axis=1
            )
        raw_dataset = raw_dataset[raw_dataset["modulation"] != 0]
        # Group by day and process each group
        grouped = raw_dataset.groupby(raw_dataset.index.date)
        for day, group in grouped:
            non_null_indices_crack = group[group[RawFeatureName.CRACK.value].notnull()].index
            non_null_indices_pothole = group[group[RawFeatureName.POTHOLE.value].notnull()].index
            if RawFeatureName.CRACK.value in group and not non_null_indices_crack.empty:
                index_list_crack.append(non_null_indices_crack[0])
                first_occurrence_index = non_null_indices_crack[0]
                mean_crack_severity = group[RawFeatureName.CRACK.value].mean()
                to_add = group[group[RawFeatureName.CRACK.value].notna()].index.difference([first_occurrence_index])
                raw_dataset.loc[to_add] = np.nan
                raw_dataset.at[first_occurrence_index, RawFeatureName.CRACK.value] = mean_crack_severity
            if RawFeatureName.POTHOLE.value in group and not non_null_indices_pothole.empty:
                index_list_pothole.append(non_null_indices_pothole[0])
                first_occurrence_index = non_null_indices_pothole[0]
                mean_crack_pothole = group[RawFeatureName.POTHOLE.value].mean()
                to_add = group[group[RawFeatureName.POTHOLE.value].notna()].index.difference([first_occurrence_index])
                raw_dataset.loc[to_add] = np.nan
                raw_dataset.at[first_occurrence_index, RawFeatureName.POTHOLE.value] = mean_crack_pothole

        raw_dataset = raw_dataset.dropna(how='all')
        # Add maintenance info
        raw_dataset = raw_dataset.assign(
        maintenance=raw_dataset.apply(
            lambda row: 1 if any(
                maintenance['date'].date() == row.name.date() for maintenance in maintenances
                ) else 0, axis=1
            )
        )
        rainfall_indices = raw_dataset.loc[~raw_dataset[RawFeatureName.RAINFALL.value].isna()].index
        raw_dataset.loc[:, FeatureName.IS_RAINING.value] = raw_dataset.index.to_series().apply(
            lambda timestamp: int(self.is_raining_at_time(rainfall_indices, pd.to_datetime(timestamp)))
        )
        raw_dataset["storm"] = 0
        grouped_by_day = raw_dataset[[FeatureName.IS_RAINING.value, RawFeatureName.RAINFALL.value]].groupby(raw_dataset.index.date)
        for day, group in grouped_by_day:
            first_occurrence_index = group.index[0]
            if(group[RawFeatureName.RAINFALL.value].sum() > 10.):
                raw_dataset.loc[first_occurrence_index, "storm"] = 1

        return self.partition_and_process(raw_dataset, index_list_crack, index_list_pothole, consecutive_measures_only=consecutive_measures_only, num_final_rows=num_final_rows)


    def partition_and_process(self, raw_dataset: pd.DataFrame, index_list_crack: list, index_list_pothole: list,
                              consecutive_measures_only: bool = True, num_final_rows: int = 0) -> pd.DataFrame:

        crack_rows = []
        pothole_rows = []

        m_i = 2
        m_j = 2
        df_len = (len(index_list_crack) + len(index_list_pothole))
        if num_final_rows > 0:
            val = math.sqrt(
                df_len*(df_len - 1) / (2*num_final_rows)
            )
            m_i = max(int(val), 1)
            m_j = max(int(val), 1)
        processed = 0

        for index_list, feature_name in ([index_list_crack, RawFeatureName.CRACK.value], [index_list_pothole, RawFeatureName.POTHOLE.value]):
            for i in range(0, len(index_list) - 1):
                if i % m_i != 0 and not consecutive_measures_only:
                    continue
                # print(f"Processing... {processed * 100/num_final_rows:.2f}%")
                index = index_list[i]
                row = raw_dataset.loc[index]
                if not self.is_row_to_process(row, feature_name):
                    continue
                # Set the first row, I look for another one
                for j in range(i+1, i+2 if consecutive_measures_only else len(index_list)):
                    if not consecutive_measures_only:
                        if j % m_j != 0:
                            continue
                    print(f"Processing... {processed * 100 / num_final_rows:.2f}%")
                    last_index = index_list[j]
                    last_row = raw_dataset.loc[last_index]

                    if feature_name == RawFeatureName.CRACK.value and row[RawFeatureName.CRACK.value] >= last_row[RawFeatureName.CRACK.value]:
                        continue
                    if feature_name == RawFeatureName.POTHOLE.value and row[RawFeatureName.POTHOLE.value] >= last_row[RawFeatureName.POTHOLE.value]:
                        continue
                    
                    try:
                        if isinstance(last_row['maintenance'], pd.Series):
                            if last_row["maintenance"].iloc[0] == 1:
                                break
                        elif last_row['maintenance'] == 1:
                            break
                        if not self.is_row_to_process(last_row, feature_name):
                            continue

                    except Exception as e:
                        print(last_row)
                        print(last_row['maintenance'])
                        print(feature_name)

                        raise e

                    processed_row = self.process_single_row(raw_dataset.loc[index:last_index])
                    processed += 2

                    if feature_name == RawFeatureName.CRACK.value:
                        processed_row[FeatureName.CRACK_SEVERITY.value] = row[RawFeatureName.CRACK.value]
                        processed_row[FeatureName.TARGET.value] = last_row[RawFeatureName.CRACK.value]
                        crack_rows.append(processed_row.iloc[0])

                    else:
                        processed_row[FeatureName.POTHOLE_SEVERITY.value] = row[RawFeatureName.POTHOLE.value]
                        processed_row[FeatureName.TARGET.value] = last_row[RawFeatureName.POTHOLE.value]
                        pothole_rows.append(processed_row.iloc[0])

        crack_df = pd.DataFrame(crack_rows)
        poth_df = pd.DataFrame(pothole_rows)
        return crack_df, poth_df

    def process_single_row(self, raw_dataset: pd.DataFrame) -> pd.DataFrame:

        dataset = pd.DataFrame(index=[0])
        weights = raw_dataset["modulation"]
        if weights.sum() == 0:
            weights = np.ones_like(weights)
        else:
            weights = weights / weights.sum()

        if RawFeatureName.TEMPERATURE.value in raw_dataset:
            dataset[FeatureName.TEMPERATURE_MEAN.value] = self.array_mean(raw_dataset[RawFeatureName.TEMPERATURE.value], weights)
            dataset[FeatureName.SUBZERO_TEMPERATURE_MEAN.value] = self.subzero_temperature_mean(raw_dataset[RawFeatureName.TEMPERATURE.value],
                                                                                          weights)
            dataset[FeatureName.DELTA_TEMPERATURE.value] = self.get_delta_temperatures(raw_dataset[RawFeatureName.TEMPERATURE.value])
        else:
            dataset[FeatureName.TEMPERATURE_MEAN.value] = 0
            dataset[FeatureName.SUBZERO_TEMPERATURE_MEAN.value] = 0
            dataset[FeatureName.DELTA_TEMPERATURE.value] = 0
            
        if RawFeatureName.HUMIDITY.value in raw_dataset:
            dataset[FeatureName.HUMIDITY_MEAN.value] = self.array_mean(raw_dataset[RawFeatureName.HUMIDITY.value], weights)
        else:
            dataset[FeatureName.HUMIDITY_MEAN.value] = 0
            
        dataset[FeatureName.DAYS.value] = self.get_days(raw_dataset.index)
        
        if RawFeatureName.RAINFALL.value in raw_dataset:
            dataset[FeatureName.RAINFALL_QUANTITY.value] = self.array_count(raw_dataset[RawFeatureName.RAINFALL.value]) * 0.3
            dataset[FeatureName.STORM_TOTAL.value] = self.array_count(raw_dataset[raw_dataset["storm"] == 1])

        else:
            dataset[FeatureName.RAINFALL_QUANTITY.value] = 0
            dataset[FeatureName.STORM_TOTAL.value] = 0
            raw_dataset[FeatureName.IS_RAINING.value] = 0
            
        if RawFeatureName.TRANSIT_TIME.value in raw_dataset:
            dataset[FeatureName.TRANSIT_TOTAL.value] = self.array_count(raw_dataset[RawFeatureName.TRANSIT_TIME.value])
        else:
            dataset[FeatureName.TRANSIT_TOTAL.value] = 0

        if RawFeatureName.TRANSIT_LENGTH.value in raw_dataset:
            heavy_transit: np.ndarray = np.array([1 for length in raw_dataset[RawFeatureName.TRANSIT_LENGTH.value] if self.is_vehicle_heavy(length)])
        else:
            heavy_transit = np.array([])

        dataset[FeatureName.HEAVY_VEHICLES_TRANSIT_TOTAL.value] = self.array_count(heavy_transit)
        dataset[FeatureName.TRANSIT_DURING_RAINFALL.value] = self.transit_during_rainfall(raw_dataset)
        dataset[FeatureName.HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL.value] = self.transit_heavy_during_rainfall(raw_dataset)

        if RawFeatureName.CRACK.value in raw_dataset:
            candidate = self.array_mean(raw_dataset[RawFeatureName.CRACK.value], weights) if raw_dataset[RawFeatureName.CRACK.value].size > 0 else 0
            if candidate is np.nan:
                candidate = 0
            dataset[FeatureName.CRACK_SEVERITY.value] = candidate
        if RawFeatureName.POTHOLE.value in raw_dataset:
            candidate = self.array_mean(raw_dataset[RawFeatureName.POTHOLE.value], weights) if raw_dataset[RawFeatureName.POTHOLE.value].size > 0 else 0
            if candidate is np.nan:
                candidate = 0
            dataset[FeatureName.POTHOLE_SEVERITY.value] = candidate

        dataset = dataset.drop(columns=[FeatureName.SUBZERO_TEMPERATURE_MEAN.value])      # TODO

        return dataset
