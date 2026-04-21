<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Favorite extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'favorites';

    protected $fillable = [
        'user_id',
        'kost_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function kost()
    {
        return $this->belongsTo(Kost::class);
    }
}
