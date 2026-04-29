# -*- coding: utf-8 -*-
import codecs

with codecs.open('resources/views/admin/pages/kost.blade.php', 'r', 'utf-8') as f:
    content = f.read()

# 1. Update kadd-wilayah form group
kadd_old = '''            <div class="mform-row">
                <div class="mform-group"><label>Luas Kamar (m²)</label><input type="number" id="kadd-luas" placeholder="12" min="1" step="0.5"/></div>
                <div class="mform-group"><label>Wilayah / Kota</label>
                    <div class="csel-wrap" id="csel-kadd-wilayah" style="position:relative">
                        <div class="csel-trigger" onclick="toggleCselSearch('csel-kadd-wilayah')" style="display:flex;align-items:center;gap:6px">
                            <span class="csel-val" style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">-- Pilih Wilayah --</span>
                            <span>▾</span>
                        </div>
                        <div class="csel-dropdown" style="max-height:220px;overflow:hidden;display:flex;flex-direction:column">
                            <div style="padding:6px 8px;border-bottom:1px solid var(--border)">
                                <input type="text" id="kadd-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kadd')" onclick="event.stopPropagation()" />
                            </div>
                            <div id="kadd-wilayah-list" style="overflow-y:auto;flex:1"></div>
                        </div>
                    </div>
                    <input type="hidden" id="kadd-wilayah-id" />
                    <input type="hidden" id="kadd-wilayah-kode" value="1" />
                </div>
            </div>'''
kadd_new = '''            <div class="mform-row">
                <div class="mform-group"><label>Luas Kamar (m²)</label><input type="number" id="kadd-luas" placeholder="12" min="1" step="0.5"/></div>
                <div class="mform-group"><label>Kode Lokasi</label>
                    <div class="csel-wrap" id="csel-kadd-kodelok">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kadd-kodelok')"><span class="csel-val">1</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kadd-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kadd-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kadd-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kadd-kodelok',this)">🚌 Dekat Transportasi</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mform-group"><label>Wilayah / Kota</label>
                <div class="csel-wrap" id="csel-kadd-wilayah" style="position:relative">
                    <div class="csel-trigger" onclick="toggleCselSearch('csel-kadd-wilayah')" style="display:flex;align-items:center;gap:6px">
                        <span class="csel-val" style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">-- Pilih Wilayah --</span>
                        <span>▾</span>
                    </div>
                    <div class="csel-dropdown" style="max-height:220px;overflow:hidden;display:flex;flex-direction:column">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border)">
                            <input type="text" id="kadd-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kadd')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kadd-wilayah-list" style="overflow-y:auto;flex:1"></div>
                    </div>
                </div>
                <input type="hidden" id="kadd-wilayah-id" />
            </div>'''
if kadd_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found kadd_old")
    # careful replacement
    old_blocks = [
        kadd_old.replace('\n', '\r\n'),
        kadd_old.replace('\r\n', '\n')
    ]
    for b in old_blocks:
        content = content.replace(b, kadd_new.replace('\n', '\r\n'))

# 2. Update kedit-wilayah form group
kedit_old = '''            <div class="mform-row">
                <div class="mform-group"><label>Luas Kamar (m²)</label><input type="number" id="kedit-luas" placeholder="12" min="1" step="0.5"/></div>
                <div class="mform-group"><label>Wilayah / Kota</label>
                    <div class="csel-wrap" id="csel-kedit-wilayah" style="position:relative">
                        <div class="csel-trigger" onclick="toggleCselSearch('csel-kedit-wilayah')" style="display:flex;align-items:center;gap:6px">
                            <span class="csel-val" style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">-- Pilih Wilayah --</span>
                            <span>▾</span>
                        </div>
                        <div class="csel-dropdown" style="max-height:220px;overflow:hidden;display:flex;flex-direction:column">
                            <div style="padding:6px 8px;border-bottom:1px solid var(--border)">
                                <input type="text" id="kedit-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kedit')" onclick="event.stopPropagation()" />
                            </div>
                            <div id="kedit-wilayah-list" style="overflow-y:auto;flex:1"></div>
                        </div>
                    </div>
                    <input type="hidden" id="kedit-wilayah-id" />
                    <input type="hidden" id="kedit-wilayah-kode" value="1" />
                </div>
            </div>'''
kedit_new = '''            <div class="mform-row">
                <div class="mform-group"><label>Luas Kamar (m²)</label><input type="number" id="kedit-luas" placeholder="12" min="1" step="0.5"/></div>
                <div class="mform-group"><label>Kode Lokasi</label>
                    <div class="csel-wrap" id="csel-kedit-kodelok">
                        <div class="csel-trigger" onclick="toggleCsel('csel-kedit-kodelok')"><span class="csel-val">1</span></div>
                        <div class="csel-dropdown">
                            <div class="csel-opt active" data-val="1" onclick="pickCsel('csel-kedit-kodelok',this)">🏫 Dekat Kampus</div>
                            <div class="csel-opt" data-val="2" onclick="pickCsel('csel-kedit-kodelok',this)">🏙️ Pusat Kota</div>
                            <div class="csel-opt" data-val="3" onclick="pickCsel('csel-kedit-kodelok',this)">🏘️ Pinggir Kota</div>
                            <div class="csel-opt" data-val="4" onclick="pickCsel('csel-kedit-kodelok',this)">🚌 Dekat Transportasi</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mform-group"><label>Wilayah / Kota</label>
                <div class="csel-wrap" id="csel-kedit-wilayah" style="position:relative">
                    <div class="csel-trigger" onclick="toggleCselSearch('csel-kedit-wilayah')" style="display:flex;align-items:center;gap:6px">
                        <span class="csel-val" style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">-- Pilih Wilayah --</span>
                        <span>▾</span>
                    </div>
                    <div class="csel-dropdown" style="max-height:220px;overflow:hidden;display:flex;flex-direction:column">
                        <div style="padding:6px 8px;border-bottom:1px solid var(--border)">
                            <input type="text" id="kedit-wilayah-search" placeholder="Ketik untuk cari..." style="width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;background:var(--bg);color:var(--text)" oninput="filterWilayah('kedit')" onclick="event.stopPropagation()" />
                        </div>
                        <div id="kedit-wilayah-list" style="overflow-y:auto;flex:1"></div>
                    </div>
                </div>
                <input type="hidden" id="kedit-wilayah-id" />
            </div>'''
if kedit_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found kedit_old")
    old_blocks = [
        kedit_old.replace('\n', '\r\n'),
        kedit_old.replace('\r\n', '\n')
    ]
    for b in old_blocks:
        content = content.replace(b, kedit_new.replace('\n', '\r\n'))

# 3. Update openAddKost
add_init_old = "setCselVal('csel-kadd-tier','1');setCselVal('csel-kadd-status','1');setCselVal('csel-kadd-jenis','3');"
add_init_new = "setCselVal('csel-kadd-tier','1');setCselVal('csel-kadd-status','1');setCselVal('csel-kadd-jenis','3');setCselVal('csel-kadd-kodelok','1');\n    document.getElementById('kadd-wilayah-id').value='';\n    document.getElementById('csel-kadd-wilayah').querySelector('.csel-val').textContent='-- Pilih Wilayah --';"
content = content.replace(add_init_old, add_init_new)

# 4. Update submitAddKost
submit_add_old = "const wilayahId = document.getElementById('kadd-wilayah-id').value; const kodeLokas = document.getElementById('kadd-wilayah-kode').value || 1;"
submit_add_new = "const wilayahId = document.getElementById('kadd-wilayah-id').value; const kodeLokas = getCselVal('csel-kadd-kodelok') || 1;"
content = content.replace(submit_add_old, submit_add_new)

# 5. Update openEditKost
edit_init_old = "setCselVal('csel-kedit-jenis',String(d.tipe_kos||3));"
edit_init_new = "setCselVal('csel-kedit-jenis',String(d.tipe_kos||3));\n    setCselVal('csel-kedit-kodelok',String(d.kode_lokasi||1));\n    const wilayahOpt = (K_WILAYAH_OPTS || []).find(w => w.id === d.wilayah_id);\n    document.getElementById('kedit-wilayah-id').value = d.wilayah_id || '';\n    document.getElementById('csel-kedit-wilayah').querySelector('.csel-val').textContent = wilayahOpt ? wilayahOpt.nama : '-- Pilih Wilayah --';"
content = content.replace(edit_init_old, edit_init_new)

# 6. Update submitEditKost
submit_edit_old = "const wilayahId = document.getElementById('kedit-wilayah-id').value; const kodeLokas = document.getElementById('kedit-wilayah-kode').value || 1;"
submit_edit_new = "const wilayahId = document.getElementById('kedit-wilayah-id').value; const kodeLokas = getCselVal('csel-kedit-kodelok') || 1;"
content = content.replace(submit_edit_old, submit_edit_new)

# 7. Update toggleCselSearch and pickWilayah
js_old = '''function toggleCselSearch(id) {
    const wrap = document.getElementById(id);
    if (!wrap) return;
    document.querySelectorAll('.csel-wrap.open').forEach(w => {
        if (w.id !== id) {
            w.classList.remove('open');
            const d = w.querySelector('.csel-dropdown');
            if(d) d.classList.remove('open');
        }
    });
    wrap.classList.toggle('open');
    const dd = wrap.querySelector('.csel-dropdown');
    if (dd) dd.classList.toggle('open', wrap.classList.contains('open'));

    if (wrap.classList.contains('open')) {
        const inp = wrap.querySelector('input[type="text"]');
        if (inp) { inp.value = ''; inp.focus(); }
        filterWilayah(id.replace('csel-', '').split('-')[0]);
    }
}
function filterWilayah(prefix) {
    const q = (document.getElementById(prefix + '-wilayah-search').value || '').toLowerCase();
    const list = document.getElementById(prefix + '-wilayah-list');
    const opts = K_WILAYAH_OPTS || [];
    const filtered = opts.filter(o => o.nama.toLowerCase().includes(q));
    list.innerHTML = filtered.map(o => <div class="csel-opt" style="padding:8px 12px;font-size:13px;cursor:pointer;border-bottom:1px solid var(--border)" onclick="pickWilayah('', '', '', this.textContent)"></div>).join('');
    if (!filtered.length) list.innerHTML = '<div style="padding:8px 12px;font-size:12px;color:var(--muted);text-align:center">Tidak ditemukan</div>';
}
function pickWilayah(prefix, id, kode, nama) {
    document.getElementById(prefix + '-wilayah-id').value = id;
    document.getElementById(prefix + '-wilayah-kode').value = kode;
    const wrap = document.getElementById('csel-' + prefix + '-wilayah');
    wrap.querySelector('.csel-val').textContent = nama;
    wrap.classList.remove('open');
    const dd = wrap.querySelector('.csel-dropdown');
    if(dd) dd.classList.remove('open');
}'''
js_new = '''function toggleCselSearch(id) {
    const wrap = document.getElementById(id);
    if (!wrap) return;
    const dd = wrap.querySelector('.csel-dropdown');
    const trig = wrap.querySelector('.csel-trigger');
    const isOpen = dd.classList.contains('open');

    // tutup semua csel lain
    document.querySelectorAll('.csel-dropdown.open').forEach(d => {
        d.classList.remove('open');
        const w = d.closest('.csel-wrap');
        if(w) {
            const t = w.querySelector('.csel-trigger');
            if(t) t.classList.remove('open');
        }
    });

    if (!isOpen) {
        dd.classList.add('open');
        if(trig) trig.classList.add('open');
        
        const inp = wrap.querySelector('input[type="text"]');
        if (inp) { inp.value = ''; inp.focus(); }
        filterWilayah(id.replace('csel-', '').split('-')[0]);
    } else {
        dd.classList.remove('open');
        if(trig) trig.classList.remove('open');
    }
}
function filterWilayah(prefix) {
    const q = (document.getElementById(prefix + '-wilayah-search').value || '').toLowerCase();
    const list = document.getElementById(prefix + '-wilayah-list');
    const opts = K_WILAYAH_OPTS || [];
    const filtered = opts.filter(o => o.nama.toLowerCase().includes(q));
    list.innerHTML = filtered.map(o => <div class="csel-opt" style="padding:8px 12px;font-size:13px;cursor:pointer;border-bottom:1px solid var(--border)" onclick="pickWilayah('', '', this.textContent)"></div>).join('');
    if (!filtered.length) list.innerHTML = '<div style="padding:8px 12px;font-size:12px;color:var(--muted);text-align:center">Tidak ditemukan</div>';
}
function pickWilayah(prefix, id, nama) {
    document.getElementById(prefix + '-wilayah-id').value = id;
    const wrap = document.getElementById('csel-' + prefix + '-wilayah');
    const valEl = wrap.querySelector('.csel-val');
    valEl.textContent = nama;
    valEl.classList.remove('csel-placeholder');
    wrap.dataset.value = id;
    const dd = wrap.querySelector('.csel-dropdown');
    const trig = wrap.querySelector('.csel-trigger');
    if(dd) dd.classList.remove('open');
    if(trig) trig.classList.remove('open');
}'''
if js_old.replace('\r\n', '\n') in content.replace('\r\n', '\n'):
    print("Found js_old")
    old_blocks = [
        js_old.replace('\n', '\r\n'),
        js_old.replace('\r\n', '\n')
    ]
    for b in old_blocks:
        content = content.replace(b, js_new.replace('\n', '\r\n'))

with codecs.open('resources/views/admin/pages/kost.blade.php', 'w', 'utf-8') as f:
    f.write(content)
