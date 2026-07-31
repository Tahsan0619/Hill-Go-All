<?php

namespace App\Services;

use App\Models\PricingSetting;
use Illuminate\Support\Facades\Cache;

class PricingService
{
    public static function get(string $panel): array
    {
        return Cache::remember("pricing.$panel", 60, function () use ($panel) {
            $row = PricingSetting::where('panel', $panel)->first();
            return $row?->values ?? [];
        });
    }

    public static function forget(string $panel): void
    {
        Cache::forget("pricing.$panel");
    }

    /** Customer ride fare (server-authoritative). Returns breakdown. */
    public static function rideFare(float $km, float $min, string $vehicleType = 'bike', float $surge = 1.0): array
    {
        $p = self::get('customer');
        $r = self::get('rider');
        $base = (float) ($p['rideBase'] ?? 30);
        $perKm = (float) ($p['ridePerKm'] ?? 15);
        $perMin = (float) ($p['ridePerMin'] ?? 1);
        $minimum = (float) ($p['rideMinimum'] ?? 50);
        $multiplier = (float) ($r[$vehicleType . 'Multiplier'] ?? 1.0);

        $fare = max($minimum, $base + $km * $perKm + $min * $perMin);
        $vehicleFare = max(50, round($fare * $multiplier * $surge));

        return [
            'base' => $base, 'per_km' => $perKm, 'per_min' => $perMin,
            'minimum' => $minimum, 'multiplier' => $multiplier, 'surge' => $surge,
            'distance_km' => $km, 'duration_min' => $min,
            'fare' => $vehicleFare, 'currency' => 'BDT',
        ];
    }

    /** Customer parcel fare. */
    public static function parcelFare(float $km, float $kg, string $priority = 'standard'): array
    {
        $p = self::get('customer');
        $c = self::get('courier');
        $base = (float) ($p['parcelBase'] ?? 40);
        $perKm = (float) ($p['parcelPerKm'] ?? 12);
        $perKg = (float) ($p['parcelPerKg'] ?? 8);
        $minimum = (float) ($p['parcelMinimum'] ?? 50);

        $fare = max($minimum, round($base + $km * $perKm + $kg * $perKg));
        $multiplier = match ($priority) {
            'express' => (float) ($c['expressMultiplier'] ?? 1.4),
            'priority' => (float) ($c['priorityMultiplier'] ?? 1.25),
            default => 1.0,
        };
        $total = round($fare * $multiplier);

        return [
            'base' => $base, 'per_km' => $perKm, 'per_kg' => $perKg, 'minimum' => $minimum,
            'priority' => $priority, 'multiplier' => $multiplier,
            'distance_km' => $km, 'weight_kg' => $kg,
            'fare' => $total, 'currency' => 'BDT',
        ];
    }

    /** Rider earning for a job (before commission). */
    public static function riderEarning(string $type, float $km, float $min = 0, float $kg = 0, string $vehicleType = 'bike', float $surge = 1.0): float
    {
        $r = self::get('rider');
        if ($type === 'food') {
            return round((float) ($r['foodJobFee'] ?? 30) * $surge);
        }
        if ($type === 'parcel') {
            $base = (float) ($r['parcelBase'] ?? 40);
            $fare = max((float) ($r['parcelMinimum'] ?? 50), round($base + $km * (float) ($r['parcelPerKm'] ?? 12) + $kg * (float) ($r['parcelPerKg'] ?? 8)));
            return round($fare * $surge);
        }
        $base = (float) ($r['rideBase'] ?? 30);
        $fare = max((float) ($r['rideMinimum'] ?? 50), round($base + $km * (float) ($r['ridePerKm'] ?? 15) + $min * (float) ($r['ridePerMin'] ?? 1)));
        $mult = (float) ($r[$vehicleType . 'Multiplier'] ?? 1.0);
        return max(50, round($fare * $mult * $surge));
    }

    /** Courier parcel earning (before commission). */
    public static function courierEarning(float $km, float $kg, string $priority = 'standard', float $surgeBonus = 0): float
    {
        $c = self::get('courier');
        $base = (float) ($c['parcelBase'] ?? 50) + $km * (float) ($c['perKm'] ?? 12) + $kg * (float) ($c['perKg'] ?? 8);
        $mult = match ($priority) {
            'express' => (float) ($c['expressMultiplier'] ?? 1.4),
            'priority' => (float) ($c['priorityMultiplier'] ?? 1.25),
            default => 1.0,
        };
        $surgeBonus = min($surgeBonus, (float) ($c['surgeCap'] ?? 100));
        return round($base * $mult + $surgeBonus);
    }
}
