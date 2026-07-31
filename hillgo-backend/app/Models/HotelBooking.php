<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HotelBooking extends Model
{
    protected $fillable = ['code', 'hotel_id', 'customer_id', 'check_in', 'check_out', 'nights', 'guests', 'rooms', 'guest_name', 'guest_phone', 'room_total', 'service_fee', 'total', 'status'];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'room_total' => 'float',
        'service_fee' => 'float',
        'total' => 'float',
    ];

    public function hotel() { return $this->belongsTo(Hotel::class); }
    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
}
