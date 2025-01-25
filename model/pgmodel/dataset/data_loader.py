import pandas as pd
import os
from typing import Dict

from pgmodel.constants import RawFeatureName


class DataLoader:

    @classmethod
    def load_data_from_csv(self, data_dir: str, features_names: list[str]) -> Dict[str, pd.DataFrame]:
        data_dataframes = {
            fname: pd.read_csv(os.path.join(data_dir, f"{fname}.csv")) for fname in features_names
        }

        return data_dataframes



if __name__ == '__main__':

    data_dir = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/dataset/data"
    features_names: list[str] = [str(raw_feature.value) for raw_feature in list(RawFeatureName)]

    features_dataframe = DataLoader.load_data_from_csv(
        data_dir,
        features_names
    )

    print(features_names)

    print(features_dataframe["temperature"].head())