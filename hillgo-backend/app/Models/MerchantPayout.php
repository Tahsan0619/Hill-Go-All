<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MerchantPayout extends Model
{
    protected $fillable = ['code', 'store_id', 'amount', 'method', 'status', 'early_request', 'fee'];

    protected $casts = [
        'early_request' => 'bool',
        'amount' => 'float',
        'fee' => 'float',
    ];

    public function store() { return $this->belongsTo(Store::class); }
}
