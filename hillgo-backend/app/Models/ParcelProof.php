<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ParcelProof extends Model
{
    protected $fillable = ['parcel_id', 'type', 'file_path'];
}
