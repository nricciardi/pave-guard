import pandas as pd
from typing import Dict
import requests
from pgmodel.constants import RawFeatureName
from pgmodel.dataset.data_loader import DataLoader

GRAPHQL_ENDPOINT = "http://localhost:3000/graphql"


class DatabaseFiller:

    def __init__(self, graphql_endpoint: str = GRAPHQL_ENDPOINT, max_telemetries_in_req: int = 100):
        self.graphql_endpoint = graphql_endpoint
        self.max_telemetries_in_req = max_telemetries_in_req

    def upload_telemetries(self, dataframes: Dict[str, pd.DataFrame]):

        mutations = []

        mutations.append(self.build_temperature_mutations(dataframes["temperature"]))

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


    def build_temperature_mutations(self, dataframe: pd.DataFrame):

        mutations = []

        for index, row in enumerate(dataframe.to_dict(orient='records'), start=1):

            mutations.append(f"""
            temperature{index}: createTemperatureTelemetry(
                deviceId: "{row['deviceId']}",
                timestamp: "{row['timestamp']}",
                temperature: "{row['temperature']}",
            ) {{ id }}
            """)

        return mutations



if __name__ == '__main__':
    dbfiller = DatabaseFiller()

    data_dir = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/dataset/data"

    data = DataLoader.load_data_from_csv(
        data_dir,
        [str(raw_feature.value) for raw_feature in list(RawFeatureName)]
    )

    dbfiller.upload_telemetries(data)