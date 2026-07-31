<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RentalBooking extends Model
{
    protected $fillable = ['code', 'vehicle_id', 'customer_id', 'pickup_location', 'dropoff_location', 'start_date', 'end_date', 'days', 'with_driver', 'renter_name', 'renter_phone', 'vehicle_total', 'driver_fee', 'insurance_fee', 'total', 'status'];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'with_driver' => 'bool',
        'vehicle_total' => 'float',
        'driver_fee' => 'float',
        'insurance_fee' => 'float',
        'total' => 'float',
    ];

    public function vehicle() { return $this->belongsTo(RentalVehicle::class, 'vehicle_id'); }
    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
}
