const fs = require('fs');
fetch('http://localhost:8000/api/kost')
  .then(r => r.json())
  .then(res => {
    let allKosts = res.data;
    try {
        function formatRupiah(n){return 'Rp '+Number(n??0).toLocaleString('id-ID');}
        const q='';
        const KELAS_LABEL={1:'Ekonomi',2:'Standar',3:'Premium'};
        let activeKostFilter='semua';
        const filtered=allKosts.filter(k=>{
            const kelasInt=parseInt(k.kelas??0);
            const kelasLabel=(KELAS_LABEL[kelasInt]||'').toLowerCase();
            const matchKelas=activeKostFilter==='semua'||String(kelasInt)===activeKostFilter;
            const matchSearch=!q||(k.nama_kost??'').toLowerCase().includes(q)||(k.alamat_kost??'').toLowerCase().includes(q)||kelasLabel.includes(q)||(k.status_label??'').toLowerCase().includes(q)||formatRupiah(k.harga_kost).toLowerCase().includes(q)||String(k.avg_rating??'').includes(q);
            return matchKelas&&matchSearch;
        });
        
        function renderStars(r){const v=parseFloat(r)||0,f=Math.floor(v),h=(v-f)>=0.5;let s='';for(let i=0;i<5;i++)s+=i<f?'★':(i===f&&h?'½':'☆');return s;}
        function kelasClass(k){const t=(k||'').toLowerCase();return t==='ekonomis'?'coral':t==='standar'?'teal':t==='premium'?'yellow':'blue';}
        function packKost(k){
            return JSON.stringify({
                id:k.id??'',
                nama_kost:k.nama_kost??'',
                foto_kost:k.foto_kost??'',
                alamat_kost:k.alamat_kost??'',
                kelas:k.kelas??1,
                kelas_label:k.kelas_label??'Ekonomi',
                tipe_kos:k.tipe_kos??3,
                tipe_kos_label:k.tipe_kos_label??'Campur',
                status:k.status??1,
                status_label:k.status_label??'Tersedia',
                luas_kamar:k.luas_kamar??0,
                kode_lokasi:k.kode_lokasi??1,
                wilayah_id:k.wilayah_id??'',
                listrik:k.listrik??0,
                ac:k.ac??0,
                kamar_mandi_dalam:k.kamar_mandi_dalam??0,
                parkir_motor:k.parkir_motor??0,
                laundry:k.laundry??0,
                wifi:k.wifi??0,
                harga_kost:k.harga_kost??0,
                nomor_telepon:k.nomor_telepon??'',
                deskripsi:k.deskripsi??'',
                rating:parseFloat(k.avg_rating??0).toFixed(1),
                ulasan:parseInt(k.reviews_count??0),
            }).replace(/'/g,"&#39;");
        }
        
        const gridHtml=filtered.map(k=>{
            const rating=parseFloat(k.avg_rating??0).toFixed(1),ulasan=parseInt(k.reviews_count??0);
            const stars=renderStars(rating);
            const kelasInt=parseInt(k.kelas??1);
            const kelasLabel=k.kelas_label||KELAS_LABEL[kelasInt]||'Ekonomi';
            const kelasCls=kelasClass(kelasLabel);
            const statusLabel=k.status_label||(k.status>=1?'Tersedia':'Penuh');
            const fasList=[];
            if(k.listrik)fasList.push('⚡');if(k.ac)fasList.push('❄️');if(k.wifi)fasList.push('📶');
            if(k.kamar_mandi_dalam)fasList.push('🚿');if(k.parkir_motor)fasList.push('🏍️');if(k.laundry)fasList.push('👕');
            const tags=fasList.slice(0,3).map(f=>`<span class="kc-tag">${f}</span>`).join('');
            const fotoHtml=k.foto_kost?'<img>':'<span></span>';
            const d=packKost(k),namaEsc=(k.nama_kost??'').replace(/'/g,"\\'");
            return '<div class="kost-card-dash"></div>';
        }).join('');
        console.log('SUCCESS! No JS error in rendering logic');
    } catch(err) {
        console.error('JS Error:', err.message);
        console.error(err.stack);
    }
  });
