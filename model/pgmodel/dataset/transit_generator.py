from pgmodel.dataset.ind_generator import IndependentGenerator
from pgmodel.dataset.rainfall_generator import generate_aggregate_timespace
from typing import Callable
from datetime import date
from abc import ABC, abstractmethod
import numpy as np
import pandas as pd

class Transit:

    def __init__(self, length: float, time: float, speed: float):
        self.length = length
        self.time = time
        self.speed = speed

    @staticmethod
    def get_time(length: float, speed: float):
        return length / speed


class TransitGenerator(IndependentGenerator):

    def __init__(self, timestamp_callback: Callable[[date, float, float], np.ndarray] = generate_aggregate_timespace,
                 average_transit_in_a_day: int = 500, min_transits_in_a_day: int = 100,
                 max_transits_in_a_day: int = 2000, max_speed_change: float = 20, **kwargs):
        super().__init__(timestamp_callback=timestamp_callback, values_in_a_day=average_transit_in_a_day, min_value=min_transits_in_a_day, max_value=max_transits_in_a_day, **kwargs)

        self.timestamp_callback = timestamp_callback
        self.max_speed_change = max_speed_change
        self.index = 0
        self.values = []
        self.timestamps = []
        self.slices = [0]
        self.slice_index = 0

    def generate_next_value(self, previous_value, timestamp: date, **kwargs) -> Transit:
        length = np.random.uniform(2.5, 5)
        speed = previous_value + np.random.uniform(-self.max_speed_change, self.max_speed_change)
        speed = speed if speed > 20 else 20
        time = Transit.get_time(length, speed)
        return Transit(length, time, speed)

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.Series:
        if self.index == 0:
            new_timestamps = self.timestamp_callback(day, 0.95, 0.3, 15, 5, 0.99)
            for timestamp in new_timestamps:
                self.timestamps.append(timestamp)
            values_index = len(self.values)
            self.slices.append(values_index)
            previous_value = 40.
            for _ in range(0, new_timestamps.size):
                new_value = self.generate_next_value(previous_value, day)
                previous_value = new_value.speed
                self.values.append(new_value)
            return pd.Series([value.speed for value in self.values[values_index:]], index=new_timestamps)

        else:
            left_value = self.slices[self.slice_index]
            self.slice_index += 1
            right_value = self.slices[self.slice_index]
            return pd.Series([value.time if self.index == 1 else value.length for value in self.values[left_value:right_value]], index=self.timestamps[left_value:right_value])

    def generate(self, from_date: date, to_date: date, seed_value = None, **kwargs) -> pd.Series:
        to_return = super().generate(from_date, to_date, seed_value, **kwargs)
        self.index += 1
        self.slice_index = 0
        return to_return
