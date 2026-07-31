<?php

namespace App\Services;

class Phone
{
    /** Normalize BD mobiles to +8801XXXXXXXXX when possible. */
    public static function normalize(?string $raw): ?string
    {
        if ($raw === null || trim($raw) === '') {
            return $raw;
        }

        $digits = preg_replace('/\D+/', '', $raw) ?? '';
        if ($digits === '') {
            return trim($raw);
        }
        if (str_starts_with($digits, '880')) {
            return '+'.$digits;
        }
        if (str_starts_with($digits, '0')) {
            return '+88'.$digits;
        }
        if (strlen($digits) === 10 && str_starts_with($digits, '1')) {
            return '+880'.$digits;
        }

        return trim($raw);
    }

    /** Candidate forms for DB lookup (normalized + common raw variants). */
    public static function lookupVariants(?string $raw): array
    {
        if ($raw === null || trim($raw) === '') {
            return [];
        }

        $trimmed = trim($raw);
        $normalized = self::normalize($trimmed);
        $digits = preg_replace('/\D+/', '', $trimmed) ?? '';

        $variants = array_filter([
            $trimmed,
            $normalized,
            $digits !== '' ? $digits : null,
            (str_starts_with($digits, '880') && strlen($digits) >= 13)
                ? '0'.substr($digits, 3)
                : null,
        ]);

        return array_values(array_unique($variants));
    }
}
