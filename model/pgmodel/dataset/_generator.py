import math

import pandas as pd
from typing import Callable
import random

from dask.array import arctan

from _basedatagenerator import *

'''
    Tutti i nomi di features che vuoi nel .csv
    Devi creare la corrispondente funzione handler
'''
FEATURES: list[str] = [
    MEDIA_TEMPERATURA_SOTTOZERO,
    NUMERO_GIORNI,
    MEDIA_TEMPERATURA,
    MEDIA_UMIDITA,
    QTA_PIOGGIA,
    NUMERO_TEMPORALI,
    MEDIA_SBALZO_TERMICO,
    NUMERO_TRANSITI_TOTALE,
    NUMERO_MEZZI_PESANTI,
    NUMERO_TRANSITI_PIOGGIA,
    NUMERO_TRANSITI_PESANTI_PIOGGIA,
    SEVERITY_BUCHE,
    SEVERITY_VIBRAZIONI,
]

class Generator:

    def __init__(self, output_filename: str, min_days: int = 1, max_days: int = 100, temperature_min: int = -10, temperature_max: int = 30,
                    humidity_min: int = 0, humidity_max: int = 100, rain_min: float = 0.1, rain_max: float = 10.0,
                    threshold_storm: float = 7.0, temperature_in_a_day: int = 48, min_transits: int = 0, max_transits: int = 10000,
                    hole_detect_probability: float = 0.8, hole_formation_probability: float = 0.003):
        
        self.output_filename: str = output_filename
        self.column_names: list[str] = FEATURES
        self.min_days = min_days
        self.max_days = max_days

        self.temperature_in_a_day = temperature_in_a_day
        self.temperature_min = temperature_min
        self.temperature_max = temperature_max

        self.humidity_min = humidity_min
        self.humidity_max = humidity_max

        self.min_rain = rain_min
        self.max_rain = rain_max
        self.threshold_storm = threshold_storm

        self.min_transits = min_transits
        self.max_transits = max_transits

        self.hole_detect_probability = hole_detect_probability
        self.hole_formation_probability = hole_formation_probability
        
        self.basedata_generator = BaseDataGenerator(self.min_days, self.max_days, self.temperature_in_a_day, self.temperature_min,
                                                    self.temperature_max, self.humidity_min, self.humidity_max, self.min_rain,
                                                    self.max_rain, self.hole_formation_probability)

        '''
            Associa il nome di una feature con il rispettivo generatore
        '''
        self.feature_handler: dict[str, Callable[[dict[str, any]], any]] = {

            MEDIA_TEMPERATURA_SOTTOZERO: 
                lambda data: sum([temp for temp in
                    data["temperatures"]
                        if temp < 0]
                    ) / (self.temperature_in_a_day * data[NUMERO_GIORNI]),

            MEDIA_TEMPERATURA: 
                lambda data: sum(data["temperatures"]) / (self.temperature_in_a_day * data[NUMERO_GIORNI]),

            MEDIA_UMIDITA:
                lambda data: sum(data[UMIDITA]) / data[NUMERO_GIORNI],

            QTA_PIOGGIA:
                lambda data: sum(data["pioggia"]) / data[NUMERO_GIORNI],

            NUMERO_TEMPORALI:
                lambda data: len([p for p in data["pioggia"] if p > self.threshold_storm]),

            MEDIA_SBALZO_TERMICO:
                lambda data: sum([
                        max(data[TEMPERATURE][i * self.temperature_in_a_day : (i + 1) * self.temperature_in_a_day])
                        - min(data[TEMPERATURE][i * self.temperature_in_a_day : (i + 1) * self.temperature_in_a_day]) 
                            for i in range(0, data[NUMERO_GIORNI])
                        ]) / data[NUMERO_GIORNI],

            NUMERO_TRANSITI_TOTALE:
                lambda data: sum([int(random.gauss((self.max_transits - self.min_transits) / 2, self.max_transits / 2)) for _ in range(0, data[NUMERO_GIORNI])]),

            NUMERO_MEZZI_PESANTI:
                lambda data: random.randint(self.min_transits, data[NUMERO_TRANSITI_TOTALE]),

            NUMERO_TRANSITI_PIOGGIA:
                lambda data: 0 if data[QTA_PIOGGIA] == 0 else random.randint(self.min_transits, data[NUMERO_TRANSITI_TOTALE]),

            NUMERO_TRANSITI_PESANTI_PIOGGIA:
                lambda data: random.randint(self.min_transits, min(data[NUMERO_MEZZI_PESANTI], data[NUMERO_TRANSITI_PIOGGIA])),

            SEVERITY_BUCHE:
                lambda data: sum(
                    [sum(
                        # Lista di somme delle severity rilevate
                        [sum(
                            # Lista di transiti che rilevano la buca
                            [severity for _ in range(0, int(data[NUMERO_TRANSITI_TOTALE] / data[NUMERO_GIORNI])) if random.uniform(0, 1) < self.hole_detect_probability]
                            ) for severity in severities]
                        ) for severities in data[BUCHE]]
                    ),

            SEVERITY_VIBRAZIONI:
                lambda data: (
                    abs(data[MEDIA_TEMPERATURA_SOTTOZERO] * 20 / -self.temperature_min)                 # Conta un 20%
                    + data[NUMERO_TRANSITI_PESANTI_PIOGGIA] * 40 / data[NUMERO_TRANSITI_TOTALE]         # Conta un 40%
                    + data[MEDIA_SBALZO_TERMICO] * 20 / (self.temperature_max - self.temperature_min)   # Conta un 20%
                    + arctan(data[SEVERITY_BUCHE]) * (2 / math.pi) * 20                                 # Conta un 20%
                )

        }

    '''
        Genera il file .csv!

        rows = numero di righe del file
    '''
    def generate(self, rows: int) -> bool:

        data: list[dict[str, any]] = [self.get_fake_row() for _ in range(0, rows)]
        df = pd.DataFrame(data)
        if df.to_csv(self.output_filename, index=False, columns=self.column_names):
            return True
        return False


    '''
        Crea una riga fake per il dataframe
    '''
    def get_fake_row(self) -> dict[str, any]:
        
        data = self.basedata_generator.generate()

        for feature in self.column_names:
            if feature in data.keys():
                continue
            data[feature] = self.feature_handler[feature](data)

        new_data = {}
        for feature in self.column_names:
            new_data[feature] = data[feature]

        return new_data

if __name__ == '__main__':

    # Crea un file .csv con 100 righe
    generator = Generator("output.csv")
    generator.generate(100)