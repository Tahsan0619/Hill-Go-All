<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class LoyaltyReward extends Model
{
    use SoftDeletes;

    protected $fillable = ['title', 'description', 'points', 'type', 'active'];

    protected $casts = [
        'active' => 'bool',
    ];
}
