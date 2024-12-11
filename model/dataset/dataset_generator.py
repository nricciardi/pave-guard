from calendar import month
from datetime import date, timedelta
from typing import Dict
import os
import pandas as pd

from dataset.generator import Generator
from dataset.ind_generator import IndependentGenerator
from dataset.seasonal_generator import SeasonalGenerator


class DatasetGenerator:

    @classmethod
    def generate_dataset(cls, output_dir: str, from_date: date, to_date: date, generators: Dict[str, Generator], **kwargs):

        for name, generator in generators.items():
            series: pd.Series = generator.generate(from_date=from_date, to_date=to_date, **kwargs)
            series.to_csv(os.path.join(output_dir, f"{name}.csv"), index_label="timestamp", header=[name])



if __name__ == '__main__':

    from_date = date.today()
    to_date = date.today() + timedelta(days=30)
    generators = {
        "temperature": SeasonalGenerator(magnitude=25, min_value=-20, max_value=40, mean_value=18, seed_value=10),
        "humidity": SeasonalGenerator(mean_value=50, magnitude=50),
        "rainfall": SeasonalGenerator(magnitude=500, max_value=2000, mean_value=500),
        # "transit": TODO,
        # "crack": TODO,
        # "photole": TODO,
    }

    DatasetGenerator.generate_dataset("/home/nricciardi/Repositories/pave-guard/model/dataset", from_date, to_date, generators)