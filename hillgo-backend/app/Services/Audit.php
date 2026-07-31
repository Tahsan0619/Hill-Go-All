<?php

namespace App\Services;

use App\Models\ActivityLog;

class Audit
{
    /**
     * Append-only activity/audit log. `by` is a display label only; the
     * authoritative attribution is `by_user_id` (authenticated user).
     */
    public static function log(string $text, ?string $by = null, ?string $category = null, ?int $byUserId = null): void
    {
        ActivityLog::create([
            'text' => $text,
            'by' => $by ?? (auth()->user()?->name ?? 'System'),
            'by_user_id' => $byUserId ?? auth()->id(),
            'category' => $category,
        ]);
    }
}
