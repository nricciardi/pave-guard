from datetime import date

from numpy.random.bit_generator import BitGenerator

from model.dataset.seasonal_generator import SeasonalGenerator
import numpy as np

class RainfallGenerator(SeasonalGenerator):

    def __init__(self, humidity_mean: float, **kwargs):
        super().__init__(**kwargs)

        self.humidity_mean = humidity_mean

    def rain_probability(self) -> float:
        return self.humidity_mean / 100

    def generate_next_value(self, previous_value, timestamp: date, **kwargs):

        return (
                super().modulation(timestamp) * self.magnitude + np.random.uniform(-self.min_value, self.max_value) * self.rain_probability()
                if self.rain_probability() < np.random.uniform(0,1)
                else 0
        )