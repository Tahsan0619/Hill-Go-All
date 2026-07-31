<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductCategory extends Model
{
    protected $fillable = ['store_id', 'name', 'icon', 'color', 'is_visible', 'sort_order'];

    protected $casts = [
        'is_visible' => 'bool',
    ];

    public function products() { return $this->hasMany(Product::class, 'category_id'); }
}
