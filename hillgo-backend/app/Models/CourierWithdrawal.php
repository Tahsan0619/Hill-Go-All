<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourierWithdrawal extends Model
{
    protected $fillable = ['code', 'courier_id', 'amount', 'method', 'bank_last4', 'status'];

    protected $casts = [
        'amount' => 'float',
    ];

    public function courier() { return $this->belongsTo(User::class, 'courier_id'); }
}
