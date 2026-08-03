<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class LoyaltyRedemption extends Model
{
    use SoftDeletes;

    protected $fillable = ['user_id', 'reward_id', 'points'];
}
