<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MerchantOnboarding extends Model
{
    protected $fillable = ['store_id', 'user_id', 'business_name', 'description', 'owner', 'category', 'subcategories', 'phone', 'email', 'address', 'city', 'district_id', 'zip', 'docs', 'logo_path', 'storefront_path', 'status'];

    protected $casts = [
        'subcategories' => 'array',
        'docs' => 'array',
    ];

    public function district() { return $this->belongsTo(District::class); }
    public function store() { return $this->belongsTo(Store::class); }
    public function user() { return $this->belongsTo(User::class); }
}
