<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaymentMethod extends Model
{
    protected $fillable = ['user_id', 'type', 'label', 'details', 'is_default'];

    protected $casts = [
        'details' => 'array',
        'is_default' => 'bool',
    ];
}
