<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Http;

class MLController extends Controller
{
    public function trainModel()
    {
        $response = Http::get('http://127.0.0.1:5000/train');

        return $response->json();
    }
}
