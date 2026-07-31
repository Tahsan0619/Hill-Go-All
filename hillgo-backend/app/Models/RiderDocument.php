<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RiderDocument extends Model
{
    protected $fillable = ['rider_profile_id', 'doc_key', 'title', 'status', 'file_path', 'token_number', 'note'];
}
