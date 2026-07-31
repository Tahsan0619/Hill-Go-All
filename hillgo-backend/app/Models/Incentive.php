<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Incentive extends Model
{
    protected $fillable = ['code', 'title', 'description', 'multiplier', 'district', 'goal_deliveries', 'bonus_tk', 'valid_until', 'active'];

    protected $casts = [
        'multiplier' => 'float',
        'bonus_tk' => 'float',
        'active' => 'bool',
        'valid_until' => 'date',
    ];
}
