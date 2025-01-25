from pgmodel.dataset.generator.ind_generator import IndependentGenerator
import numpy as np
from datetime import date


class SeasonalGenerator(IndependentGenerator):

    def __init__(self, mean_value, magnitude, period: int = 365, phi = 181, **kwargs):
        super().__init__(**kwargs)

        self.period = period
        self.phi = phi
        self.mean_value = mean_value
        self.magnitude = magnitude

    def __modulation(self, timestamp: date) -> float:
        return np.sin(2 * np.pi / self.period * (int(timestamp.strftime("%j")) - self.phi))

    def generate_next_value(self, previous_value, timestamp: date, **kwargs):

        modulation = self.__modulation(timestamp)

        return self.magnitude * modulation + self.mean_value + np.random.uniform(-self.max_change, self.max_change)
