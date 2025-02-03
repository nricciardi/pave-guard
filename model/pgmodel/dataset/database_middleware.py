import pandas as pd
from typing import Dict, List, Tuple
import requests
import sys
from datetime import date, timedelta
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))
from pgmodel.preprocess.preprocessor import Preprocessor
from pgmodel.constants import RawFeatureName, DataframeKey, GRAPHQL_ENDPOINT
from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.dataset.generator.crack_generator import CrackGenerator


class DatabaseFiller:

    def __init__(self, graphql_endpoint: str = GRAPHQL_ENDPOINT, max_telemetries_in_req: int = 25):
        self.graphql_endpoint = graphql_endpoint
        self.max_telemetries_in_req = max_telemetries_in_req

    def upload_static_guard_data(self, device_id: str, dataframes: Dict[str, pd.DataFrame]):

        mutations = []

        mutations.extend(self.build_temperature_mutations(device_id, dataframes[DataframeKey.TEMPERATURE.value]))
        mutations.extend(self.build_humidity_mutations(device_id, dataframes[DataframeKey.HUMIDITY.value]))
        mutations.extend(self.build_rainfall_mutations(device_id, dataframes[DataframeKey.RAINFALL.value]))
        mutations.extend(self.build_transit_mutations(device_id, dataframes[DataframeKey.TRANSIT.value]))

        self.upload_data(mutations)

    def upload_dynamic_guard_data(self, device_id: str, dataframes: Dict[str, pd.DataFrame]):
        mutations = []

        # TODO: lat/long must change

        mutations.extend(self.build_crack_mutations(device_id, dataframes[DataframeKey.CRACK.value]))
        mutations.extend(self.build_pothole_mutations(device_id, dataframes[DataframeKey.POTHOLE.value]))

        self.upload_data(mutations)

    def upload_data(self, mutations: list[str]):

        from concurrent.futures import ThreadPoolExecutor, as_completed
        from itertools import islice

        headers = {"Content-Type": "application/json"}

        def send_request(batch):
            query = f"mutation {{ {' '.join(batch)} }}"
            response = requests.post(self.graphql_endpoint, json={"query": query}, headers=headers)

            if response.status_code != 200:
                print(query)
                print(response.text)

            return response

        with ThreadPoolExecutor(max_workers=8) as executor:
            futures = [
                executor.submit(send_request, mutations[i:i + self.max_telemetries_in_req])
                for i in range(0, len(mutations), self.max_telemetries_in_req)
            ]

            for future in as_completed(futures):
                print(future.result())  # Process completed requests


    def build_temperature_mutations(self, device_id: str, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createTemperatureTelemetry(
                        deviceId: "{device_id}",
                        timestamp: "{row['timestamp']}",
                        temperature: {float(row[RawFeatureName.TEMPERATURE.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print(e)

        return mutations

    def build_humidity_mutations(self, device_id: str, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createHumidityTelemetry(
                        deviceId: "{device_id}",
                        timestamp: "{row['timestamp']}",
                        humidity: {float(row[RawFeatureName.HUMIDITY.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print(e)

        return mutations

    def build_rainfall_mutations(self, device_id: str, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createRainTelemetry(
                        deviceId: "{device_id}",
                        timestamp: "{row['timestamp']}",
                        mm: {float(row[RawFeatureName.RAINFALL.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print(e)

        return mutations

    def build_transit_mutations(self, device_id: str, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createTransitTelemetry(
                        deviceId: "{device_id}",
                        timestamp: "{row['timestamp']}",
                        length: {float(row[RawFeatureName.TRANSIT_LENGTH.value])},
                        velocity: {float(row[RawFeatureName.TRANSIT_VELOCITY.value])},
                        transitTime: {float(row[RawFeatureName.TRANSIT_TIME.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print(e)

        return mutations

    def build_crack_mutations(self, device_id: str, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createRoadCrackTelemetry(
                        deviceId: "{device_id}",
                        road: "{row['road']}",
                        city: "{row['city']}",
                        county: "{row['county']}",
                        state: "{row['state']}",
                        latitude: {float(row["latitude"])},
                        longitude: {float(row["longitude"])},
                        timestamp: "{row['timestamp']}",
                        severity: {float(row[RawFeatureName.CRACK.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print("error", e)

        return mutations

    def build_pothole_mutations(self, device_id: str, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createRoadPotholeTelemetry(
                        deviceId: "{device_id}",
                        road: "{row['road']}",
                        city: "{row['city']}",
                        county: "{row['county']}",
                        state: "{row['state']}",
                        latitude: {float(row["latitude"])},
                        longitude: {float(row["longitude"])},
                        timestamp: "{row['timestamp']}",
                        severity: {float(row[RawFeatureName.POTHOLE.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print(e)

        return mutations

    def upload_prediction(self, prediction):
        self.upload_data([f"""
                    createPrediction(
                        road: "{prediction['road']}",
                        city: "{prediction['city']}",
                        county: "{prediction['county']}",
                        state: "{prediction['state']}",
                        updatedAt: "{prediction['updatedAt']}",
                        crackSeverityPredictions: {prediction["crackSeverityPredictions"]},
                        potholeSeverityPredictions: {prediction["potholeSeverityPredictions"]},
                    ) {{ road }}
                    """.strip()])


class DatabaseFetcher:

    def __init__(self, graphql_endpoint: str = GRAPHQL_ENDPOINT):
        self.graphql_endpoint = graphql_endpoint

    def locations(self) -> List[Dict]:
        query = """
        query {
          locations {
            road,
            city,
            county,
            state,
          }
        }
        """

        return self.__request(query).json()["data"]["locations"]

    def static_guard_telemetries_data(self, static_guard_id: str = None, road: str = None, city: str = None, county: str = None, state: str = None) -> Dict[str, pd.DataFrame]:

        filters = ""
        if road is not None and city is not None and county and state is not None:
            filters = f"""
                (
                    road: "{road}",
                    city: "{city}",
                    county: "{county}",
                    state: "{state}"
                )"""

        if static_guard_id is not None:
            filters = f"""
                        (
                            deviceId: "{static_guard_id}"
                        )"""

        data = {}

        query = f"""
        query {{
          temperatureTelemetries{filters} {{
            temperature,
            latitude,
            longitude,
            timestamp
          }}
        }}
        """

        response = self.__request(query).json()
        data[DataframeKey.TEMPERATURE.value] = pd.DataFrame.from_dict(response["data"]["temperatureTelemetries"])

        query = f"""
                query {{
                  humidityTelemetries{filters} {{
                    humidity,
                    latitude,
                    longitude,
                    timestamp
                  }}
                }}
                """

        response = self.__request(query).json()
        data[DataframeKey.HUMIDITY.value] = pd.DataFrame.from_dict(response["data"]["humidityTelemetries"])

        query = f"""
                query {{
                  rainTelemetries{filters} {{
                    mm,
                    latitude,
                    longitude,
                    timestamp
                  }}
                }}
                """

        response = self.__request(query).json()
        data[DataframeKey.RAINFALL.value] = pd.DataFrame.from_dict(response["data"]["rainTelemetries"])

        query = f"""
                query {{
                  transitTelemetries{filters} {{
                    velocity,
                    length,
                    transitTime,
                    latitude,
                    longitude,
                    timestamp
                  }}
                }}
                """

        response = self.__request(query).json()
        data[DataframeKey.TRANSIT.value] = pd.DataFrame.from_dict(response["data"]["transitTelemetries"])

        return data

    def dynamic_guard_telemetries_data(self) -> Tuple[List[Dict], List[pd.DataFrame], List[pd.DataFrame]]:

        locations = self.locations()

        cracks = []
        potholes = []

        for location in locations:
            crack_query = f"""
                    query {{
            roadCrackTelemetries(
                road: "{location['road']}",
                city: "{location['city']}",
                county: "{location['county']}",
                state: "{location['state']}"
                ) {{
                    severity,
                    latitude,
                    longitude,
                    timestamp,
                    metadata {{
                      deviceId
                    }}
                }}
            }}"""

            response = self.__request(crack_query)

            cracks.append(pd.json_normalize(response.json()["data"]["roadCrackTelemetries"], sep="_"))

            crack_query = f"""
                                query {{
                        roadPotholeTelemetries(
                            road: "{location['road']}",
                            city: "{location['city']}",
                            county: "{location['county']}",
                            state: "{location['state']}"
                            ) {{
                                severity,
                                latitude,
                                longitude,
                                timestamp,
                                metadata {{
                                  deviceId
                                }}
                            }}
                        }}"""

            response = self.__request(crack_query)

            potholes.append(pd.json_normalize(response.json()["data"]["roadPotholeTelemetries"], sep="_"))


        return locations, cracks, potholes

    def maintenance_operations(self) -> List[Dict]:
        query = """
        query {
          planningCalendar {
            id,
            road,
            city,
            county,
            state,
            date,
            done,
            description
          }
        }
        """

        return self.__request(query).json()["data"]["planningCalendar"]


    def static_guards(self, as_dict: bool = True) -> List[Dict] | Dict:
        query = """
        query {
          staticGuards {
            id,
            road,
            city,
            county,
            state,
            latitude,
            longitude
          }
        }
        """

        data = self.__request(query).json()["data"]["staticGuards"]

        if not as_dict:
            return data

        result = {}
        for sg in data:
            result[sg["id"]] = sg

        return result


    def crack_telemetries_by_date(self, date = date.today() - timedelta(days=1)) -> pd.DataFrame:

        query = f"""
         query {{
          roadCrackTelemetries(
            from: "{date.year}-{str(date.month).zfill(2)}-{str(date.day).zfill(2)}T00:00:00.000Z",
            to: "{date.year}-{str(date.month).zfill(2)}-{str(date.day).zfill(2)}T23:59:59.000Z"
          )  {{
              severity,
              latitude,
              longitude,
              timestamp,
              metadata {{
                road,
                city,
                county,
                state,
                deviceId
              }}
          }}
        }}
        """

        return pd.json_normalize(self.__request(query).json()["data"]["roadCrackTelemetries"], sep="_")

    def pothole_telemetries_by_date(self, date=date.today() - timedelta(days=1)):
        query = f"""
         query {{
          roadPotholeTelemetries(
            from: "{date.year}-{str(date.month).zfill(2)}-{str(date.day).zfill(2)}T00:00:00.000Z",
            to: "{date.year}-{str(date.month).zfill(2)}-{str(date.day).zfill(2)}T23:59:59.000Z"
          )  {{
              severity,
              latitude,
              longitude,
              timestamp,
              metadata {{
                road,
                city,
                county,
                state,
                deviceId
              }}
          }}
        }}
        """

        return pd.json_normalize(self.__request(query).json()["data"]["roadPotholeTelemetries"], sep="_")



    def __request(self, query):
        headers = {"Content-Type": "application/json"}

        return requests.post(self.graphql_endpoint, json={"query": query}, headers=headers)


def upload_telemetries(static_guards_ids: list[str], dynamic_guards: list[str], locations, n_days):
    dbfiller = DatabaseFiller(max_telemetries_in_req=25)

    dfs = DatasetGenerator.generate_static_guard_telemetries_data(n_days=n_days, to_date=date.today())

    for device_id in dynamic_guards:
        dbfiller.upload_dynamic_guard_data(
            device_id,
            DatasetGenerator.generate_dynamic_guard_telemetries_data(locations, n_days=n_days, to_date=date.today(), df_to_use=dfs)
        )

    for device_id in static_guards_ids:
        dbfiller.upload_static_guard_data(
            device_id,
            dfs,
        )


if __name__ == '__main__':

    static_guards_ids = ["679b622834220629bc94425c"]

    dynamic_guards = [  
        "6795478c9d7d3a6e9a46ada3",
    ]

    locations: list[dict] = [
        {
            "road": "Via Antonio Araldi",
            "city": "Modena",
            "county": "Modena",
            "state": "Emilia-Romagna",
            "latitude": 44.631169,
            "longitude": 10.946299,
            "variation": 1000
        },
        {
            "road": "Via Barbato Zanoni",
            "city": "Modena",
            "county": "Modena",
            "state": "Emilia-Romagna",
            "latitude": 44.630059,
            "longitude": 10.950163,
            "variation": 50
        },
        {
            "road": "Via Glauco Gottardi",
            "city": "Modena",
            "county": "Modena",
            "state": "Emilia-Romagna",
            "latitude": 44.632163,
            "longitude": 10.948782,
            "variation": 100
        },
        {
            "road": "Via Pietro Vivarelli",
            "city": "Modena",
            "county": "Modena",
            "state": "Emilia-Romagna",
            "latitude": 44.628619,
            "longitude": 10.947372,
            "variation": 100
        },
        {
            "road": "Via Rodolfo Gelmini",
            "city": "Modena",
            "county": "Modena",
            "state": "Emilia-Romagna",
            "latitude": 44.628187, 
            "longitude": 10.950903,
            "variation": 50
        }
    ]

    upload_telemetries(static_guards_ids, dynamic_guards, locations, n_days=730)


    # dbfetcher = DatabaseFetcher()
    #
    # static_guards = dbfetcher.static_guards()
    #
    # print(static_guards)
    #
    # modulations = Preprocessor.get_modulated_ids(static_guards, 10, 10)
    #
    # print(modulations)