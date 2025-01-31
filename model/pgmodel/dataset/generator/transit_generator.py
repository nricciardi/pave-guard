from pgmodel.dataset.generator.ind_generator import IndependentGenerator
from pgmodel.dataset.generator.rainfall_generator import generate_aggregate_timespace
from typing import Callable
from datetime import date
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

    def __init__(self, speed_name = "speed", length_name = "length", time_name = "time", timestamp_callback: Callable[[date, float, float], np.ndarray] = generate_aggregate_timespace,
                 average_transit_in_a_day: int = 500, min_transits_in_a_day: int = 100,
                 max_transits_in_a_day: int = 2000, max_speed_change: float = 20, **kwargs):
        super().__init__(timestamp_callback=timestamp_callback, values_in_a_day=average_transit_in_a_day, min_value=min_transits_in_a_day, max_value=max_transits_in_a_day, **kwargs)

        self.speed_name = speed_name
        self.length_name = length_name
        self.time_name = time_name
        self.timestamp_callback = timestamp_callback
        self.max_speed_change = max_speed_change

    def generate_next_value(self, previous_value, timestamp: date, **kwargs) -> Transit:
        length = np.random.uniform(3, 15)
        speed = previous_value + np.random.uniform(-self.max_speed_change, self.max_speed_change)
        speed = speed if speed > 20 else 20
        time = Transit.get_time(length, speed)
        return Transit(length, time, speed)

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.DataFrame:
        
        new_timestamps = self.timestamp_callback(day, 0.95, 0.3, 15, 5, 0.99)
        previous_value = 40.
        values: list[Transit] = []
        for _ in range(0, new_timestamps.size):
            new_value: Transit = self.generate_next_value(previous_value, day)
            previous_value = new_value.speed
            values.append(new_value)
        data = {
            'timestamp': new_timestamps,
            self.speed_name: [value.speed for value in values],
            self.time_name: [value.time for value in values],
            self.length_name: [value.length for value in values]
        }
        return pd.DataFrame(data)

    def generate(self, from_date: date, to_date: date, seed_value = None, **kwargs) -> pd.DataFrame:
        to_return = super().generate(from_date, to_date, seed_value, **kwargs)
        return to_return
