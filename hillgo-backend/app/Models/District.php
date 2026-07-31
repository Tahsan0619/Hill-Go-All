<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class District extends Model
{
    protected $fillable = ['id', 'division_id', 'name', 'status', 'opened_at', 'allow_customer', 'allow_rider', 'allow_merchant', 'allow_courier', 'note', 'updated_by', 'updated_by_user_id'];

    public function updatedByUser() { return $this->belongsTo(User::class, 'updated_by_user_id'); }

    protected $casts = [
        'allow_customer' => 'bool',
        'allow_rider' => 'bool',
        'allow_merchant' => 'bool',
        'allow_courier' => 'bool',
        'opened_at' => 'datetime',
    ];

    protected $keyType = 'string';
    public $incrementing = false;

    public function division() { return $this->belongsTo(Division::class); }
}
