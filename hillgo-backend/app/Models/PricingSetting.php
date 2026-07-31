<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PricingSetting extends Model
{
    protected $fillable = ['panel', 'values'];

    protected $casts = [
        'values' => 'array',
    ];
}
