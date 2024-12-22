import pandas as pd
import numpy as np

from model.constants import FeatureName, RawFeatureName


class Preprocessor:

    def subzeroTemperatureMean(self, temperatures: np.ndarray) -> float:
        return self.arrayMean(temperatures[temperatures < 0])

    def arrayMean(self, array: np.ndarray) -> float:
        array = array[np.isnan(array)]
        return array.mean(axis=0)

    def rainTotal(self, rain: np.ndarray) -> float:
        return rain.sum(axis=0)

    def getDays(self, days: np.ndarray) -> int:
        days = pd.to_datetime(days)
        return (
            (days.max() - days.min()).days
        )


    def process(self, raw_dataset: pd.DataFrame) -> pd.DataFrame:

        dataset = pd.DataFrame()

        dataset[FeatureName.TEMPERATURE_MEAN] = self.arrayMean(raw_dataset[RawFeatureName.TEMPERATURE])
        dataset[FeatureName.HUMIDITY_MEAN] = self.arrayMean(raw_dataset[RawFeatureName.HUMIDITY])
        dataset[FeatureName.DAYS] = self.getDays(raw_dataset.index)

        # TODO

        return dataset
