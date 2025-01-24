import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.preprocess.preprocessor import Preprocessor
import pandas as pd
from sklearn.base import BaseEstimator
from sklearn.tree import DecisionTreeClassifier

class PaveGuardModel:

    def __init__(self, crack_model: BaseEstimator, pothole_model: BaseEstimator):
        self.crack_model = crack_model
        self.pothole_model = pothole_model

    def fit(self, X: pd.DataFrame, Y_crack: pd.Series, Y_pothole: pd.Series):
        self.crack_model.fit(X, Y_crack)
        self.pothole_model.fit(X, Y_pothole)










if __name__ == '__main__':

    # input_dir = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/dataset/data"
    input_dir = "pgmodel\dataset\data"

    df = DatasetGenerator.csv_to_dataframe(input_dir)

    preprocessor = Preprocessor()
    dataset = preprocessor.process(df, consecutive_measures_only=False)
    print(dataset.head())


    model = PaveGuardModel(DecisionTreeClassifier(), DecisionTreeClassifier())