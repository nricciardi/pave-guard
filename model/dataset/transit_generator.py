from model.dataset.ind_generator import IndependentGenerator
from model.dataset.rainfall_generator import generate_aggregate_timespace
from typing import Callable
from datetime import date
from abc import ABC, abstractmethod
import numpy as np
import pandas as pd

class TransitGenerator(IndependentGenerator):

    def __init__(self, timestamp_callback: Callable[[date, float, float], np.ndarray] = generate_aggregate_timespace,
                 average_transit_in_a_day: int = 500, min_transits_in_a_day: int = 100,
                 max_transits_in_a_day: int = 2000, **kwargs):
        super().__init__(timestamp_callback=timestamp_callback, values_in_a_day=average_transit_in_a_day, min_value=min_transits_in_a_day, max_value=max_transits_in_a_day, **kwargs)

        self.timestamp_callback = timestamp_callback

    def generate_next_value(self, previous_value, timestamp: date, **kwargs) -> (float, float, float):
        pass

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.Series:
        # TODO
        timestamps = self.timestamp_callback()
        values = []
