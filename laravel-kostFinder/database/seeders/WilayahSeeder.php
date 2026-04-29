<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Wilayah;

class WilayahSeeder extends Seeder
{
    public function run(): void
    {
        // Seluruh Kabupaten & Kota di Indonesia (514 wilayah)
        // kode_lokasi default = 1 (dapat disesuaikan per kost)
        $data = [
            // ─── ACEH ───────────────────────────────────────────
            'Kota Banda Aceh','Kota Sabang','Kota Lhokseumawe','Kota Langsa','Kota Subulussalam',
            'Kab. Aceh Besar','Kab. Pidie','Kab. Pidie Jaya','Kab. Bireuen','Kab. Aceh Utara',
            'Kab. Aceh Timur','Kab. Aceh Tamiang','Kab. Aceh Tenggara','Kab. Gayo Lues','Kab. Bener Meriah',
            'Kab. Aceh Tengah','Kab. Aceh Barat','Kab. Nagan Raya','Kab. Aceh Jaya','Kab. Aceh Barat Daya',
            'Kab. Aceh Selatan','Kab. Aceh Singkil','Kab. Simeulue',
            // ─── SUMATERA UTARA ─────────────────────────────────
            'Kota Medan','Kota Binjai','Kota Tebing Tinggi','Kota Pematang Siantar','Kota Sibolga',
            'Kota Tanjungbalai','Kota Padangsidimpuan','Kota Gunungsitoli',
            'Kab. Deli Serdang','Kab. Langkat','Kab. Karo','Kab. Simalungun','Kab. Asahan',
            'Kab. Labuhanbatu','Kab. Labuhanbatu Selatan','Kab. Labuhanbatu Utara',
            'Kab. Tapanuli Utara','Kab. Tapanuli Tengah','Kab. Tapanuli Selatan',
            'Kab. Padang Lawas','Kab. Padang Lawas Utara','Kab. Mandailing Natal',
            'Kab. Nias','Kab. Nias Utara','Kab. Nias Selatan','Kab. Nias Barat',
            'Kab. Dairi','Kab. Pakpak Bharat','Kab. Toba','Kab. Samosir',
            'Kab. Serdang Bedagai','Kab. Batu Bara','Kab. Humbang Hasundutan',
            // ─── SUMATERA BARAT ─────────────────────────────────
            'Kota Padang','Kota Solok','Kota Sawahlunto','Kota Padang Panjang',
            'Kota Bukittinggi','Kota Payakumbuh','Kota Pariaman',
            'Kab. Pesisir Selatan','Kab. Solok','Kab. Sijunjung','Kab. Tanah Datar',
            'Kab. Padang Pariaman','Kab. Agam','Kab. Lima Puluh Kota','Kab. Pasaman',
            'Kab. Pasaman Barat','Kab. Kepulauan Mentawai','Kab. Dharmasraya','Kab. Solok Selatan',
            // ─── RIAU ────────────────────────────────────────────
            'Kota Pekanbaru','Kota Dumai',
            'Kab. Kampar','Kab. Rokan Hulu','Kab. Rokan Hilir','Kab. Siak','Kab. Pelalawan',
            'Kab. Kuantan Singingi','Kab. Indragiri Hulu','Kab. Indragiri Hilir',
            'Kab. Bengkalis','Kab. Kepulauan Meranti',
            // ─── KEPULAUAN RIAU ─────────────────────────────────
            'Kota Tanjungpinang','Kota Batam',
            'Kab. Bintan','Kab. Karimun','Kab. Natuna','Kab. Kepulauan Anambas','Kab. Lingga',
            // ─── JAMBI ───────────────────────────────────────────
            'Kota Jambi','Kota Sungai Penuh',
            'Kab. Batanghari','Kab. Muaro Jambi','Kab. Tanjung Jabung Timur','Kab. Tanjung Jabung Barat',
            'Kab. Tebo','Kab. Bungo','Kab. Merangin','Kab. Sarolangun','Kab. Kerinci',
            // ─── SUMATERA SELATAN ────────────────────────────────
            'Kota Palembang','Kota Prabumulih','Kota Pagar Alam','Kota Lubuklinggau',
            'Kab. Ogan Komering Ulu','Kab. Ogan Komering Ilir','Kab. Muara Enim','Kab. Lahat',
            'Kab. Musi Rawas','Kab. Musi Rawas Utara','Kab. Musi Banyuasin','Kab. Banyuasin',
            'Kab. OKU Timur','Kab. OKU Selatan','Kab. Ogan Ilir','Kab. Empat Lawang',
            'Kab. Penukal Abab Lematang Ilir',
            // ─── BENGKULU ────────────────────────────────────────
            'Kota Bengkulu',
            'Kab. Rejang Lebong','Kab. Lebong','Kab. Kepahiang','Kab. Bengkulu Tengah',
            'Kab. Bengkulu Utara','Kab. Bengkulu Selatan','Kab. Seluma','Kab. Mukomuko','Kab. Kaur',
            // ─── LAMPUNG ─────────────────────────────────────────
            'Kota Bandar Lampung','Kota Metro',
            'Kab. Lampung Selatan','Kab. Lampung Tengah','Kab. Lampung Utara','Kab. Lampung Barat',
            'Kab. Lampung Timur','Kab. Tulang Bawang','Kab. Tulang Bawang Barat',
            'Kab. Tanggamus','Kab. Way Kanan','Kab. Pesawaran','Kab. Pringsewu',
            'Kab. Mesuji','Kab. Pesisir Barat',
            // ─── BANGKA BELITUNG ─────────────────────────────────
            'Kota Pangkalpinang',
            'Kab. Bangka','Kab. Bangka Tengah','Kab. Bangka Selatan','Kab. Bangka Barat',
            'Kab. Belitung','Kab. Belitung Timur',
            // ─── DKI JAKARTA ─────────────────────────────────────
            'Kota Jakarta Pusat','Kota Jakarta Utara','Kota Jakarta Barat',
            'Kota Jakarta Selatan','Kota Jakarta Timur','Kab. Kepulauan Seribu',
            // ─── JAWA BARAT ──────────────────────────────────────
            'Kota Bandung','Kota Bogor','Kota Bekasi','Kota Cimahi','Kota Sukabumi',
            'Kota Cirebon','Kota Tasikmalaya','Kota Banjar','Kota Depok',
            'Kab. Bogor','Kab. Sukabumi','Kab. Cianjur','Kab. Bandung','Kab. Garut',
            'Kab. Tasikmalaya','Kab. Ciamis','Kab. Kuningan','Kab. Cirebon','Kab. Majalengka',
            'Kab. Sumedang','Kab. Indramayu','Kab. Subang','Kab. Purwakarta',
            'Kab. Karawang','Kab. Bekasi','Kab. Bandung Barat','Kab. Pangandaran',
            // ─── BANTEN ──────────────────────────────────────────
            'Kota Serang','Kota Tangerang','Kota Cilegon','Kota Tangerang Selatan',
            'Kab. Serang','Kab. Pandeglang','Kab. Lebak','Kab. Tangerang',
            // ─── DI YOGYAKARTA ───────────────────────────────────
            'Kota Yogyakarta',
            'Kab. Sleman','Kab. Bantul','Kab. Gunungkidul','Kab. Kulon Progo',
            // ─── JAWA TENGAH ─────────────────────────────────────
            'Kota Semarang','Kota Surakarta','Kota Salatiga','Kota Magelang',
            'Kota Pekalongan','Kota Tegal',
            'Kab. Cilacap','Kab. Banyumas','Kab. Purbalingga','Kab. Banjarnegara',
            'Kab. Kebumen','Kab. Purworejo','Kab. Wonosobo','Kab. Magelang','Kab. Boyolali',
            'Kab. Klaten','Kab. Sukoharjo','Kab. Wonogiri','Kab. Karanganyar','Kab. Sragen',
            'Kab. Grobogan','Kab. Blora','Kab. Rembang','Kab. Pati','Kab. Kudus',
            'Kab. Jepara','Kab. Demak','Kab. Semarang','Kab. Temanggung','Kab. Kendal',
            'Kab. Batang','Kab. Pekalongan','Kab. Pemalang','Kab. Tegal','Kab. Brebes',
            // ─── JAWA TIMUR ──────────────────────────────────────
            'Kota Surabaya','Kota Malang','Kota Kediri','Kota Blitar','Kota Pasuruan',
            'Kota Mojokerto','Kota Madiun','Kota Probolinggo','Kota Batu',
            'Kab. Pacitan','Kab. Ponorogo','Kab. Trenggalek','Kab. Tulungagung',
            'Kab. Blitar','Kab. Kediri','Kab. Malang','Kab. Lumajang','Kab. Jember',
            'Kab. Banyuwangi','Kab. Bondowoso','Kab. Situbondo','Kab. Probolinggo',
            'Kab. Pasuruan','Kab. Sidoarjo','Kab. Mojokerto','Kab. Jombang',
            'Kab. Nganjuk','Kab. Madiun','Kab. Magetan','Kab. Ngawi','Kab. Bojonegoro',
            'Kab. Tuban','Kab. Lamongan','Kab. Gresik','Kab. Bangkalan',
            'Kab. Sampang','Kab. Pamekasan','Kab. Sumenep',
            // ─── BALI ────────────────────────────────────────────
            'Kota Denpasar',
            'Kab. Badung','Kab. Gianyar','Kab. Klungkung','Kab. Bangli',
            'Kab. Karangasem','Kab. Buleleng','Kab. Jembrana','Kab. Tabanan',
            // ─── NUSA TENGGARA BARAT ─────────────────────────────
            'Kota Mataram','Kota Bima',
            'Kab. Lombok Barat','Kab. Lombok Tengah','Kab. Lombok Timur','Kab. Lombok Utara',
            'Kab. Sumbawa','Kab. Sumbawa Barat','Kab. Dompu','Kab. Bima',
            // ─── NUSA TENGGARA TIMUR ─────────────────────────────
            'Kota Kupang',
            'Kab. Kupang','Kab. Timor Tengah Selatan','Kab. Timor Tengah Utara','Kab. Belu',
            'Kab. Alor','Kab. Flores Timur','Kab. Sikka','Kab. Ende','Kab. Ngada',
            'Kab. Manggarai','Kab. Manggarai Barat','Kab. Manggarai Timur',
            'Kab. Sumba Timur','Kab. Sumba Barat','Kab. Sumba Tengah','Kab. Sumba Barat Daya',
            'Kab. Lembata','Kab. Rote Ndao','Kab. Nagekeo','Kab. Sabu Raijua','Kab. Malaka',
            // ─── KALIMANTAN BARAT ────────────────────────────────
            'Kota Pontianak','Kota Singkawang',
            'Kab. Sambas','Kab. Bengkayang','Kab. Landak','Kab. Mempawah','Kab. Sanggau',
            'Kab. Ketapang','Kab. Sintang','Kab. Kapuas Hulu','Kab. Sekadau',
            'Kab. Melawi','Kab. Kayong Utara','Kab. Kubu Raya',
            // ─── KALIMANTAN TENGAH ───────────────────────────────
            'Kota Palangka Raya',
            'Kab. Kotawaringin Barat','Kab. Kotawaringin Timur','Kab. Kapuas',
            'Kab. Barito Selatan','Kab. Barito Utara','Kab. Barito Timur',
            'Kab. Katingan','Kab. Seruyan','Kab. Sukamara','Kab. Lamandau',
            'Kab. Gunung Mas','Kab. Pulang Pisau','Kab. Murung Raya',
            // ─── KALIMANTAN SELATAN ──────────────────────────────
            'Kota Banjarmasin','Kota Banjarbaru',
            'Kab. Banjar','Kab. Barito Kuala','Kab. Tapin','Kab. Hulu Sungai Selatan',
            'Kab. Hulu Sungai Tengah','Kab. Hulu Sungai Utara','Kab. Tabalong',
            'Kab. Tanah Laut','Kab. Tanah Bumbu','Kab. Kotabaru','Kab. Balangan',
            // ─── KALIMANTAN TIMUR ────────────────────────────────
            'Kota Samarinda','Kota Balikpapan','Kota Bontang',
            'Kab. Kutai Kartanegara','Kab. Berau','Kab. Kutai Barat','Kab. Kutai Timur',
            'Kab. Paser','Kab. Penajam Paser Utara','Kab. Mahakam Ulu',
            // ─── KALIMANTAN UTARA ────────────────────────────────
            'Kota Tarakan',
            'Kab. Bulungan','Kab. Malinau','Kab. Nunukan','Kab. Tana Tidung',
            // ─── SULAWESI UTARA ──────────────────────────────────
            'Kota Manado','Kota Tomohon','Kota Bitung','Kota Kotamobagu',
            'Kab. Minahasa','Kab. Minahasa Selatan','Kab. Minahasa Utara','Kab. Minahasa Tenggara',
            'Kab. Kepulauan Sangihe','Kab. Kepulauan Talaud','Kab. Kepulauan Siau Tagulandang Biaro',
            'Kab. Bolaang Mongondow','Kab. Bolaang Mongondow Utara',
            'Kab. Bolaang Mongondow Timur','Kab. Bolaang Mongondow Selatan',
            // ─── GORONTALO ───────────────────────────────────────
            'Kota Gorontalo',
            'Kab. Gorontalo','Kab. Bone Bolango','Kab. Gorontalo Utara',
            'Kab. Boalemo','Kab. Pohuwato',
            // ─── SULAWESI TENGAH ─────────────────────────────────
            'Kota Palu',
            'Kab. Donggala','Kab. Toli-Toli','Kab. Banggai','Kab. Banggai Kepulauan','Kab. Banggai Laut',
            'Kab. Poso','Kab. Morowali','Kab. Morowali Utara','Kab. Buol',
            'Kab. Parigi Moutong','Kab. Tojo Una-Una','Kab. Sigi',
            // ─── SULAWESI SELATAN ────────────────────────────────
            'Kota Makassar','Kota Parepare','Kota Palopo',
            'Kab. Bulukumba','Kab. Bantaeng','Kab. Jeneponto','Kab. Takalar','Kab. Gowa',
            'Kab. Sinjai','Kab. Bone','Kab. Maros','Kab. Pangkajene Kepulauan','Kab. Barru',
            'Kab. Soppeng','Kab. Wajo','Kab. Sidenreng Rappang','Kab. Pinrang','Kab. Enrekang',
            'Kab. Luwu','Kab. Luwu Utara','Kab. Luwu Timur',
            'Kab. Tana Toraja','Kab. Toraja Utara','Kab. Kepulauan Selayar',
            // ─── SULAWESI BARAT ──────────────────────────────────
            'Kota Mamuju',
            'Kab. Polewali Mandar','Kab. Mamasa','Kab. Majene',
            'Kab. Mamuju Tengah','Kab. Pasangkayu',
            // ─── SULAWESI TENGGARA ───────────────────────────────
            'Kota Kendari','Kota Baubau',
            'Kab. Buton','Kab. Buton Utara','Kab. Buton Tengah','Kab. Buton Selatan',
            'Kab. Muna','Kab. Muna Barat','Kab. Konawe','Kab. Konawe Selatan',
            'Kab. Konawe Utara','Kab. Konawe Kepulauan',
            'Kab. Kolaka','Kab. Kolaka Utara','Kab. Kolaka Timur',
            'Kab. Bombana','Kab. Wakatobi',
            // ─── MALUKU ──────────────────────────────────────────
            'Kota Ambon','Kota Tual',
            'Kab. Maluku Tengah','Kab. Maluku Tenggara','Kab. Kepulauan Aru',
            'Kab. Seram Bagian Barat','Kab. Seram Bagian Timur',
            'Kab. Maluku Barat Daya','Kab. Buru','Kab. Buru Selatan',
            // ─── MALUKU UTARA ────────────────────────────────────
            'Kota Ternate','Kota Tidore Kepulauan',
            'Kab. Halmahera Barat','Kab. Halmahera Tengah','Kab. Halmahera Timur',
            'Kab. Halmahera Selatan','Kab. Halmahera Utara',
            'Kab. Kepulauan Sula','Kab. Pulau Taliabu','Kab. Pulau Morotai',
            // ─── PAPUA BARAT ─────────────────────────────────────
            'Kota Manokwari','Kota Sorong',
            'Kab. Manokwari','Kab. Manokwari Selatan','Kab. Pegunungan Arfak',
            'Kab. Sorong','Kab. Sorong Selatan','Kab. Maybrat','Kab. Raja Ampat',
            'Kab. Tambrauw','Kab. Teluk Wondama','Kab. Teluk Bintuni','Kab. Fak-Fak','Kab. Kaimana',
            // ─── PAPUA BARAT DAYA (Prov. Baru) ──────────────────
            'Kab. Sorong (Papua Barat Daya)',
            // ─── PAPUA ───────────────────────────────────────────
            'Kota Jayapura',
            'Kab. Jayapura','Kab. Biak Numfor','Kab. Jayawijaya','Kab. Merauke',
            'Kab. Nabire','Kab. Paniai','Kab. Puncak Jaya','Kab. Sarmi','Kab. Keerom',
            'Kab. Pegunungan Bintang','Kab. Yahukimo','Kab. Tolikara','Kab. Waropen',
            'Kab. Supiori','Kab. Memberamo Raya',
            // ─── PAPUA TENGAH (Prov. Baru) ───────────────────────
            'Kab. Nabire (Papua Tengah)','Kab. Puncak','Kab. Dogiyai','Kab. Intan Jaya',
            'Kab. Deiyai','Kab. Mimika',
            // ─── PAPUA PEGUNUNGAN (Prov. Baru) ───────────────────
            'Kab. Lanny Jaya','Kab. Mamberamo Tengah','Kab. Yalimo','Kab. Nduga',
            // ─── PAPUA SELATAN (Prov. Baru) ──────────────────────
            'Kab. Asmat','Kab. Boven Digoel','Kab. Mappi','Kab. Merauke (Papua Selatan)',
        ];

        foreach ($data as $nama) {
            Wilayah::updateOrCreate(
                ['nama_wilayah' => $nama],
                ['nama_wilayah' => $nama, 'kode_lokasi' => 1, 'deskripsi' => '']
            );
        }

        $this->command->info('WilayahSeeder: ' . count($data) . ' kabupaten/kota berhasil di-seed.');
    }
}
