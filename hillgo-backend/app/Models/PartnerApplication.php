<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PartnerApplication extends Model
{
    protected $fillable = ['full_name', 'phone', 'email', 'vehicle_type', 'city', 'district_id', 'status', 'rider_user_id'];

    public function district()
    {
        return $this->belongsTo(District::class);
    }
}
