# KostFinder

KostFinder adalah platform pencarian kost yang dilengkapi dengan Web (Laravel), Rest API, integrasi Machine Learning (Flask) untuk prediksi harga kost, dan aplikasi mobile (Android/Flutter).

## Penjelasan Singkat Tentang Projek Kita
Proyek ini bertujuan untuk menyelesaikan permasalahan pencari kost (seperti mahasiswa dan pekerja) yang kesulitan mencari tempat tinggal dengan harga yang wajar dan sesuai fasilitas. Dengan KostFinder, pengguna tak hanya bisa membandingkan kost, tapi juga mendapatkan estimasi harga prediksi berdasarkan fasilitas yang diinginkan.

## Tentang Projek

Proyek ini dibangun menggunakan pendekatan micro-service dengan 3 komponen utama:
- **Laravel (Web & Backend API)**: Menjadi sistem pusat data dan Content Management System (CMS), sekaligus menyediakan REST API bagi aplikasi mobile.
- **Flutter (Aplikasi Mobile)**: Antarmuka interaktif bagi end-user yang mempermudah eksplorasi, filter, dan mencari kost melalui perangkat smartphone.
- **Flask (Machine Learning)**: Service terpisah menggunakan Python yang menangani prediksi cerdas harga kost.

## Fitur Utama

- 🔍 **Pencarian Kost Berbasis AI**: Membantu mencari kost cerdas.
- 💰 **Prediksi Harga (AI)**: Mengetahui kisaran wajar harga kost berdasarkan spesifikasi fasilitas dan wilayah.
- ❤️ **Manajemen Favorit**: Menyimpan dan melacak kost favorit pilihan pengguna.
- 📱 **Mobile & Web Responsive**: Dapat diakses melalui browser dengan tampilan landing page yang responsif, maupun aplikasi Android yang native.
- 🔒 **Sistem Autentikasi Terpusat**: Login dan register yang terhubung antara aplikasi Android dan website.

## Tech Stack

- **Frontend/Mobile**: Flutter, Blade (Laravel)
- **Backend**: Laravel (PHP), Flask (Python)
- **Database**: MongoDB
- **Machine Learning**: Scikit-Learn (Python), Pandas, Numpy, NLTK
- **Scraping Tools**: BeautifulSoup, Selenium (Jupyter Notebook)

## Struktur Projek

```text
KostFinder/
├── laravel-kostFinder/    # Source Code Web CMS & API (PHP 8.1+)
├── flask-ml/              # Model ML & API Service (Python 3)
├── flutter_kostfinder/    # Aplikasi Mobile (Dart & Flutter)
├── LICENSE                # File Lisensi Project (MIT)
└── README.md              # Dokumentasi ini
```

## Endpoint

Berikut adalah beberapa Endpoint API Utama yang digunakan dalam sistem ini:

- **Auth**: `POST /api/login`, `POST /api/register`, `POST /api/logout`
- **Data Kost**: `GET /api/user/kost`
- **Favorit**: `GET /api/user/favorite`, `POST /api/user/favorite`
- **AI Prediksi (via Laravel ke Flask)**: `POST /api/user/prediksi`
- **Flask Service (Internal)**: `POST /predict`, `GET /health`

## Persiapan Menjalankan Projek

### Prasyarat Global
Pastikan sistem Anda telah terinstal software berikut sebelum memulai:
- **PHP** (v8.1 atau lebih baru) & Composer
- **Python** (v3.8 atau lebih baru)
- **Node.js** & NPM
- **MongoDB** (Server berjalan di localhost:27017)
- **Flutter SDK** (v3.10 atau lebih baru) & Android Studio / Emulator

---

### Bagian 1: Laravel Backend

#### Instalasi
1. Masuk ke folder backend: `cd laravel-kostFinder`
2. Install dependensi: `composer install`
3. Generate application key: `php artisan key:generate`

#### Konfigurasi `.env`
1. Copy file konfigurasi: `cp .env.example .env`
2. Pastikan settingan database MongoDB Anda sesuai:
   ```env
   DB_CONNECTION=mongodb
   DB_HOST=127.0.0.1
   DB_PORT=27017
   DB_DATABASE=kostfinder
   ```
3. Konfigurasi endpoint Flask ML:
   ```env
   FLASK_ML_URL=http://127.0.0.1:5000
   ```

#### Menjalankan Server Laravel
1. Lakukan seeding database (untuk dummy awal jika diperlukan): `php artisan db:seed`
2. Jalankan server: `php artisan serve`
3. Backend akan menyala di `http://127.0.0.1:8000`

---

### Bagian 2: Flask ML Service (Setup Server)

#### Instalasi
1. Buka terminal baru dan masuk ke folder `flask-ml`: `cd flask-ml`
2. Buat virtual environment (Disarankan): `python -m venv venv`
3. Aktifkan venv: 
   - Windows: `venv\Scripts\activate`
   - Linux/Mac: `source venv/bin/activate`
4. Install semua library: `pip install -r requirements.txt`

#### Konfigurasi `.env`
Untuk saat ini, Flask Service di KostFinder tidak membutuhkan environment tambahan khusus, seluruh model telah disematkan pada folder `saved_model/` dan port default ada di 5000.

#### Menjalankan Flask Server
1. Jalankan server: `flask run` atau `python app.py`
2. Server Machine Learning akan aktif di `http://127.0.0.1:5000`. Biarkan terminal ini aktif di background agar web Laravel bisa terhubung.

---

### Bagian 3: Scraping & Data Preparation
Bagian ini hanya dilakukan jika Anda ingin mengembangkan ulang model atau mengumpulkan data terbaru.

#### Prasyarat Tambahan
- Install Jupyter Notebook (`pip install notebook`)
- Web Driver (misal ChromeDriver untuk Selenium)

#### Step 1 — Scraping Data (`scraping.ipynb`)
Buka dan jalankan Jupyter notebook `scraping.ipynb`. Skrip ini akan melakukan ekstraksi data (crawling) informasi kost dari situs sumber menggunakan Selenium dan menyimpannya dalam format mentah (`raw_data.csv`).

#### Step 2 — Data Cleaning (`data_kost.ipynb`)
Lanjutkan dengan menjalankan `data_kost.ipynb`. Di sini, proses pembersihan data seperti penanganan nilai kosong (NaN), standarisasi harga, encoding fasilitas, dan filter data akan dilakukan, lalu mengekspornya sebagai `clean_data.csv`.

#### Import ke MongoDB
Data `clean_data.csv` bisa digunakan untuk melatih (train) model baru, atau Anda dapat membuat seeder di Laravel (`KostSeeder`) yang mengimpor CSV tersebut langsung ke dalam database MongoDB.

---

### Bagian 4: Flutter App

#### Instalasi
1. Buka terminal baru dan masuk ke folder mobile: `cd flutter_kostfinder`
2. Download semua dependencies Dart: `flutter pub get`

#### Konfigurasi Base URL
1. Buka file `lib/config/api_config.dart`.
2. Ubah host API Laravel Anda dari localhost menjadi **IP Address IPv4 jaringan lokal Anda**. (Contoh `http://192.168.x.x:8000`). Hal ini wajib dilakukan agar emulator Android atau device fisik dapat menghubungi server backend lokal di laptop Anda.

#### Menjalankan Flutter App
1. Sambungkan device Android via kabel (Debug mode) atau buka Android Emulator.
2. Jalankan perintah: `flutter run`

---

## Alur Kerja Sistem

1. Pengguna membuka Aplikasi Flutter atau Web.
2. Flutter App mengirim request data (seperti list kost, review, favorit) ke REST API Laravel.
3. Laravel mengeksekusi query ke MongoDB lalu mengirimkannya kembali ke Flutter.
4. Ketika Pengguna ingin "Memprediksi Harga Kost", Flutter App/Web meminta endpoint di Laravel.
5. Laravel akan melakukan _forwarding_ request tersebut ke Flask Server (`127.0.0.1:5000`).
6. Flask memproses data dari pengguna atau kalkulasi model (Random Forest / Regresi), lalu mengembalikan output JSON.
7. Laravel meneruskan jawaban dari Flask kembali ke Pengguna di aplikasi.

---

## Model & Evaluasi

Sistem Machine Learning untuk Prediksi Harga kami dibangun menggunakan algoritma prediksi dengan tahapan:
- **Data Split**: Pembagian data latih dan data uji (80:20).
- **Features**: Fasilitas (AC, WiFi, dll), Kelas Kost, Wilayah.
- **Model Engine**: Scikit-Learn models disimpan menggunakan joblib/pickle.
- **Evaluasi**: Model diukur dengan algoritma metriks kesalahan seperti MAE (Mean Absolute Error) dan R² Score untuk memastikan akurasi prediksi harga yang diberikan kepada user relevan dengan harga asli pasaran.

---

## Troubleshooting Cepat

- **Gagal login di aplikasi Android**: Pastikan IP Address `lib/config/api_config.dart` sudah menggunakan IPv4 lokal Anda, dan device/emulator terhubung pada jaringan WiFi yang sama dengan laptop Anda.
- **Database Connection Error di Laravel**: Cek kembali status service MongoDB Anda di OS (`systemctl status mongod` atau melalui Services.msc Windows).

---

## Lisensi
Proyek ini dilisensikan di bawah [MIT License](LICENSE). Copyright (c) 2026 Tim C1-KostFinder.
