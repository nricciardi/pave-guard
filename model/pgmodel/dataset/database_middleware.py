import pandas as pd
from typing import Dict
import requests
from pgmodel.constants import RawFeatureName
from pgmodel.dataset.dataset_generator import DatasetGenerator

GRAPHQL_ENDPOINT = "http://localhost:3000/graphql"


class DatabaseFiller:

    def __init__(self, graphql_endpoint: str = GRAPHQL_ENDPOINT, max_telemetries_in_req: int = 25):
        self.graphql_endpoint = graphql_endpoint
        self.max_telemetries_in_req = max_telemetries_in_req

    def upload_static_guard_data(self, device_id: str, dataframes: Dict[str, pd.DataFrame]):

        mutations = []

        mutations.extend(self.build_temperature_mutations(device_id, dataframes["temperature"]))
        mutations.extend(self.build_humidity_mutations(device_id, dataframes["humidity"]))
        mutations.extend(self.build_rainfall_mutations(device_id, dataframes["rainfall"]))
        mutations.extend(self.build_transit_mutations(device_id, dataframes["transit"]))

        self.upload_data(mutations)

    def upload_dynamic_guard_data(self, device_id: str, road: str, city: str, county: str | None, state: str, latitude: float,
                                  longitude: float, dataframes: Dict[str, pd.DataFrame]):
        mutations = []

        mutations.extend(self.build_crack_mutations(device_id, road, city, county, state, latitude, longitude, dataframes["crack"]))
        mutations.extend(self.build_pothole_mutations(device_id, road, city, county, state, latitude, longitude, dataframes["pothole"]))

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
                print(e)

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



if __name__ == '__main__':
    dbfiller = DatabaseFiller(max_telemetries_in_req=5)

    n_days = 30
    static_guards_ids = ["679251aa95e18aed7f6219ed"]

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