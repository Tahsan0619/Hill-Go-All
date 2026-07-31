<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use SoftDeletes;

    protected $fillable = ['code', 'store_id', 'customer_id', 'channel', 'priority', 'scheduled_for', 'status', 'subtotal', 'service_fee', 'tax', 'delivery_fee', 'discount', 'total', 'payment_method', 'delivery_address', 'customer_note', 'promo_code', 'delivered_at', 'rating', 'district_id'];

    protected $casts = [
        'scheduled_for' => 'datetime',
        'delivered_at' => 'datetime',
        'subtotal' => 'float',
        'service_fee' => 'float',
        'tax' => 'float',
        'delivery_fee' => 'float',
        'discount' => 'float',
        'total' => 'float',
    ];

    public function store() { return $this->belongsTo(Store::class); }
    public function customer() { return $this->belongsTo(User::class, 'customer_id'); }
    public function items() { return $this->hasMany(OrderItem::class); }
    public function district() { return $this->belongsTo(District::class); }

    /** Customer-facing status mapping (placed|preparing|on_the_way|delivered|cancelled) */
    public function customerStatus(): string
    {
        return match ($this->status) {
            'new_order' => 'placed',
            'preparing' => 'preparing',
            'ready', 'on_the_way' => 'on_the_way',
            'delivered' => 'delivered',
            default => 'cancelled',
        };
    }
}
