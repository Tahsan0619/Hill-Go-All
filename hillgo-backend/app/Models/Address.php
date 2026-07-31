<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = ['user_id', 'label', 'address', 'lat', 'lng', 'is_default'];

    protected $casts = [
        'is_default' => 'bool',
        'lat' => 'float',
        'lng' => 'float',
    ];
}
