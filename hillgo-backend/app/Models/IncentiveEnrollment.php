<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IncentiveEnrollment extends Model
{
    protected $fillable = ['incentive_id', 'courier_id', 'progress', 'completed'];

    protected $casts = [
        'completed' => 'bool',
    ];
}
