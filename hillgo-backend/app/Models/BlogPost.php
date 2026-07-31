<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BlogPost extends Model
{
    protected $fillable = ['title', 'slug', 'body', 'author', 'cover_image', 'published_at'];

    protected $casts = [
        'published_at' => 'datetime',
    ];
}
