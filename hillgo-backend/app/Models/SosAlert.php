<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SosAlert extends Model
{
    protected $fillable = ['user_id', 'type', 'location_label', 'lat', 'lng', 'status', 'resolved_at', 'resolved_by', 'resolved_by_user_id'];

    public function resolvedByUser() { return $this->belongsTo(User::class, 'resolved_by_user_id'); }

    protected $casts = [
        'resolved_at' => 'datetime',
        'lat' => 'float',
        'lng' => 'float',
    ];

    public function user() { return $this->belongsTo(User::class); }
}
