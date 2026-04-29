"""
Flask ML Service — KostFinder (ML-Ready Schema)

Feature vector order (MUST stay consistent between training & prediction):
  harga_kost, luas_kamar, tipe_kos, kelas, kode_lokasi,
  listrik, ac, kamar_mandi_dalam, parkir_motor, laundry, wifi

Endpoint:
  GET  /health        → cek status & apakah model sudah dilatih
  POST /predict       → prediksi karakteristik kost dari harga
  POST /train         → latih ulang model dari data Laravel API
"""

import os
import sys

# Tambahkan root directory ke path agar bisa import model/
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import requests as req
from flask import Flask, request, jsonify
from flask_cors import CORS
from model.predictor import KostPredictor, FEATURE_COLUMNS

# ── Inisialisasi Flask ──────────────────────────────────────────
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# URL Laravel (bisa di-override lewat environment variable)
LARAVEL_URL = os.getenv('LARAVEL_URL', 'http://127.0.0.1:8000')

# Load/init predictor
predictor = KostPredictor(model_dir=os.path.join(os.path.dirname(__file__), 'saved_model'))


# ── Endpoint: Health Check ──────────────────────────────────────
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status':          'ok',
        'model_trained':   predictor.is_trained,
        'laravel_url':     LARAVEL_URL,
        'feature_columns': FEATURE_COLUMNS,
    })


# ── Endpoint: Predict ───────────────────────────────────────────
@app.route('/predict', methods=['POST'])
def predict():
    """
    Body JSON: { "harga": 1500000 }
    Response:  {
        "success": true,
        "data": {
            "kelas": 2,             -- int: 1=ekonomi, 2=standar, 3=premium
            "tipe_kos": 3,          -- int: 1=pria, 2=wanita, 3=campur
            "luas_kamar": 12.0,     -- float, m²
            "status": 1,            -- int: 0=penuh, 1=tersedia, >=2=sisa
            "kode_lokasi": 1,       -- int: 1-4
            "listrik": 1,
            "ac": 0,
            "kamar_mandi_dalam": 1,
            "parkir_motor": 1,
            "laundry": 0,
            "wifi": 1,
            "source": "flask_ml" | "rule_based"
        }
    }
    """
    body = request.get_json(silent=True)
    if not body or 'harga' not in body:
        return jsonify({'success': False, 'message': 'Parameter "harga" wajib diisi.'}), 400

    try:
        harga = float(body['harga'])
    except (ValueError, TypeError):
        return jsonify({'success': False, 'message': 'Nilai harga tidak valid.'}), 400

    if harga <= 0:
        return jsonify({'success': False, 'message': 'Harga harus lebih dari 0.'}), 400

    result = predictor.predict(harga)

    return jsonify({
        'success': True,
        'data':    result,
    })


# ── Endpoint: Train ─────────────────────────────────────────────
@app.route('/train', methods=['POST'])
def train():
    """
    Ambil data kost dari Laravel API (/api/kost), lalu latih model.
    Body JSON (opsional): { "laravel_url": "http://..." }
    """
    body       = request.get_json(silent=True) or {}
    source_url = body.get('laravel_url', LARAVEL_URL)

    try:
        response = req.get(f'{source_url}/api/kost', timeout=15)
        response.raise_for_status()
        api_data = response.json()
    except Exception as e:
        return jsonify({'success': False, 'message': f'Gagal mengambil data dari Laravel: {str(e)}'}), 500

    # Data bisa berupa list langsung atau dalam key "data"
    kost_data = api_data if isinstance(api_data, list) else api_data.get('data', [])

    if not kost_data:
        return jsonify({'success': False, 'message': 'Tidak ada data kost yang diterima dari Laravel.'}), 400

    success, message = predictor.train(kost_data)
    status_code = 200 if success else 500

    return jsonify({
        'success':         success,
        'message':         message,
        'total_data':      len(kost_data),
        'feature_columns': FEATURE_COLUMNS,
    }), status_code


# ── Main ────────────────────────────────────────────────────────
if __name__ == '__main__':
    print(f"[Flask ML] Berjalan di http://127.0.0.1:5000")
    print(f"[Flask ML] Laravel URL: {LARAVEL_URL}")
    print(f"[Flask ML] Model sudah dilatih: {predictor.is_trained}")
    print(f"[Flask ML] Feature columns: {FEATURE_COLUMNS}")
    app.run(debug=True, host='0.0.0.0', port=5000)