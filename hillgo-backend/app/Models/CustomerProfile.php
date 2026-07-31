<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CustomerProfile extends Model
{
    // wallet_balance intentionally NOT fillable — only Wallet::adjust may mutate it.
    protected $fillable = ['user_id', 'code', 'tier', 'loyalty_points', 'orders_count', 'rating'];

    protected $casts = [
        'wallet_balance' => 'float',
        'rating' => 'float',
    ];

    public function user() { return $this->belongsTo(User::class); }
}
