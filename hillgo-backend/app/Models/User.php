<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * Note: role, status and wallet-affecting fields are intentionally NOT
     * mass-assignable from request input; they are set explicitly in code.
     */
    protected $fillable = [
        'name', 'email', 'phone', 'password', 'district_id', 'avatar', 'language',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'prefs' => 'array',
        ];
    }

    public function district() { return $this->belongsTo(District::class); }
    public function customerProfile() { return $this->hasOne(CustomerProfile::class); }
    public function riderProfile() { return $this->hasOne(RiderProfile::class); }
    public function courierProfile() { return $this->hasOne(CourierProfile::class); }
    public function store() { return $this->hasOne(Store::class); }
    public function addresses() { return $this->hasMany(Address::class); }
    public function paymentMethods() { return $this->hasMany(PaymentMethod::class); }
    public function walletTransactions() { return $this->hasMany(WalletTransaction::class); }
    public function sosContacts() { return $this->hasMany(SosContact::class); }
    public function appNotifications() { return $this->hasMany(AppNotification::class); }

    public function isAdmin(): bool
    {
        return in_array($this->role, ['super_admin', 'admin'], true);
    }
}
