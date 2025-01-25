from datetime import date, time, datetime, timedelta
from pgmodel.dataset.generator.generator import Generator
from abc import ABC, abstractmethod
from typing import Callable
import numpy as np
import pandas as pd


def generate_aggregate_timespace(day: date, phenomenon_probability: float,
                                 phenomenon_aggressivity: float,
                                 phenomenon_duration_average_minutes: float = 80,
                                 phenomenon_duration_variance: float = 50,
                                 alpha: float = 0.9) -> np.ndarray:

    i = 0
    timestamps_total = None
    start_datetime = datetime.combine(day, datetime.min.time())

    while phenomenon_probability * (alpha ** i) >= np.random.uniform(0, 1):

        if phenomenon_probability >= np.random.uniform(0, 1):
            i += 1
            continue

        duration = np.random.normal(loc=phenomenon_duration_average_minutes * (1 + phenomenon_aggressivity),
                                    scale=phenomenon_duration_variance)
        duration = duration if duration >= 0 else 0
        if duration == 0:
            i += 1
            continue

        start_time = start_datetime + timedelta(minutes=np.random.uniform(0, 24 * 60 - duration))
        end_time = start_time + timedelta(minutes=duration)

        n_points = 10
        while phenomenon_aggressivity >= np.random.uniform(0, 1):
            n_points += 10

        timestamps = np.linspace(start_time.timestamp(), end_time.timestamp(), n_points)
        timestamps = pd.to_datetime(timestamps, unit='s')
        timestamps = timestamps.floor("s")
        timestamps_total = np.concatenate((timestamps_total, timestamps)) if timestamps_total is not None else timestamps

        i += 1
        start_datetime = start_time

    return pd.Series() if timestamps_total is None else timestamps_total


class RainfallGenerator(Generator, ABC):

    def __init__(self, timestamp_callback: Callable[[date, float, float], np.ndarray] = generate_aggregate_timespace,
                 humidity_mean: float = 50, rain_aggressivity_mean: float = 0.5, rain_duration_average_minutes: float = 70,
                 rain_duration_variance: float = 30, rain_click_measure: float = 3, **kwargs):

        super().__init__(**kwargs)

        self.timestamp_callback = timestamp_callback
        self.humidity_mean = humidity_mean
        self.rain_aggressivity_mean = rain_aggressivity_mean
        self.rain_duration_average_minutes = rain_duration_average_minutes
        self.rain_duration_variance = rain_duration_variance
        self.rain_click_measure = rain_click_measure

    def rain_probability(self, day: date) -> float:
        prob =  self.humidity_mean / 100
        actual_season = self.get_season(day)
        prob *= (
            1.75 if actual_season == "Winter" else
            0.75 if actual_season == "Summer" else
            1.20 if actual_season == "Autumn" else
            1.00
        )
        return prob

    def generate_day_data(self, day: date, previous_day_data: np.ndarray | None = None, **kwargs) -> pd.Series:

        timestamps = self.timestamp_callback(day, self.rain_probability(day), np.random.uniform(0.01, 1.))
        values = []
        for _ in range(0, timestamps.size):
            values.append(self.rain_click_measure)

        return pd.Series(values, index=timestamps)

    @staticmethod
    def get_season(date_obj):
        year = date_obj.year
        spring = date(year, 3, 21)
        summer = date(year, 6, 21)
        autumn = date(year, 9, 21)
        winter = date(year, 12, 21)

        if spring <= date_obj < summer:
            return "Spring"
        elif summer <= date_obj < autumn:
            return "Summer"
        elif autumn <= date_obj < winter:
            return "Autumn"
        else:
            return "Winter"