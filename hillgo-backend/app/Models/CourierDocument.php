<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourierDocument extends Model
{
    protected $fillable = ['courier_profile_id', 'doc_key', 'title', 'status', 'file_path', 'expires_at'];

    protected $casts = [
        'expires_at' => 'date',
    ];
}
