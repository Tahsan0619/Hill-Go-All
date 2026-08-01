<?php

namespace App\Support;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

/**
 * Consistent public/private disk paths + cleanup on replace/delete.
 *
 * Public disk keys are stored in DB as "/storage/{key}" so Media::url and
 * the public/storage symlink stay in sync.
 */
final class StoredFiles
{
    /** Store on public disk; returns "/storage/..." path for DB. */
    public static function putPublic(UploadedFile $file, string $directory): string
    {
        $key = $file->store($directory, 'public');

        return '/storage/'.$key;
    }

    /** Replace a public file; deletes the previous object when present. */
    public static function replacePublic(?string $oldPath, UploadedFile $file, string $directory): string
    {
        self::deletePublic($oldPath);

        return self::putPublic($file, $directory);
    }

    public static function deletePublic(?string $path): void
    {
        $key = self::publicKey($path);
        if ($key !== null && Storage::disk('public')->exists($key)) {
            Storage::disk('public')->delete($key);
        }
    }

    /** Store on private (local) disk; returns relative key for DB. */
    public static function putPrivate(UploadedFile $file, string $directory): string
    {
        return $file->store($directory, 'local');
    }

    public static function replacePrivate(?string $oldKey, UploadedFile $file, string $directory): string
    {
        self::deletePrivate($oldKey);

        return self::putPrivate($file, $directory);
    }

    public static function deletePrivate(?string $key): void
    {
        if ($key === null || $key === '') {
            return;
        }
        $key = ltrim(str_replace('\\', '/', $key), '/');
        if (Storage::disk('local')->exists($key)) {
            Storage::disk('local')->delete($key);
        }
    }

    /** Normalize any public media reference to a DB "/storage/..." path. */
    public static function asPublicDbPath(?string $path): ?string
    {
        $key = self::publicKey($path);

        return $key !== null ? '/storage/'.$key : null;
    }

    /** Absolute filesystem path for an admin-served private or public key. */
    public static function absolute(?string $path, string $disk = 'local'): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }
        if ($disk === 'public') {
            $key = self::publicKey($path);
            if ($key === null) {
                return null;
            }
            $full = storage_path('app/public/'.$key);

            return is_file($full) ? $full : null;
        }

        $key = ltrim(str_replace('\\', '/', $path), '/');
        // Legacy mistaken storefront-in-docs paths lived on public disk.
        if (str_starts_with($key, 'stores/')) {
            $public = storage_path('app/public/'.$key);
            if (is_file($public)) {
                return $public;
            }
        }
        $full = storage_path('app/private/'.$key);

        return is_file($full) ? $full : null;
    }

    /** Normalize DB value to a public-disk relative key, or null. */
    public static function publicKey(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            $path = parse_url($path, PHP_URL_PATH) ?: '';
        }
        $path = str_replace('\\', '/', $path);
        if (str_starts_with($path, '/storage/')) {
            return ltrim(substr($path, strlen('/storage/')), '/');
        }
        if (str_starts_with($path, 'storage/')) {
            return ltrim(substr($path, strlen('storage/')), '/');
        }
        // Bare relative keys written before path normalization.
        if (preg_match('#^(products|stores)/#', $path)) {
            return ltrim($path, '/');
        }

        return null;
    }
}
