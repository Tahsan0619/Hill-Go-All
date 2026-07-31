<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Promo extends Model
{
    protected $fillable = ['title', 'description', 'code', 'type', 'value', 'min_order_tk', 'expires_at', 'active', 'usage_limit', 'used_count'];

    protected $casts = [
        'active' => 'bool',
        'expires_at' => 'date',
        'value' => 'float',
        'min_order_tk' => 'float',
    ];
}
