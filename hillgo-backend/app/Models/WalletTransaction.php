<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WalletTransaction extends Model
{
    protected $fillable = ['user_id', 'title', 'amount', 'direction', 'ref_type', 'ref_id', 'note', 'balance_after'];

    protected $casts = [
        'amount' => 'float',
        'balance_after' => 'float',
    ];
}
