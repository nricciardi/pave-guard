import pandas as pd
import random

MEDIA_TEMPERATURA_SOTTOZERO = "MEDIA_TEMPERATURA_SOTTOZERO"
MEDIA_TEMPERATURA = "MEDIA_TEMPERATURA"
MEDIA_UMIDITA = "MEDIA_UMIDITA"
QTA_PIOGGIA = "PIOGGIA"
NUMERO_TEMPORALI = "NUM_TEMPORALI"
MEDIA_SBALZO_TERMICO = "MEDIA_SBALZO_TERMICO"
NUMERO_TRANSITI_TOTALE = "NUM_TRANSITI_TOT"
NUMERO_MEZZI_PESANTI = "NUM_MEZZI_PESANTI"
NUMERO_TRANSITI_PIOGGIA = "NUM_TRANSITI_PIOGGIA"
NUMERO_TRANSITI_PESANTI_PIOGGIA = "NUM_TRANSIT_PESANTI_PIOGGIA"
NUMERO_GIORNI = "NUM_GIORNI"
SEVERITY_VIBRAZIONI = "SEV_VIBR"
SEVERITY_BUCHE = "SEV_BUCHE"

PIOGGIA = "pioggia"
TEMPERATURE = "temperatures"

'''
    Aggiungi dati che servono a priori da tutto :)
    Se non li vuoi poi nel .csv, cavali da FEATURES
'''
HELPFUL_DATA: list[str] = [
    NUMERO_GIORNI,
    MEDIA_UMIDITA,
    PIOGGIA,
    TEMPERATURE,
]

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
                    threshold_storm: float = 7.0, temperature_in_a_day: int = 48, min_transiti: int = 0, max_transiti: int = 50):
        
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

        self.min_transiti = min_transiti
        self.max_transiti = max_transiti

        '''
            Funzione che crea una generica sequenza, tenendo conto che le cose non
                possono cambiare enormemenete da una misurazione ad un'altra
        '''
        def fake_sequences(num: int, min: float, max: float, max_change: float = 5) -> list[float]:
            temperatures = [random.uniform(min, max)]
            for _ in range(0, num - 1):
                next_temp = temperatures[-1] + random.uniform(-max_change, max_change)
                temperatures.append(
                    max(min(next_temp, max), min)
                )
            return temperatures
        
        '''
            Genera una sequenza di pioggia
        '''
        def generate_rainfall(days: int, min_rain: float, max_rain: float, average_humidity: float) -> list[float]:
            daily_rainfall = []
            rain_prob = min(0.0, average_humidity / self.humidity_max)
            for _ in range(days):
                daily_rainfall.append(
                    random.uniform(min_rain, max_rain) if random.uniform(0.0, 1.0) < rain_prob else 0.0
                )
            return daily_rainfall

        '''
            Associa il nome di una feature con il rispettivo generatore
        '''
        self.feature_handler: map[str, function[[map], any]] = {

            NUMERO_GIORNI:
                lambda data: random.randint(self.min_days, self.max_days),

            TEMPERATURE:
                lambda data: fake_sequences(data[NUMERO_GIORNI] * self.temperature_in_a_day, self.temperature_min, self.temperature_max),

            MEDIA_TEMPERATURA_SOTTOZERO: 
                lambda data: sum([temp for temp in
                    data["temperatures"]
                        if temp < 0]
                    ) / (self.temperature_in_a_day * data[NUMERO_GIORNI]),

            MEDIA_TEMPERATURA: 
                lambda data: sum(data["temperatures"]) / (self.temperature_in_a_day * data[NUMERO_GIORNI]),

            MEDIA_UMIDITA:
                lambda data: sum(fake_sequences(data[NUMERO_GIORNI], self.humidity_min, self.humidity_max)) / data[NUMERO_GIORNI],

            PIOGGIA:
                lambda data: generate_rainfall(data[NUMERO_GIORNI], self.min_rain, self.max_rain, data[MEDIA_UMIDITA]),

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
                lambda data: sum([random.randint(self.min_transiti, self.max_transiti) for _ in range(0, data[NUMERO_GIORNI])]),

            NUMERO_MEZZI_PESANTI:
                lambda data: random.randint(self.min_transiti, data[NUMERO_TRANSITI_TOTALE]),

            NUMERO_TRANSITI_PIOGGIA:
                lambda data: 0 if data[QTA_PIOGGIA] == 0 else random.randint(self.min_transiti, data[NUMERO_TRANSITI_TOTALE]),

            NUMERO_TRANSITI_PESANTI_PIOGGIA:
                lambda data: random.randint(self.min_transiti, min(data[NUMERO_MEZZI_PESANTI], data[NUMERO_TRANSITI_PIOGGIA])),

            SEVERITY_BUCHE:
                lambda data: sum([random.uniform(0, 100) * random.randint(0, 4) for _ in range(0, data[NUMERO_GIORNI]) if random.uniform(0, 1) < 0.4]),

            SEVERITY_VIBRAZIONI:
                lambda data: random.uniform(0, 100)

        }

    '''
        Genera il file .csv!

        rows = numero di righe del file
    '''
    def generate(self, rows: int) -> None:

        data = [self.get_fake_row() for i in range(0, rows)]
        df = pd.DataFrame(data)
        df.to_csv(self.output_filename, index=False, columns=self.column_names)


    '''
        Crea una riga fake per il dataframe
    '''
    def get_fake_row(self) -> map:
        data = {}

        for helpful in HELPFUL_DATA:
            data[helpful] = self.feature_handler[helpful](data)

        for feature in self.column_names:
            if feature in data.keys():
                continue
            data[feature] = self.feature_handler[feature](data)

        new_data = {}
        for feature in self.column_names:
            new_data[feature] = data[feature]

        return new_data

if __name__ == '__main__':

    # Crea un file .csv con 10 righe
    generator = Generator("./output.csv")
    generator.generate(10)