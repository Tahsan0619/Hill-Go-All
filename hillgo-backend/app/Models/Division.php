<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Division extends Model
{
    protected $fillable = ['id', 'name', 'zone'];

    protected $keyType = 'string';
    public $incrementing = false;

    public function districts() { return $this->hasMany(District::class); }
}
