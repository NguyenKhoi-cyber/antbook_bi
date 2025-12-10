import pandas as pd
from sklearn.linear_model import LinearRegression

def train_model(file_path):
    df = pd.read_csv(file_path)

    X = df[['quantity']]
    y = df['price']

    model = LinearRegression().fit(X, y)
    return model
