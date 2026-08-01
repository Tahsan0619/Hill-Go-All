<?php

namespace App\Support;

/**
 * Turn relative /storage/... paths into absolute URLs for mobile/web clients.
 */
final class Media
{
    public static function url(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        // Bare public-disk keys (e.g. stores/1/x.jpg from older onboarding) → /storage/...
        $key = StoredFiles::publicKey($path);
        if ($key !== null) {
            return url('/storage/'.$key);
        }

        return url(str_starts_with($path, '/') ? $path : '/'.$path);
    }

    /** @param  list<string>|null  $paths */
    public static function urls(?array $paths): array
    {
        if ($paths === null || $paths === []) {
            return [];
        }

        return array_values(array_filter(array_map(
            fn ($p) => is_string($p) ? self::url($p) : null,
            $paths
        )));
    }
}
