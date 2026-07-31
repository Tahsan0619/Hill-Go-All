<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class RentalVehicle extends Model
{
    use SoftDeletes;

    protected $fillable = ['name', 'category', 'price_per_day', 'seats', 'transmission', 'fuel', 'rating', 'description', 'image', 'features', 'active'];

    protected $casts = [
        'features' => 'array',
        'active' => 'bool',
        'rating' => 'float',
        'price_per_day' => 'float',
    ];
}
