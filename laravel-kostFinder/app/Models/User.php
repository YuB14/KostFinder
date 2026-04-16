<?php

namespace App\Models;

use MongoDB\Laravel\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'users';

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'profile_picture',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_login_at'     => 'datetime',
        'created_at'        => 'datetime',
        'updated_at'        => 'datetime',
        'password'          => 'hashed',
    ];

    // Relasi ke review
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    // Relasi ke favorite
    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}
