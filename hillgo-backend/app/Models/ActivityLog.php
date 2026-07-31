<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    protected $fillable = ['text', 'by', 'by_user_id', 'category'];

    public function byUser() { return $this->belongsTo(User::class, 'by_user_id'); }
}
