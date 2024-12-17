from calendar import month
from datetime import date, timedelta
from typing import Dict
import os
import pandas as pd

from model.dataset.generator import Generator
from model.dataset.ind_generator import IndependentGenerator
from model.dataset.rainfall_generator import RainfallGenerator
from model.dataset.seasonal_generator import SeasonalGenerator
from model.dataset.rainfall_generator import RainfallGenerator
from model.constants import RawFeatureName


class DatasetGenerator:

    @classmethod
    def generate_dataset(cls, output_dir: str, from_date: date, to_date: date, generators: Dict[RawFeatureName, Generator], **kwargs):

        for name, generator in generators.items():
            series: pd.Series = generator.generate(from_date=from_date, to_date=to_date, **kwargs)
            series.to_csv(os.path.join(output_dir, f"{name.value}.csv"), index_label="timestamp", header=[name.value])



if __name__ == '__main__':

    n_days = 30
    from_date = date.today()
    to_date = date.today() + timedelta(days=n_days)

    generators = {}
    generators[RawFeatureName.TEMPERATURE] = SeasonalGenerator(magnitude=25, min_value=-20, max_value=40, mean_value=18, seed_value=10)
    generators[RawFeatureName.HUMIDITY] = SeasonalGenerator(mean_value=50, magnitude=50)

    humidities = []
    for i in range(0, n_days):
        humidities.append(generators[RawFeatureName.HUMIDITY].generate_next_value(humidities[-1] if len(humidities) > 0 else 0, from_date.today().__add__(timedelta(days=i))))

    humidity_mean = sum(humidities) / len(humidities)
    generators[RawFeatureName.RAINFALL] = (
        RainfallGenerator(magnitude=500, max_value=2000, mean_value=500, humidity_mean=humidity_mean)
    )

    # "transit": TODO,
    # "crack": TODO,
    # "photole": TODO,

    #DatasetGenerator.generate_dataset("/home/nricciardi/Repositories/pave-guard/model/dataset", from_date, to_date, generators)
    DatasetGenerator.generate_dataset(".", from_date, to_date, generators)