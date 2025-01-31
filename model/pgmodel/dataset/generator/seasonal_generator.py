from pgmodel.dataset.generator.ind_generator import IndependentGenerator
import numpy as np
from datetime import date


class SeasonalGenerator(IndependentGenerator):

    def __init__(self, mean_value, magnitude, period: int = 365, phi = 182, **kwargs):
        super().__init__(**kwargs)

        self.period = period
        self.phi = phi
        self.mean_value = mean_value
        self.magnitude = magnitude

    def __modulation(self, timestamp: date) -> float:
        day_of_year = int(timestamp.strftime("%j"))
        return np.sin(2 * np.pi / self.period * (day_of_year - self.phi))

    def generate_next_value(self, previous_value, timestamp: date, df = None, **kwargs):

        modulation = self.__modulation(timestamp)

        next_value = self.magnitude * modulation + self.mean_value + np.random.uniform(-self.max_change, self.max_change)
        next_value = max(self.min_value, min(self.max_value, next_value))
        return next_value
