<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RiderPayout extends Model
{
    protected $fillable = ['code', 'rider_id', 'amount', 'method', 'period_from', 'period_to', 'ref', 'tips', 'surge', 'deductions', 'note', 'status', 'source', 'paid_at'];

    protected $casts = [
        'amount' => 'float',
        'tips' => 'float',
        'surge' => 'float',
        'deductions' => 'float',
        'period_from' => 'date',
        'period_to' => 'date',
        'paid_at' => 'datetime',
    ];

    public function rider() { return $this->belongsTo(User::class, 'rider_id'); }
}
