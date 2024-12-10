import pandas as pd
import numpy as np


class DerivedDataComputer:

    def subzeroTemperatureMean(self, temperature: np.ndarray) -> float:
        return temperature[temperature < 0].mean(axis=0)

    def temperatureMean(self, temperature: np.ndarray) -> float:
        return temperature.mean(axis=0)

    def humidityMean(self, humidity: np.ndarray) -> float:
        return humidity.mean(axis=0)

    def rainTotal(self, rain: np.ndarray) -> float:
        return rain.sum(axis=0)
