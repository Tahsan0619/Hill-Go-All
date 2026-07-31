<?php

namespace App\Services;

use App\Jobs\DeliverAppNotification;
use App\Models\User;

class Notifier
{
    /** Notify a specific user (their role inbox + unread badge). */
    public static function user(User|int|null $user, string $title, string $body = '', string $type = 'general', array $data = []): void
    {
        if (! $user) {
            return;
        }
        $u = $user instanceof User ? $user : User::find($user);
        if (! $u) {
            return;
        }

        DeliverAppNotification::dispatch($u->id, $u->role, $title, $body, $type, $data);
    }

    /** Broadcast to all admins (user_id null, role admin). */
    public static function admins(string $title, string $body = '', string $type = 'general', array $data = []): void
    {
        DeliverAppNotification::dispatch(null, 'admin', $title, $body, $type, $data);
    }
}
