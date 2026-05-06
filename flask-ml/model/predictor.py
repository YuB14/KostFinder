import os
import numpy as np
import pandas as pd
import joblib
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler


# ── FEATURE COLUMNS (urutan FIXED — jangan diubah!) ────────────
# Konsistensi ini WAJIB antara training dan prediksi.
# Laravel harus mengirim field dalam urutan yang sama.
FEATURE_COLUMNS = [
    'harga_kost',
    'luas_kamar',
    'tipe_kos',
    'kelas',
    'kode_lokasi',
    'listrik',
    'ac',
    'kamar_mandi_dalam',
    'parkir_motor',
    'laundry',
    'wifi',
]

# ── Mapping statis (sama dengan Laravel) ───────────────────────
TIPE_KOS_LABEL   = {1: 'Pria', 2: 'Wanita', 3: 'Campur'}
KELAS_LABEL      = {1: 'Ekonomi', 2: 'Standar', 3: 'Premium'}
LOKASI_LABEL     = {1: 'Dekat Kampus', 2: 'Pusat Kota', 3: 'Pinggir Kota', 4: 'Dekat Transportasi Umum'}


def status_label(status: int) -> str:
    if status == 0: return 'Penuh'
    if status == 1: return 'Tersedia'
    return f'{status} kamar tersisa'


class KostPredictor:
    """
    Memprediksi karakteristik kost berdasarkan harga menggunakan K-Means Clustering.
    Seluruh fitur dalam bentuk numerik (float/int) sesuai skema ML-ready.
    Jika model belum dilatih, menggunakan rule-based fallback.
    """

    def __init__(self, model_dir: str = 'saved_model'):
        self.model_dir       = model_dir
        self.kmeans          = None
        self.cluster_profiles: dict = {}
        self.scaler          = None
        self.is_trained      = False
        self._try_load()

    # ──────────────────────────────────────────────
    # Load & Save
    # ──────────────────────────────────────────────
    def _try_load(self):
        """Coba load model yang sudah tersimpan."""
        try:
            self.kmeans           = joblib.load(os.path.join(self.model_dir, 'kmeans.pkl'))
            self.cluster_profiles = joblib.load(os.path.join(self.model_dir, 'profiles.pkl'))
            self.scaler           = joblib.load(os.path.join(self.model_dir, 'scaler.pkl'))
            self.is_trained       = True
            debugPrint("[KostPredictor] Model berhasil dimuat dari disk.")
        except Exception as e:
            self.is_trained = False
            debugPrint(f"[KostPredictor] Model belum ada, pakai rule-based. ({e})")

    def _save(self):
        os.makedirs(self.model_dir, exist_ok=True)
        joblib.dump(self.kmeans,           os.path.join(self.model_dir, 'kmeans.pkl'))
        joblib.dump(self.cluster_profiles, os.path.join(self.model_dir, 'profiles.pkl'))
        joblib.dump(self.scaler,           os.path.join(self.model_dir, 'scaler.pkl'))
        debugPrint("[KostPredictor] Model disimpan ke disk.")

    # ──────────────────────────────────────────────
    # Training
    # ──────────────────────────────────────────────
    def train(self, data: list) -> tuple[bool, str]:
        """
        Latih model dari list dict kost yang berasal dari Laravel API.
        Setiap dict harus memiliki field dalam FEATURE_COLUMNS
        (minimal harga_kost; field lain fallback ke 0 jika tidak ada).
        """
        try:
            df = pd.DataFrame(data)

            if df.empty or 'harga_kost' not in df.columns:
                return False, "Data kosong atau tidak memiliki kolom harga_kost."

            # Jika data dari Laravel punya 'feature_vector' embedded, gunakan itu
            if 'feature_vector' in df.columns:
                fv_df = pd.json_normalize(df['feature_vector'])
                df = pd.concat([df.drop(columns=['feature_vector']), fv_df], axis=1)

            # Pastikan semua FEATURE_COLUMNS ada, fallback 0 jika tidak
            for col in FEATURE_COLUMNS:
                if col not in df.columns:
                    df[col] = 0
                df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0)

            # Filter harga valid
            df = df[df['harga_kost'] > 0].copy()

            if len(df) < 3:
                return False, f"Data terlalu sedikit ({len(df)} kost). Minimal 3."

            # Feature matrix (seluruh FEATURE_COLUMNS)
            X = df[FEATURE_COLUMNS].values
            self.scaler = StandardScaler()
            X_scaled    = self.scaler.fit_transform(X)

            # K-Means: 3 cluster (ekonomi / standar / premium)
            n_clusters  = min(3, len(df))
            self.kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
            df['cluster'] = self.kmeans.fit_predict(X_scaled)

            # Bangun profil tiap cluster — semua nilai numerik
            self.cluster_profiles = {}
            for c in range(n_clusters):
                subset    = df[df['cluster'] == c]
                harga_avg = float(subset['harga_kost'].mean())

                # Mode untuk tiap fitur kategorik
                def mode_int(col, default):
                    s = subset[col].dropna()
                    return int(s.mode().iloc[0]) if not s.empty else default

                def mean_float(col, default):
                    s = subset[col].dropna()
                    return float(s.mean()) if not s.empty else default

                kelas       = mode_int('kelas',      self._kelas_by_harga(harga_avg))
                tipe_kos    = mode_int('tipe_kos',   3)
                kode_lokasi = mode_int('kode_lokasi', 1)
                status      = mode_int('status',      1)
                luas_kamar  = mean_float('luas_kamar', self._luas_by_harga(harga_avg))

                self.cluster_profiles[int(c)] = {
                    'harga_avg':         harga_avg,
                    'kelas':             kelas,
                    'tipe_kos':          tipe_kos,
                    'luas_kamar':        round(luas_kamar, 1),
                    'status':            status,
                    'kode_lokasi':       kode_lokasi,
                    'listrik':           mode_int('listrik',           1),
                    'ac':                mode_int('ac',                0),
                    'kamar_mandi_dalam': mode_int('kamar_mandi_dalam', 0),
                    'parkir_motor':      mode_int('parkir_motor',      0),
                    'laundry':           mode_int('laundry',           0),
                    'wifi':              mode_int('wifi',              0),
                }

            self._save()
            self.is_trained = True
            return True, f"Berhasil melatih model dengan {len(df)} data kost, {n_clusters} cluster."

        except Exception as e:
            return False, f"Error saat training: {str(e)}"

    # ──────────────────────────────────────────────
    # Prediction
    # ──────────────────────────────────────────────
    def predict(self, harga: float) -> dict:
        """Prediksi karakteristik kost berdasarkan harga."""
        if not self.is_trained:
            result = self._rule_based(harga)
            result['source'] = 'rule_based'
            return result

        try:
            # Buat feature vector dari harga (field lain pakai nilai rule-based)
            rb      = self._rule_based(harga)
            fv      = [harga if col == 'harga_kost' else rb.get(col, 0) for col in FEATURE_COLUMNS]
            X       = np.array([fv])
            X_scaled = self.scaler.transform(X)
            cluster  = int(self.kmeans.predict(X_scaled)[0])

            profile = dict(self.cluster_profiles.get(cluster, {}))
            profile['harga_input'] = harga
            profile['cluster']     = cluster
            profile['source']      = 'flask_ml'
            return profile

        except Exception as e:
            result = self._rule_based(harga)
            result['source'] = 'rule_based_fallback'
            result['error']  = str(e)
            return result

    # ──────────────────────────────────────────────
    # Helpers
    # ──────────────────────────────────────────────
    def _kelas_by_harga(self, harga: float) -> int:
        """Fallback kelas berdasarkan harga (numerik)."""
        if harga <= 700_000:   return 1  # ekonomi
        if harga <= 1_500_000: return 2  # standar
        return 3                         # premium

    def _luas_by_harga(self, harga: float) -> float:
        """Fallback luas kamar berdasarkan harga (m²)."""
        if harga <= 700_000:   return 9.0   # 3×3
        if harga <= 1_500_000: return 12.0  # 3×4
        return 16.0                         # 4×4

    def _rule_based(self, harga: float) -> dict:
        """
        Rule-based fallback — seluruh nilai numerik.
        Mapping sama dengan Laravel UserApiController::ruleBased().
        """
        if harga <= 700_000:
            return {
                'kelas':             1,
                'tipe_kos':          3,
                'luas_kamar':        9.0,
                'status':            1,
                'kode_lokasi':       3,
                'listrik':           1,
                'ac':                0,
                'kamar_mandi_dalam': 0,
                'parkir_motor':      1,
                'laundry':           0,
                'wifi':              0,
                'harga_input':       harga,
                'cluster':           0,
            }
        elif harga <= 1_500_000:
            return {
                'kelas':             2,
                'tipe_kos':          3,
                'luas_kamar':        12.0,
                'status':            1,
                'kode_lokasi':       1,
                'listrik':           1,
                'ac':                0,
                'kamar_mandi_dalam': 1,
                'parkir_motor':      1,
                'laundry':           0,
                'wifi':              1,
                'harga_input':       harga,
                'cluster':           1,
            }
        else:
            return {
                'kelas':             3,
                'tipe_kos':          3,
                'luas_kamar':        16.0,
                'status':            1,
                'kode_lokasi':       2,
                'listrik':           1,
                'ac':                1,
                'kamar_mandi_dalam': 1,
                'parkir_motor':      1,
                'laundry':           1,
                'wifi':              1,
                'harga_input':       harga,
                'cluster':           2,
            }
