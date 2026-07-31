<?php

namespace App\Support;

use Illuminate\Validation\ValidationException;

/** Server-side geo helpers — client distance/weight inputs are never trusted blindly. */
class Geo
{
    /**
     * Haversine distance in km between two WGS84 points.
     */
    public static function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earth = 6371.0;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        return round($earth * 2 * atan2(sqrt($a), sqrt(1 - $a)), 2);
    }

    /**
     * When both endpoints have coordinates, recompute distance server-side and
     * reject a client-reported km that diverges beyond tolerance.
     * Returns the distance that must be used for pricing.
     */
    public static function trustedDistanceKm(
        float $clientKm,
        ?float $pickupLat,
        ?float $pickupLng,
        ?float $dropLat,
        ?float $dropLng,
        float $relTolerance = 0.30,
        float $absToleranceKm = 2.0,
    ): float {
        if ($pickupLat === null || $pickupLng === null || $dropLat === null || $dropLng === null) {
            // No coords to verify against — clamp to a sane upper bound.
            if ($clientKm > 500) {
                throw ValidationException::withMessages(['distance_km' => 'Distance exceeds the maximum allowed.']);
            }

            return round($clientKm, 2);
        }

        $computed = self::haversineKm($pickupLat, $pickupLng, $dropLat, $dropLng);
        // Road distance is typically longer than straight-line; allow up to ~1.6× haversine.
        $roadEstimate = max($computed, round($computed * 1.35, 2));
        $delta = abs($clientKm - $roadEstimate);
        $allowed = max($absToleranceKm, $roadEstimate * $relTolerance);

        if ($delta > $allowed) {
            // Prefer the server estimate rather than trusting a inflated client value.
            return $roadEstimate;
        }

        return round($clientKm, 2);
    }
}
