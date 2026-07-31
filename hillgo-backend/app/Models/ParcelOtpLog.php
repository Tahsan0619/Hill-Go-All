<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ParcelOtpLog extends Model
{
    protected $fillable = ['parcel_id', 'stage', 'success', 'by_user_id'];

    protected $casts = [
        'success' => 'bool',
    ];
}
