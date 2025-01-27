import pandas as pd
from typing import Dict, List, Tuple
import requests
import sys
from datetime import date
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from pgmodel.constants import RawFeatureName, DataframeKey, GRAPHQL_ENDPOINT
from pgmodel.dataset.dataset_generator import DatasetGenerator


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

    def upload_dynamic_guard_data(self, device_id: str, road: str, city: str, county: str | None, state: str, latitude: float,
                                  longitude: float, dataframes: Dict[str, pd.DataFrame]):
        mutations = []

        mutations.extend(self.build_crack_mutations(device_id, road, city, county, state, latitude, longitude, dataframes[DataframeKey.CRACK.value]))
        mutations.extend(self.build_pothole_mutations(device_id, road, city, county, state, latitude, longitude, dataframes[DataframeKey.POTHOLE.value]))

        self.upload_data(mutations)

    def upload_data(self, mutations: list[str]):

        headers = {"Content-Type": "application/json"}

        while len(mutations) > 0:

            counter = 0
            body = []
            while len(mutations) > 0 and counter < self.max_telemetries_in_req:

                body.append(mutations.pop())
                counter += 1

            query = f"mutation {{ {','.join(body)} }}"

            response = requests.post(self.graphql_endpoint, json={"query": query}, headers=headers)

            print(response)

            if response.status_code != 200:
                print(query)
                print(response.text)


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

    def build_crack_mutations(self, device_id: str, road: str, city: str, county: str, state: str, latitude: float,
                                  longitude: float, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createRoadCrackTelemetry(
                        deviceId: "{device_id}",
                        road: "{road}",
                        city: "{city}",
                        county: "{county}",
                        state: "{state}",
                        latitude: {latitude},
                        longitude: {longitude},
                        timestamp: "{row['timestamp']}",
                        severity: {float(row[RawFeatureName.CRACK.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print("error", e)

        return mutations

    def build_pothole_mutations(self, device_id: str, road: str, city: str, county: str | None, state: str, latitude: float,
                                  longitude: float, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            try:
                mutations.append(f"""
                    temperature{index}: createRoadPotholeTelemetry(
                        deviceId: "{device_id}",
                        road: "{road}",
                        city: "{city}",
                        county: "{county}",
                        state: "{state}",
                        latitude: {latitude},
                        longitude: {longitude},
                        timestamp: "{row['timestamp']}",
                        severity: {float(row[RawFeatureName.POTHOLE.value])},
                    ) {{ id }}
                    """.strip())

            except Exception as e:
                print(e)

        return mutations


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

    def static_guard_telemetries_data(self) -> Dict[str, pd.DataFrame]:

        data = {}

        query = """
        query {
          temperatureTelemetries {
            temperature,
            latitude,
            longitude,
            timestamp
          }
        }
        """

        response = self.__request(query).json()
        data[DataframeKey.TEMPERATURE.value] = pd.DataFrame.from_dict(response["data"]["temperatureTelemetries"])

        query = """
                query {
                  humidityTelemetries {
                    humidity,
                    latitude,
                    longitude,
                    timestamp
                  }
                }
                """

        response = self.__request(query).json()
        data[DataframeKey.HUMIDITY.value] = pd.DataFrame.from_dict(response["data"]["humidityTelemetries"])

        query = """
                query {
                  rainTelemetries {
                    mm,
                    latitude,
                    longitude,
                    timestamp
                  }
                }
                """

        response = self.__request(query).json()
        data[DataframeKey.RAINFALL.value] = pd.DataFrame.from_dict(response["data"]["rainTelemetries"])

        query = """
                query {
                  transitTelemetries {
                    velocity,
                    length,
                    transitTime,
                    latitude,
                    longitude,
                    timestamp
                  }
                }
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

        res = self.__request(query).json()
        return res["data"]["planningCalendar"]

    def crack_telemetries_by_date(self, date = date.today()):

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

        return self.__request(query)["date"]["roadCrackTelemetries"]

    def pothole_telemetries_by_date(self, date=date.today()):
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

        return self.__request(query)["date"]["roadPotholeTelemetries"]



    def __request(self, query):
        headers = {"Content-Type": "application/json"}

        return requests.post(self.graphql_endpoint, json={"query": query}, headers=headers)


def upload_telemetries():
    dbfiller = DatabaseFiller(max_telemetries_in_req=5)

    n_days = 30
    static_guards_ids = ["67975a6f6ca18c7a68c3a91d"]

    for device_id in static_guards_ids:
        dbfiller.upload_static_guard_data(
            device_id,
            DatasetGenerator.generate_static_guard_telemetries_data(n_days)
        )

    dynamic_guards = [
        {
            "device_id": "6795478c9d7d3a6e9a46ada3",
            "road": "road",
            "city": "city",
            "county": "county",
            "state": "state",
            "latitude": 24,
            "longitude": 42,
        }
    ]

    for dynamic_guard in dynamic_guards:
        dbfiller.upload_dynamic_guard_data(
            dynamic_guard["device_id"],
            dynamic_guard["road"],
            dynamic_guard["city"],
            dynamic_guard["county"],
            dynamic_guard["state"],
            dynamic_guard["latitude"],
            dynamic_guard["longitude"],
            DatasetGenerator.generate_dynamic_guard_telemetries_data(n_days)
        )


if __name__ == '__main__':
    # upload_telemetries()

    dbfetcher = DatabaseFetcher()

    _, _, t = dbfetcher.dynamic_guard_telemetries_data()

    print(type(t[0]))