"""
Script untuk melatih model KostPredictor dari data kost yang ada di Laravel API.
Jalankan: python model/train_model.py
"""

import sys
import os
import requests

# Tambahkan root flask-ml ke path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from model.predictor import KostPredictor

LARAVEL_URL = os.getenv('LARAVEL_URL', 'http://127.0.0.1:8000')
MODEL_DIR   = os.path.join(os.path.dirname(__file__), '..', 'saved_model')


def train():
    print(f"[Training] Mengambil data dari {LARAVEL_URL}/api/kost ...")

    try:
        response = requests.get(f'{LARAVEL_URL}/api/kost', timeout=15)
        response.raise_for_status()
        api_data = response.json()
    except Exception as e:
        print(f"[Training] GAGAL mengambil data: {e}")
        return

    kost_data = api_data if isinstance(api_data, list) else api_data.get('data', [])

    if not kost_data:
        print("[Training] Tidak ada data kost. Pastikan Laravel sudah berjalan dan ada data.")
        return

    print(f"[Training] Data diterima: {len(kost_data)} kost.")

    predictor = KostPredictor(model_dir=MODEL_DIR)
    success, message = predictor.train(kost_data)

    if success:
        print(f"[Training] OK: {message}")
    else:
        print(f"[Training] GAGAL: {message}")


if __name__ == '__main__':
    train()