@extends('admin.layouts.admin')
@section('title', 'API / JSON Tester')
@section('page_title', 'API / JSON')

@section('content')
<div class="page active" id="page-api">
    <div class="page-header">
        <h2>API <em>/ JSON</em> Tester</h2>
        <p>Uji endpoint REST API KostFinder — lihat response JSON secara langsung.</p>
    </div>

    <div class="api-tester-layout">
        {{-- Sidebar: Resource Tabs --}}
        <div class="api-sidebar">
            <div class="api-sidebar-title">📂 Resources</div>
            <button class="api-resource-btn active" onclick="setApiResource('users', this)">👥 Pengguna</button>
            <button class="api-resource-btn" onclick="setApiResource('kost', this)">🏘️ Kost</button>
            <button class="api-resource-btn" onclick="setApiResource('review', this)">⭐ Review</button>
            <button class="api-resource-btn" onclick="setApiResource('favorite', this)">❤️ Favorite</button>
        </div>

        {{-- Main: Methods + Response --}}
        <div class="api-main">
            {{-- Method Buttons --}}
            <div class="api-methods-bar">
                <button class="api-method-btn get active" onclick="setApiMethod('GET', this)">GET</button>
                <button class="api-method-btn post" onclick="setApiMethod('POST', this)">POST</button>
                <button class="api-method-btn put" onclick="setApiMethod('PUT', this)">PUT</button>
                <button class="api-method-btn delete" onclick="setApiMethod('DELETE', this)">DELETE</button>
            </div>

            {{-- URL Preview --}}
            <div class="api-url-bar">
                <span class="api-method-label" id="api-method-label">GET</span>
                <span class="api-url-text" id="api-url-text">/api/users</span>
            </div>

            {{-- ID Input --}}
            <div class="api-input-row" id="api-id-row" style="display:none">
                <label>ID Resource</label>
                <input type="text" id="api-id-input" placeholder="Masukkan ID (untuk GET by ID, PUT, DELETE)"/>
            </div>

            {{-- Body Input --}}
            <div class="api-input-row" id="api-body-row" style="display:none">
                <label>Body JSON</label>
                <textarea id="api-body-input" rows="8" placeholder='{"key": "value"}'></textarea>
            </div>

            {{-- Send Button --}}
            <div style="margin-bottom:18px">
                <button class="btn-sm primary" id="api-send-btn" onclick="sendApiRequest()" style="padding:10px 28px;font-size:14px">
                    <span id="api-send-label">🚀 Kirim Request</span>
                </button>
            </div>

            {{-- Response --}}
            <div class="api-response-wrap">
                <div class="api-response-header">
                    <span>📋 Response</span>
                    <div style="display:flex;gap:8px;align-items:center">
                        <span class="api-status-badge" id="api-status-badge" style="display:none"></span>
                        <button class="btn-sm" onclick="copyApiResponse()" style="font-size:11px;padding:4px 10px">📋 Copy</button>
                    </div>
                </div>
                <pre class="api-response-body" id="api-response-body"><span style="color:var(--muted)">// Response JSON akan muncul di sini setelah Anda mengirim request...</span></pre>
            </div>
        </div>
    </div>
</div>

<style>
.api-tester-layout{display:grid;grid-template-columns:200px 1fr;gap:18px;min-height:500px}
.api-sidebar{background:var(--card);border:1px solid var(--border);border-radius:16px;padding:16px;display:flex;flex-direction:column;gap:6px}
.api-sidebar-title{font-family:'Syne',sans-serif;font-size:13px;font-weight:700;margin-bottom:8px;color:var(--muted)}
.api-resource-btn{background:none;border:1.5px solid transparent;border-radius:10px;padding:10px 14px;font-size:13px;font-weight:600;font-family:'DM Sans',sans-serif;cursor:pointer;text-align:left;color:var(--text);transition:all .15s}
.api-resource-btn:hover{background:var(--bg);border-color:var(--border)}
.api-resource-btn.active{background:var(--coral-bg);border-color:var(--coral);color:var(--coral)}
.api-main{display:flex;flex-direction:column;gap:14px}
.api-methods-bar{display:flex;gap:8px;flex-wrap:wrap}
.api-method-btn{padding:8px 20px;border-radius:10px;border:1.5px solid var(--border);background:var(--bg);font-size:13px;font-weight:700;font-family:'DM Sans',sans-serif;cursor:pointer;transition:all .15s;color:var(--text)}
.api-method-btn:hover{border-color:var(--coral)}
.api-method-btn.active.get{background:rgba(56,178,172,.12);border-color:var(--teal);color:var(--teal)}
.api-method-btn.active.post{background:rgba(232,67,13,.1);border-color:var(--coral);color:var(--coral)}
.api-method-btn.active.put{background:rgba(255,193,7,.12);border-color:var(--yellow);color:var(--yellow)}
.api-method-btn.active.delete{background:rgba(229,62,62,.1);border-color:#E53E3E;color:#E53E3E}
.api-url-bar{display:flex;align-items:center;gap:10px;background:var(--card);border:1px solid var(--border);border-radius:12px;padding:12px 16px;font-family:'JetBrains Mono',monospace;font-size:13px}
.api-method-label{padding:4px 10px;border-radius:6px;font-size:11px;font-weight:800;background:rgba(56,178,172,.15);color:var(--teal)}
.api-url-text{color:var(--text);font-weight:500}
.api-input-row{display:flex;flex-direction:column;gap:6px}
.api-input-row label{font-size:12px;font-weight:700;color:var(--muted)}
.api-input-row input,.api-input-row textarea{border:1.5px solid var(--border);border-radius:10px;padding:10px 14px;font-size:13px;font-family:'JetBrains Mono','DM Sans',monospace;background:var(--bg);color:var(--text);resize:vertical}
.api-input-row input:focus,.api-input-row textarea:focus{outline:none;border-color:var(--coral)}
.api-response-wrap{background:var(--card);border:1px solid var(--border);border-radius:16px;overflow:hidden}
.api-response-header{display:flex;justify-content:space-between;align-items:center;padding:12px 18px;border-bottom:1px solid var(--border);font-size:13px;font-weight:700}
.api-response-body{padding:18px;margin:0;font-family:'JetBrains Mono',monospace;font-size:12px;line-height:1.6;max-height:500px;overflow:auto;white-space:pre-wrap;word-break:break-word;color:var(--text);background:transparent}
.api-status-badge{padding:3px 10px;border-radius:100px;font-size:11px;font-weight:700}
.api-status-badge.success{background:rgba(56,178,172,.12);color:var(--teal)}
.api-status-badge.error{background:rgba(229,62,62,.1);color:#E53E3E}
@media(max-width:768px){.api-tester-layout{grid-template-columns:1fr}.api-sidebar{flex-direction:row;overflow-x:auto;flex-wrap:nowrap}.api-resource-btn{white-space:nowrap}}
</style>
@endsection

@push('scripts')
<script>
let apiResource = 'users';
let apiMethod = 'GET';

const apiEndpoints = {
    users: '/api/users',
    kost: '/api/kost',
    review: '/api/review',
    favorite: '/api/favorite',
};

function setApiResource(resource, el) {
    apiResource = resource;
    document.querySelectorAll('.api-resource-btn').forEach(b => b.classList.remove('active'));
    el.classList.add('active');
    updateApiUrl();
}

function setApiMethod(method, el) {
    apiMethod = method;
    document.querySelectorAll('.api-method-btn').forEach(b => b.classList.remove('active'));
    el.classList.add('active');

    // Show/hide ID input
    const showId = ['PUT', 'DELETE'].includes(method);
    document.getElementById('api-id-row').style.display = showId ? '' : 'none';

    // Show/hide body input
    const showBody = ['POST', 'PUT'].includes(method);
    document.getElementById('api-body-row').style.display = showBody ? '' : 'none';

    // Update method label color
    const label = document.getElementById('api-method-label');
    const colorMap = { GET: 'rgba(56,178,172,.15)', POST: 'rgba(232,67,13,.1)', PUT: 'rgba(255,193,7,.12)', DELETE: 'rgba(229,62,62,.1)' };
    const textMap = { GET: 'var(--teal)', POST: 'var(--coral)', PUT: 'var(--yellow)', DELETE: '#E53E3E' };
    label.style.background = colorMap[method] || '';
    label.style.color = textMap[method] || '';

    updateApiUrl();
}

function updateApiUrl() {
    const base = apiEndpoints[apiResource] || '/api/' + apiResource;
    const id = document.getElementById('api-id-input')?.value?.trim() || '';
    let url = base;
    if (['PUT', 'DELETE'].includes(apiMethod) && id) {
        url += '/' + id;
    }
    document.getElementById('api-method-label').textContent = apiMethod;
    document.getElementById('api-url-text').textContent = url;
}

// Listen for ID input changes
document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('api-id-input')?.addEventListener('input', updateApiUrl);
});

async function sendApiRequest() {
    const base = apiEndpoints[apiResource];
    const id = document.getElementById('api-id-input')?.value?.trim() || '';
    let url = base;
    if (['PUT', 'DELETE'].includes(apiMethod) && id) {
        url += '/' + id;
    } else if (apiMethod === 'GET' && id) {
        url += '/' + id;
    }

    const responseBody = document.getElementById('api-response-body');
    const statusBadge = document.getElementById('api-status-badge');
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';

    responseBody.textContent = '⏳ Mengirim request...';
    statusBadge.style.display = 'none';

    document.getElementById('api-send-btn').disabled = true;
    document.getElementById('api-send-label').textContent = '⏳ Mengirim...';

    try {
        const options = {
            method: apiMethod === 'GET' ? 'GET' : 'POST',
            headers: {
                'Accept': 'application/json',
                'X-CSRF-TOKEN': csrfToken,
            },
        };

        if (['POST', 'PUT', 'DELETE'].includes(apiMethod)) {
            options.headers['Content-Type'] = 'application/json';
            const bodyText = document.getElementById('api-body-input')?.value?.trim() || '{}';
            let bodyObj = {};
            try { bodyObj = JSON.parse(bodyText); } catch(e) { bodyObj = {}; }
            if (apiMethod === 'PUT') bodyObj._method = 'PUT';
            if (apiMethod === 'DELETE') {
                bodyObj._method = 'DELETE';
                options.method = 'POST';
            }
            options.body = JSON.stringify(bodyObj);
        }

        const res = await fetch(url, options);
        const json = await res.json();

        // Format JSON with syntax highlighting
        const formatted = JSON.stringify(json, null, 2);
        responseBody.textContent = formatted;

        // Status badge
        statusBadge.style.display = '';
        statusBadge.textContent = res.status + ' ' + res.statusText;
        statusBadge.className = 'api-status-badge ' + (res.ok ? 'success' : 'error');

    } catch (err) {
        responseBody.textContent = '❌ Error: ' + err.message;
        statusBadge.style.display = '';
        statusBadge.textContent = 'Error';
        statusBadge.className = 'api-status-badge error';
    } finally {
        document.getElementById('api-send-btn').disabled = false;
        document.getElementById('api-send-label').textContent = '🚀 Kirim Request';
    }
}

function copyApiResponse() {
    const text = document.getElementById('api-response-body').textContent;
    navigator.clipboard.writeText(text).then(() => {
        showToast('Response berhasil dicopy', '📋');
    });
}
</script>
@endpush
