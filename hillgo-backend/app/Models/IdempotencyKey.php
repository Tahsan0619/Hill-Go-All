<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IdempotencyKey extends Model
{
    protected $fillable = [
        'user_id', 'method', 'path', 'key', 'request_fingerprint', 'response_status', 'response_body', 'expires_at',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];
}
