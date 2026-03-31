@extends('layouts.admin')

@section('title', 'Dashboard')

@section('page_title', 'Beranda')

@section('content')
<div class="page active">
    <div class="page-header">
        <h2>Selamat Datang, <em>Aini</em> 👋</h2>
        <p>Ringkasan aktivitas platform KostFinder hari ini.</p>
    </div>

    {{-- Stat Cards --}}
    <div class="stats-grid">
        <div class="stat-card coral">
            <div class="stat-icon-wrap coral">🏘️</div>
            <div class="stat-value">2.431</div>
            <div class="stat-label">Total Kost</div>
            <div class="stat-change up">↑ 3.2% bulan ini</div>
        </div>
        {{-- Stat card lainnya... --}}
    </div>

    <div class="two-col">
        {{-- Widget Chart dan lainnya... --}}
    </div>
</div>
@endsection
