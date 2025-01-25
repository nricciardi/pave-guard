import pandas as pd
from typing import Dict


GRAPHQL_ENDPOINT = "http://localhost:3000/graphql"


class DatabaseFiller:

    def __init__(self, graphql_endpoint: str = GRAPHQL_ENDPOINT):
        self.graphql_endpoint = graphql_endpoint

    def upload_telemetries(self, dataframes: Dict[str, pd.DataFrame]):

        for feature_name, dataframe in dataframes:
            pass

    def _sent_mutation(self):
        pass

