import pandas as pd
from sklearn.linear_model import LinearRegression
import pickle

def train():
    # contoh data sederhana
    data = {
        'x': [1, 2, 3, 4],
        'y': [2, 4, 6, 8]
    }

    df = pd.DataFrame(data)

    X = df[['x']]
    y = df['y']

    model = LinearRegression()
    model.fit(X, y)

    # simpan model
    with open('saved_model/model.pkl', 'wb') as f:
        pickle.dump(model, f)

    return "Training selesai!"