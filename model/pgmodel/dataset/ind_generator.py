from datetime import date
from typing import Callable
import pandas as pd
import numpy as np
from pgmodel.dataset.generator import Generator
from abc import ABC, abstractmethod


class IndependentGenerator(Generator, ABC):

    def __init__(self, timestamp_callback: Callable[[date, int], np.ndarray] = Generator.generate_linspace_timestamp,
                 values_in_a_day: int = 48, min_value: int = 0, max_value: int = 100, max_change: float = 5, **kwargs):

        super().__init__(**kwargs)

        self.timestamp_callback = timestamp_callback
        self.values_in_a_day = values_in_a_day
        self.min_value = min_value
        self.max_value = max_value
        self.max_change = max_change

    @abstractmethod
    def generate_next_value(self, previous_value, timestamp: date, **kwargs):
        raise NotImplemented

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.Series:

        timestamps = self.timestamp_callback(day, self.values_in_a_day)

        values = [np.random.uniform(self.min_value, self.max_value)] if previous_day_data is None else [previous_day_data.iloc[-1]]
        for index in range(0, self.values_in_a_day - 1):

            timestamp = timestamps[index]

            next_value = self.generate_next_value(values[-1], timestamp, **kwargs)
            values.append(
                max(min(next_value, self.max_value), self.min_value)
            )

        return pd.Series(values, index=timestamps)

