<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$kost = \App\Models\Kost::with('reviews')->first();
$resource = \App\Http\Resources\KostResource::make($kost)->resolve();
echo json_encode($resource) . "\n";
