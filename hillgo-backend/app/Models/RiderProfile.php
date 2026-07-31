<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RiderProfile extends Model
{
    // kyc_status / kyc_* flags are set explicitly by onboarding & admin — never mass-assignable.
    // balance is never fillable (Wallet::adjustRider only).
    protected $fillable = ['user_id', 'code', 'vehicle_type', 'vehicle_make', 'vehicle_model', 'vehicle_year', 'plate', 'vehicle_photo', 'online', 'lat', 'lng', 'last_location_at', 'online_since', 'online_seconds_today', 'payout_method', 'legal_name', 'home_address', 'dob', 'nid'];

    protected $casts = [
        'nid' => 'encrypted', // PII: encrypted at rest
        'online' => 'bool',
        'kyc_priority' => 'bool',
        'kyc_flagged' => 'bool',
        'lat' => 'float',
        'lng' => 'float',
        'rating' => 'float',
        'balance' => 'float',
        'last_location_at' => 'datetime',
        'online_since' => 'datetime',
        'kyc_submitted_at' => 'datetime',
        'dob' => 'date',
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function documents() { return $this->hasMany(RiderDocument::class); }
}
