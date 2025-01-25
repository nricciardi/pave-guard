from datetime import date, timedelta
from typing import Dict
import os
import pandas as pd
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))
from pgmodel.dataset.generator.crack_generator import CrackGenerator
from pgmodel.dataset.generator.generator import Generator
from pgmodel.dataset.generator.seasonal_generator import SeasonalGenerator
from pgmodel.dataset.generator.rainfall_generator import RainfallGenerator
from pgmodel.constants import RawFeatureName
from pgmodel.dataset.generator.transit_generator import TransitGenerator





class DatasetGenerator:

    @classmethod
    def generate_dataset(cls, from_date: date, to_date: date, generators: Dict[RawFeatureName, Generator], **kwargs) -> dict[RawFeatureName, pd.DataFrame]:

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


if __name__ == '__main__':

    n_days = 30
    from_date = date.today()
    to_date = date.today() + timedelta(days=n_days)

    generators = {}
    generators[RawFeatureName.TEMPERATURE] = SeasonalGenerator(magnitude=25, min_value=-20, max_value=40, mean_value=18, seed_value=10, var_name=RawFeatureName.TEMPERATURE)
    generators[RawFeatureName.HUMIDITY] = SeasonalGenerator(mean_value=50, magnitude=50, var_name=RawFeatureName.HUMIDITY)

    humidities = []
    for i in range(0, n_days * 48):
        humidities.append(generators[RawFeatureName.HUMIDITY].generate_next_value(humidities[-1] if len(humidities) > 0 else 0, from_date.today().__add__(timedelta(days=i))))
    humidity_mean = sum(humidities) / len(humidities)

    generators[RawFeatureName.RAINFALL] = (
        RainfallGenerator(humidity_mean=humidity_mean, var_name=RawFeatureName.RAINFALL)
    )

    generators[RawFeatureName.TRANSIT_LENGTH] = TransitGenerator(speed_name=RawFeatureName.TRANSIT_VELOCITY, length_name=RawFeatureName.TRANSIT_LENGTH, time_name=RawFeatureName.TRANSIT_TIME)

    generators[RawFeatureName.CRACK] = CrackGenerator(var_name=RawFeatureName.CRACK)
    generators[RawFeatureName.POTHOLE] = CrackGenerator(max_cracks=5, cracks_gravity_average=40, probability_detection=0.2, var_name=RawFeatureName.POTHOLE)


    dfs = DatasetGenerator.generate_dataset(from_date, to_date, generators)
    print(dfs)