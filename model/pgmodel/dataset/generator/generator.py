from datetime import date, timedelta, datetime
import numpy as np
from abc import ABC, abstractmethod
import pandas as pd


class Generator(ABC):

    def __init__(self, seed_value = None):
        self.seed_value = seed_value

    @abstractmethod
    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, df = None, **kwargs) -> pd.DataFrame:
        raise NotImplemented

    def generate(self, from_date: date, to_date: date, seed_value = None, df = None, **kwargs) -> pd.DataFrame:

        data = pd.DataFrame()
        previous_day_data = None

        current_date = from_date

        while current_date <= to_date:

            day_data = self.generate_day_data(day=current_date, previous_day_data=previous_day_data, seed_value=seed_value, df=df, **kwargs)
            if not day_data.empty:
                data = pd.concat([data, day_data]) if not data.empty else day_data

            previous_day_data = day_data
            current_date += timedelta(days=1)

        return data

    @staticmethod
    def generate_linspace_timestamp(day: date, n_points: int = 100) -> np.ndarray:
        start_time = datetime.combine(day, datetime.min.time())
        end_time = start_time + timedelta(days=1) - timedelta(seconds=1)

        timestamps = np.linspace(start_time.timestamp(), end_time.timestamp(), n_points)
        timestamps = pd.to_datetime(timestamps, unit='s')

        return timestamps.floor("s")
