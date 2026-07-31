<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Store extends Model
{
    use SoftDeletes;

    // status / balance are set explicitly — never mass-assignable from request input.
    protected $fillable = ['code', 'user_id', 'name', 'owner_name', 'category', 'subcategories', 'description', 'specialties', 'bio', 'address', 'city', 'district_id', 'zip', 'lat', 'lng', 'is_open', 'accepting_orders', 'hours', 'banner', 'logo', 'profile_strength', 'free_delivery', 'eta_label'];

    protected $casts = [
        'subcategories' => 'array',
        'hours' => 'array',
        'is_open' => 'bool',
        'accepting_orders' => 'bool',
        'free_delivery' => 'bool',
        'rating' => 'float',
        'balance' => 'float',
        'lat' => 'float',
        'lng' => 'float',
    ];

    public function owner() { return $this->belongsTo(User::class, 'user_id'); }
    public function products() { return $this->hasMany(Product::class); }
    public function categories() { return $this->hasMany(ProductCategory::class); }
    public function district() { return $this->belongsTo(District::class); }
}
