import pandas as pd

def clean_data(df):
    df = df.dropna()
    df['total'] = df['quantity'] * df['price']
    return df
