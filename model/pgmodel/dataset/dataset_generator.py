from datetime import date, timedelta
from typing import Dict
import os
import numpy as np
import pandas as pd
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))
from pgmodel.dataset.generator.crack_generator import CrackGenerator
from pgmodel.dataset.generator.generator import Generator
from pgmodel.dataset.generator.seasonal_generator import SeasonalGenerator
from pgmodel.dataset.generator.rainfall_generator import RainfallGenerator
from pgmodel.constants import RawFeatureName, DataframeKey, M
from pgmodel.dataset.generator.transit_generator import TransitGenerator


possible_dynamic_centers: list[tuple[float, float]] = [
    (44.627650, 10.949806),
    (44.629460, 10.946722),
    (44.631892, 10.947128),
    (44.629943, 10.950502)
]


class DatasetGenerator:

    @classmethod
    def generate_static_guard_telemetries_data(cls, n_days = 30, from_date = date.today()):
        to_date = date.today() + timedelta(days=n_days)

        generators = {}
        generators[DataframeKey.TEMPERATURE.value] = SeasonalGenerator(magnitude=25, min_value=-20, max_value=40,
                                                                         mean_value=18, seed_value=10,
                                                                         var_name=RawFeatureName.TEMPERATURE.value)
        generators[DataframeKey.HUMIDITY.value] = SeasonalGenerator(mean_value=50, magnitude=50,
                                                                      var_name=RawFeatureName.HUMIDITY.value)

        humidities = []
        for i in range(0, n_days * 48):
            humidities.append(generators[RawFeatureName.HUMIDITY.value].generate_next_value(
                humidities[-1] if len(humidities) > 0 else 0, from_date.today().__add__(timedelta(days=i))))
        humidity_mean = sum(humidities) / len(humidities)

        generators[DataframeKey.RAINFALL.value] = (
            RainfallGenerator(humidity_mean=humidity_mean, var_name=RawFeatureName.RAINFALL.value)
        )

        generators[DataframeKey.TRANSIT.value] = TransitGenerator(speed_name=RawFeatureName.TRANSIT_VELOCITY.value,
                                                 length_name=RawFeatureName.TRANSIT_LENGTH.value,
                                                 time_name=RawFeatureName.TRANSIT_TIME.value)

        dfs = DatasetGenerator.generate_dfs(from_date, to_date, generators)

        return dfs

    @classmethod
    def generate_dynamic_guard_telemetries_data(cls, n_days=30, from_date=date.today()):
        to_date = date.today() + timedelta(days=n_days)

        generators = {}

        generators[DataframeKey.CRACK.value] = CrackGenerator(var_name=RawFeatureName.CRACK.value)
        generators[DataframeKey.POTHOLE.value] = CrackGenerator(max_cracks=5, cracks_gravity_average=40,
                                                                  probability_detection=0.2,
                                                                  var_name=RawFeatureName.POTHOLE.value)

        dfs = DatasetGenerator.generate_dfs(from_date, to_date, generators)
        M_coord = M / 111000
        for df in dfs.values():
            latitude = np.random.choice([center[0] for center in possible_dynamic_centers])
            longitude = np.random.choice([center[1] for center in possible_dynamic_centers])
            df["latitude"] = np.random.uniform(latitude - M_coord, latitude + M_coord, len(df))
            df["longitude"] = np.random.uniform(longitude - M_coord, longitude + M_coord, len(df))

        return dfs

    @classmethod
    def generate_dfs(cls, from_date: date, to_date: date, generators: Dict[str, Generator], **kwargs) -> dict[str, pd.DataFrame]:

        dfs = {}

        for name, generator in generators.items():
            df: pd.DataFrame = generator.generate(from_date=from_date, to_date=to_date, **kwargs)
            dfs[name] = df
        
        return dfs

    @classmethod
    def telemetries_to_dataframe(cls, telemetries: list[pd.DataFrame]) -> pd.DataFrame:
        
        # Gets out all timestamps
        for df in telemetries:
            df['timestamp'] = pd.to_datetime(df['timestamp'])
        timestamps = pd.concat([df['timestamp'] for df in telemetries]).drop_duplicates().sort_values()
        result_df = pd.DataFrame({'timestamp': timestamps})
        
        # Merges all dataframes
        for df in telemetries:
            result_df = result_df.merge(df, on='timestamp', how='left')
            if "latitude_x" in result_df.columns:
                result_df["latitude"] = result_df["latitude_x"].fillna(result_df["latitude_y"])
                result_df = result_df.drop(columns=["latitude_x", "latitude_y"])
            if "longitude_x" in result_df.columns:
                result_df["longitude"] = result_df["longitude_x"].fillna(result_df["longitude_y"])
                result_df = result_df.drop(columns=["longitude_x", "longitude_y"])
            if "metadata_deviceId_x" in result_df.columns:
                result_df["deviceId"] = result_df["metadata_deviceId_x"].fillna(result_df["metadata_deviceId_y"])
                result_df = result_df.drop(columns=["metadata_deviceId_x", "metadata_deviceId_y"])
            if "modulation_x" in result_df.columns:
                result_df["modulation"] = result_df["modulation_x"].fillna(result_df["modulation_y"])
                result_df = result_df.drop(columns=["modulation_x", "modulation_y"])

        # Rename columns to match RawFeatureName values
        rename_dict = {
            'temperature': RawFeatureName.TEMPERATURE.value,
            'humidity': RawFeatureName.HUMIDITY.value,
            'mm': RawFeatureName.RAINFALL.value,
            'velocity': RawFeatureName.TRANSIT_VELOCITY.value,
            'length': RawFeatureName.TRANSIT_LENGTH.value,
            'transitTime': RawFeatureName.TRANSIT_TIME.value,
            'crack': RawFeatureName.CRACK.value,
            'pothole': RawFeatureName.POTHOLE.value
        }
        result_df.rename(columns=rename_dict, inplace=True)
        result_df.set_index('timestamp', inplace=True)
        return result_df
        

    @classmethod
    def csv_to_dataframe(cls, input_dir: str, output_name: str = "dataset", features: list[str] = None, save_to_csv: str | None = None) -> pd.DataFrame:
        if features is None:
            features = [feat for feat in RawFeatureName]

        dfs = {
            feature: pd.read_csv(os.path.join(input_dir, f'{feature.value}.csv')) for feature in features
        }

        for key in dfs:
            dfs[key]['timestamp'] = pd.to_datetime(dfs[key]['timestamp'])

        timestamps = pd.concat([df['timestamp'] for df in dfs.values()]).drop_duplicates().sort_values()

        result_df = pd.DataFrame({'timestamp': timestamps})
        for key, df in dfs.items():
            result_df = result_df.merge(df, on='timestamp', how='left')

        result_df.set_index('timestamp', inplace=True)

        if save_to_csv is not None:
            result_df.to_csv(os.path.join(save_to_csv, f'{output_name}.csv'), index_label="timestamp")

        return result_df
