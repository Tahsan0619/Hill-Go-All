<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourierProfile extends Model
{
    // nid / kyc_status / balance are NOT mass-assignable (PII / privilege / money).
    protected $fillable = ['user_id', 'code', 'vehicle_type', 'vehicle_name', 'plate', 'verified', 'bank_verified', 'bank_last4', 'online', 'lat', 'lng', 'last_location_at'];

    protected $casts = [
        'nid' => 'encrypted', // PII: encrypted at rest
        'verified' => 'bool',
        'bank_verified' => 'bool',
        'online' => 'bool',
        'rating' => 'float',
        'balance' => 'float',
        'lat' => 'float',
        'lng' => 'float',
        'last_location_at' => 'datetime',
        'kyc_submitted_at' => 'datetime',
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function documents() { return $this->hasMany(CourierDocument::class); }
}
