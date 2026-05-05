import re

with open('resources/views/admin/pages/kost.blade.php', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace toggleCselSearch entirely
content = re.sub(
    r'function toggleCselSearch\(id\) \{[\s\S]*?\}\nfunction filterWilayah',
    '''function toggleCselSearch(id) {
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
function filterWilayah''',
    content
)

# Replace filterWilayah map call
content = content.replace(
    '''onclick="pickWilayah('', '', '', this.textContent)"''',
    '''onclick="pickWilayah('', '', this.textContent)"'''
)

# Replace pickWilayah function
content = re.sub(
    r'function pickWilayah\(prefix, id, kode, nama\) \{[\s\S]*?\}',
    '''function pickWilayah(prefix, id, nama) {
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
}''',
    content
)

with open('resources/views/admin/pages/kost.blade.php', 'w', encoding='utf-8') as f:
    f.write(content)
