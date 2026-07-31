<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Trip extends Model
{
    use SoftDeletes;

    protected $fillable = ['code', 'type', 'rider_id', 'customer_id', 'ref_type', 'ref_id', 'pickup_name', 'pickup_address', 'pickup_lat', 'pickup_lng', 'drop_name', 'drop_address', 'drop_lat', 'drop_lng', 'distance_km', 'duration_min', 'earning', 'tip', 'payment_method', 'cod_amount', 'surge', 'vehicle_required', 'weight_kg', 'package_label', 'status', 'offered_at', 'offer_expires_at', 'declined_rider_ids', 'accepted_at', 'completed_at'];

    protected $casts = [
        'distance_km' => 'float',
        'earning' => 'float',
        'tip' => 'float',
        'cod_amount' => 'float',
        'surge' => 'float',
        'weight_kg' => 'float',
        'declined_rider_ids' => 'array',
        'offered_at' => 'datetime',
        'offer_expires_at' => 'datetime',
        'accepted_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    public function rider() { return $this->belongsTo(User::class, 'rider_id'); }
    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
}
