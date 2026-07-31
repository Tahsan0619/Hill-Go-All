<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Parcel extends Model
{
    use SoftDeletes;

    protected $fillable = ['code', 'customer_id', 'type', 'priority', 'fulfillment_channel', 'courier_id', 'rider_id', 'sender_name', 'sender_phone', 'pickup_address', 'pickup_lat', 'pickup_lng', 'receiver_name', 'receiver_phone', 'drop_address', 'drop_lat', 'drop_lng', 'weight_kg', 'distance_km', 'fare', 'earnings', 'surge_bonus', 'status', 'pickup_otp_hash', 'delivery_otp_hash', 'fail_reason', 'fragile', 'notes', 'payment_method', 'picked_up_at', 'delivered_at', 'district_id'];

    protected $casts = [
        'weight_kg' => 'float',
        'distance_km' => 'float',
        'fare' => 'float',
        'earnings' => 'float',
        'surge_bonus' => 'float',
        'fragile' => 'bool',
        'picked_up_at' => 'datetime',
        'delivered_at' => 'datetime',
    ];

    protected $hidden = ['pickup_otp_hash', 'delivery_otp_hash'];

    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
    public function courier() { return $this->belongsTo(User::class, 'courier_id'); }
    public function rider() { return $this->belongsTo(User::class, 'rider_id'); }
    public function otpLogs() { return $this->hasMany(ParcelOtpLog::class); }
}
