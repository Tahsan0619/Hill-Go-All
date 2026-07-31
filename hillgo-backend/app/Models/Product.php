<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use SoftDeletes;

    protected $fillable = ['store_id', 'category_id', 'name', 'description', 'price', 'sku', 'stock', 'low_stock_alert', 'track_stock', 'images', 'status', 'marketplace_category'];

    protected $casts = [
        'images' => 'array',
        'track_stock' => 'bool',
        'price' => 'float',
        'rating' => 'float',
    ];

    public function store() { return $this->belongsTo(Store::class); }
    public function category() { return $this->belongsTo(ProductCategory::class, 'category_id'); }
}
