<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Ride extends Model
{
    use SoftDeletes;

    protected $fillable = ['code', 'customer_id', 'rider_id', 'vehicle_type', 'pickup', 'drop', 'pickup_lat', 'pickup_lng', 'drop_lat', 'drop_lng', 'distance_km', 'duration_min', 'fare', 'surge', 'status', 'payment_method', 'rating', 'rating_comment', 'cancel_reason', 'completed_at', 'district_id'];

    protected $casts = [
        'distance_km' => 'float',
        'fare' => 'float',
        'surge' => 'float',
        'completed_at' => 'datetime',
        'pickup_lat' => 'float',
        'pickup_lng' => 'float',
        'drop_lat' => 'float',
        'drop_lng' => 'float',
    ];

    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
    public function rider() { return $this->belongsTo(User::class, 'rider_id'); }
}
