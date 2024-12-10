from datetime import date
from typing import Callable
import pandas as pd
import numpy as np
from dataset.generator import Generator


class IndependentSeasonalitySingleValueGenerator(Generator):

    def __init__(self, timestamp_callback: Callable[[date, int], np.ndarray] = Generator.generate_linspace_timestamp,
                 values_in_a_day: int = 48, min_value: int = 0, max_value: int = 100, max_change: float = 5,):

        self.timestamp_callback = timestamp_callback
        self.values_in_a_day = values_in_a_day
        self.min_value = min_value
        self.max_value = max_value
        self.max_change = max_change

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.Series:

        values = [np.random.uniform(self.min_value, self.max_value)] if previous_day_data is None else [previous_day_data.iloc[-1]]
        for _ in range(0, self.values_in_a_day - 1):
            next_temp = values[-1] + np.random.uniform(-self.max_change, self.max_change)
            values.append(
                max(min(next_temp, self.max_value), self.min_value)
            )

        return pd.Series(values, index=self.timestamp_callback(day, self.values_in_a_day))

