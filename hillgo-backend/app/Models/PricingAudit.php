<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PricingAudit extends Model
{
    protected $fillable = ['panel', 'field', 'old_value', 'new_value', 'by', 'by_user_id'];

    public function byUser() { return $this->belongsTo(User::class, 'by_user_id'); }
}
