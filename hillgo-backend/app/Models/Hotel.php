<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Hotel extends Model
{
    use SoftDeletes;

    protected $fillable = ['name', 'location', 'rating', 'stars', 'price_per_night', 'amenities', 'description', 'image', 'reviews_count', 'active'];

    protected $casts = [
        'amenities' => 'array',
        'active' => 'bool',
        'rating' => 'float',
        'price_per_night' => 'float',
    ];
}
