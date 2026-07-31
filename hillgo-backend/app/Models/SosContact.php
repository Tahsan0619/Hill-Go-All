<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SosContact extends Model
{
    protected $fillable = ['user_id', 'name', 'phone', 'relation'];
}
