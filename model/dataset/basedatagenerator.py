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
BUCHE = "buche"
UMIDITA = "umidità"


'''
    Aggiungi dati che servono a priori da tutto :)
    Se non li vuoi poi nel .csv, cavali da FEATURES
'''
HELPFUL_DATA: list[str] = [
    NUMERO_GIORNI,
    UMIDITA,
    PIOGGIA,
    TEMPERATURE,
    BUCHE,
]

class BaseDataGenerator():

    def __init__(self, min_days: int = 1, max_days: int = 100, temperature_in_a_day: int = 48, temperature_min: float = -10., 
                 temperature_max: float = 35, humidity_min: float = 0, humidity_max: float = 100, min_rain: float = 0.0,
                 max_rain: float = 10.0, hole_formation_probability: float = 0.003):

        self.min_days = min_days
        self.max_days = max_days
        
        self.temperature_in_a_day = temperature_in_a_day
        self.temperature_min = temperature_min
        self.temperature_max = temperature_max
        
        self.humidity_min = humidity_min
        self.humidity_max = humidity_max
        
        self.min_rain = min_rain
        self.max_rain = max_rain
        
        self.hole_formation_probability = hole_formation_probability

        self.data: dict = {
            attribute:0 for attribute in HELPFUL_DATA
        }

        self.function_handler = {

            NUMERO_GIORNI:
                lambda data: random.randint(self.min_days, self.max_days),

            TEMPERATURE:
                lambda data: self.fake_sequences(data[NUMERO_GIORNI] * self.temperature_in_a_day, self.temperature_min, self.temperature_max),

            UMIDITA:
                lambda data: self.fake_sequences(data[NUMERO_GIORNI], self.humidity_min, self.humidity_max),

            PIOGGIA:
                lambda data: self.generate_rainfall(data[NUMERO_GIORNI], self.min_rain, self.max_rain, data[UMIDITA], self.humidity_max),

            BUCHE:
                lambda data: self.generate_holes(data[NUMERO_GIORNI], self.hole_formation_probability),

        }

    '''
            Funzione che crea una generica sequenza, tenendo conto che le cose non
                possono cambiare enormemenete da una misurazione ad un'altra
    '''
    def fake_sequences(self, num: int, min_n: float, max_n: float, max_change: float = 5) -> list[float]:
        temperatures = [random.uniform(min_n, max_n)]
        for _ in range(0, num - 1):
            next_temp = temperatures[-1] + random.uniform(-max_change, max_change)
            temperatures.append(
                max(min(next_temp, max_n), min_n)
            )
        return temperatures
        
    '''
        Genera una sequenza di pioggia
    '''
    def generate_rainfall(self, days: int, min_rain: float, max_rain: float, humidities: list, humidity_max: float) -> list[float]:
        daily_rainfall = []
        average_humidity = sum(humidities) / days
        rain_prob = min(0.0, average_humidity / humidity_max)
        for _ in range(days):
            daily_rainfall.append(
                random.uniform(min_rain, max_rain) if random.uniform(0.0, 1.0) < rain_prob else 0.0
            )
        return daily_rainfall

    '''
        Genera una sequenza di buche
    '''
    def generate_holes(self, days: int, hole_formation_probability: float = 0.003, initial_holes: int = 0) -> list[list[int]]:
        holes = [[random.uniform(0, 100) for _ in range(0, initial_holes)]]
        for _ in range(1, days):
            new_holes = holes[-1]
            if random.uniform(0, 1) < 0.003:
                new_holes.append(random.uniform(0, 100))
            holes.append(new_holes)
        return holes

    def generate(self):
        self.data = {}
        for attribute in HELPFUL_DATA:
            self.data[attribute] = self.function_handler[attribute](self.data)
        return self.data
