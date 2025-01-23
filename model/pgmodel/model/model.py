from pgmodel.dataset.dataset_generator import DatasetGenerator
from pgmodel.preprocess.preprocessor import Preprocessor

if __name__ == '__main__':

    # input_dir = "/home/nricciardi/Repositories/pave-guard/model/pgmodel/dataset/data"
    input_dir = "pgmodel/dataset/data"

    df = DatasetGenerator.csv_to_dataframe(input_dir)

    preprocessor = Preprocessor()
    dataset = preprocessor.partition_and_process(df)
    print(dataset.head())