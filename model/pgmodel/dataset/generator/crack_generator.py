from datetime import date, datetime

import pandas as pd
import numpy as np

from pgmodel.dataset.generator.ind_generator import IndependentGenerator
from typing import Callable


def random_timespace(start: date, n_points: int) -> np.ndarray:
    start_datetime = datetime.combine(start, datetime.min.time())
    end_datetime = datetime.combine(start, datetime.max.time())

    random_timestamps = [
        datetime.fromtimestamp(
            np.random.randint(int(start_datetime.timestamp()), int(end_datetime.timestamp()))
        )
        for _ in range(n_points)
    ]

    return np.array(sorted(random_timestamps))


class CrackGenerator(IndependentGenerator):

    def __init__(self, timespace_callback: Callable[[date, int], np.ndarray] = random_timespace,
                 min_cracks: int = 1, max_cracks: int = 20, cracks_gravity_average: int = 30,
                 probability_detection: float = 0.5, max_change: float = 30,
                 cracks_gravity_deviation=20, **kwargs):

        super().__init__(timestamp_callback=timespace_callback, max_change=max_change, **kwargs)

        self.num_cracks = int(np.random.uniform(min_cracks, max_cracks))
        self.cracks = [
            max(1, min(100, int(np.random.normal(loc=cracks_gravity_average, scale=cracks_gravity_deviation))))
            for _ in range(0, self.num_cracks)
        ]
        self.probability_detection = probability_detection

    def generate_next_value(self, previous_value, timestamp: date, **kwargs) -> int:
        detected = np.random.choice(self.cracks)
        return int(max(0, min(100, detected + np.random.uniform(-self.max_change, self.max_change))))

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.Series:
        timestamps = random_timespace(day, int(np.random.standard_normal() * 100 * self.num_cracks * self.probability_detection))
        values = []
        for timestamp in timestamps:
            values.append(self.generate_next_value(0, timestamp))
        return pd.Series(values, index=timestamps)
