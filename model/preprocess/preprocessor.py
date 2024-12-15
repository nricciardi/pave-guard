import pandas as pd
import numpy as np

from constants import FeatureName, RawFeatureName


class Preprocessor:

    def subzeroTemperatureMean(self, temperature: np.ndarray) -> float:
        return temperature[temperature < 0].mean(axis=0)

    def temperatureMean(self, temperature: np.ndarray) -> float:
        return temperature.mean(axis=0)

    def humidityMean(self, humidity: np.ndarray) -> float:
        return humidity.mean(axis=0)

    def rainTotal(self, rain: np.ndarray) -> float:
        return rain.sum(axis=0)


    def process(self, raw_dataset: pd.DataFrame) -> pd.DataFrame:

        dataset = pd.DataFrame()

        dataset[FeatureName.TEMPERATURE_MEAN] = self.temperatureMean(raw_dataset[RawFeatureName.TEMPERATURE])
        dataset[FeatureName.HUMIDITY_MEAN] = self.temperatureMean(raw_dataset[RawFeatureName.HUMIDITY])

        # TODO

        return dataset
