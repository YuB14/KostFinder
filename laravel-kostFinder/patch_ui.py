# -*- coding: utf-8 -*-
import codecs

with codecs.open('resources/views/admin/pages/kost.blade.php', 'r', 'utf-8') as f:
    content = f.read()

# Fix Add Modal Kode Lokasi
kadd_lok_old = '''                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kadd-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kadd-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kadd-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kadd-kodelok',this)">🚌 Dekat Transportasi</div>'''

kadd_lok_new = '''                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kadd-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kadd-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kadd-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kadd-kodelok',this)">🚌 Dekat Transportasi</div>
                            <div class="csel-opt" data-val="5" onclick="pickCsel('csel-kadd-kodelok',this)">🏡 Perumahan</div>
                            <div class="csel-opt" data-val="6" onclick="pickCsel('csel-kadd-kodelok',this)">🛍️ Dekat Pasar/Mall</div>
                            <div class="csel-opt" data-val="7" onclick="pickCsel('csel-kadd-kodelok',this)">🏭 Kawasan Industri</div>
                            <div class="csel-opt" data-val="8" onclick="pickCsel('csel-kadd-kodelok',this)">🛣️ Pinggir Jalan Utama</div>
                            <div class="csel-opt" data-val="9" onclick="pickCsel('csel-kadd-kodelok',this)">⛰️ Pedesaan/Wisata</div>
                            <div class="csel-opt" data-val="10" onclick="pickCsel('csel-kadd-kodelok',this)">📍 Lainnya</div>'''

if kadd_lok_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found kadd_lok_old")
    content = content.replace(kadd_lok_old, kadd_lok_new).replace(kadd_lok_old.replace('\n', '\r\n'), kadd_lok_new.replace('\n', '\r\n'))

# Fix Edit Modal Kode Lokasi
kedit_lok_old = '''                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kedit-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kedit-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kedit-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kedit-kodelok',this)">🚌 Dekat Transportasi</div>'''

kedit_lok_new = '''                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kedit-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kedit-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kedit-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kedit-kodelok',this)">🚌 Dekat Transportasi</div>
                            <div class="csel-opt" data-val="5" onclick="pickCsel('csel-kedit-kodelok',this)">🏡 Perumahan</div>
                            <div class="csel-opt" data-val="6" onclick="pickCsel('csel-kedit-kodelok',this)">🛍️ Dekat Pasar/Mall</div>
                            <div class="csel-opt" data-val="7" onclick="pickCsel('csel-kedit-kodelok',this)">🏭 Kawasan Industri</div>
                            <div class="csel-opt" data-val="8" onclick="pickCsel('csel-kedit-kodelok',this)">🛣️ Pinggir Jalan Utama</div>
                            <div class="csel-opt" data-val="9" onclick="pickCsel('csel-kedit-kodelok',this)">⛰️ Pedesaan/Wisata</div>
                            <div class="csel-opt" data-val="10" onclick="pickCsel('csel-kedit-kodelok',this)">📍 Lainnya</div>'''

if kedit_lok_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found kedit_lok_old")
    content = content.replace(kedit_lok_old, kedit_lok_new).replace(kedit_lok_old.replace('\n', '\r\n'), kedit_lok_new.replace('\n', '\r\n'))

# Fix Add Wilayah Dropdown
kadd_wil_old = '''                    <div class="csel-dropdown" style="max-height:220px;overflow:hidden;display:flex;flex-direction:column">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border)">
                            <input type="text" id="kadd-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kadd')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kadd-wilayah-list" style="overflow-y:auto;flex:1"></div>
                    </div>'''

kadd_wil_new = '''                    <div class="csel-dropdown" style="padding:0">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border);position:sticky;top:0;background:var(--card);z-index:2;border-radius:6px 6px 0 0">
                            <input type="text" id="kadd-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kadd')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kadd-wilayah-list" style="padding:4px"></div>
                    </div>'''

if kadd_wil_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found kadd_wil_old")
    content = content.replace(kadd_wil_old, kadd_wil_new).replace(kadd_wil_old.replace('\n', '\r\n'), kadd_wil_new.replace('\n', '\r\n'))

# Fix Edit Wilayah Dropdown
kedit_wil_old = '''                    <div class="csel-dropdown" style="max-height:220px;overflow:hidden;display:flex;flex-direction:column">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border)">
                            <input type="text" id="kedit-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kedit')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kedit-wilayah-list" style="overflow-y:auto;flex:1"></div>
                    </div>'''

kedit_wil_new = '''                    <div class="csel-dropdown" style="padding:0">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border);position:sticky;top:0;background:var(--card);z-index:2;border-radius:6px 6px 0 0">
                            <input type="text" id="kedit-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kedit')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kedit-wilayah-list" style="padding:4px"></div>
                    </div>'''

if kedit_wil_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found kedit_wil_old")
    content = content.replace(kedit_wil_old, kedit_wil_new).replace(kedit_wil_old.replace('\n', '\r\n'), kedit_wil_new.replace('\n', '\r\n'))

with codecs.open('resources/views/admin/pages/kost.blade.php', 'w', 'utf-8') as f:
    f.write(content)
