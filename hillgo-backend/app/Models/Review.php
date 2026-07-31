<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = ['store_id', 'customer_id', 'order_id', 'rating', 'comment', 'verified', 'reply', 'replied_at', 'images', 'hidden'];

    protected $casts = [
        'verified' => 'bool',
        'hidden' => 'bool',
        'images' => 'array',
        'replied_at' => 'datetime',
    ];

    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
    public function store() { return $this->belongsTo(Store::class); }
}
