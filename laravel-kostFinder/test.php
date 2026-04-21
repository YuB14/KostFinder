<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$review = \App\Models\Review::first();
echo json_encode($review) . "\n";

$kost = \App\Models\Kost::with('reviews')->first();
echo json_encode(['kost' => $kost, 'reviews_count' => count($kost->reviews)]) . "\n";
