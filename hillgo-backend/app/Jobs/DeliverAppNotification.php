<?php

namespace App\Jobs;

use App\Models\AppNotification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

/** Persist an in-app notification off the request path. */
class DeliverAppNotification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public ?int $userId,
        public string $role,
        public string $title,
        public string $body,
        public string $type,
        public array $data = [],
    ) {}

    public function handle(): void
    {
        AppNotification::create([
            'user_id' => $this->userId,
            'role' => $this->role,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type,
            'data' => $this->data,
        ]);
    }
}
