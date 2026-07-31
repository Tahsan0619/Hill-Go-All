<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\Request;

/** Role-scoped DB notification inbox shared by all apps + Admin. */
class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = AppNotification::query()->latest();

        if ($user->isAdmin()) {
            $query->where('role', 'admin');
        } else {
            $query->where('user_id', $user->id);
        }

        $rows = $query->paginate(min((int) $request->query('per_page', 30), 100));
        $unread = (clone $query)->getQuery()->whereNull('read_at')->count();

        return response()->json([
            'data' => $rows->items(),
            'unread' => $unread,
            'total' => $rows->total(),
            'current_page' => $rows->currentPage(),
            'last_page' => $rows->lastPage(),
        ]);
    }

    public function markRead(Request $request, AppNotification $notification)
    {
        $this->authorizeRow($request, $notification);
        $notification->update(['read_at' => now()]);
        return response()->json($notification);
    }

    public function markAllRead(Request $request)
    {
        $user = $request->user();
        $q = AppNotification::whereNull('read_at');
        $user->isAdmin() ? $q->where('role', 'admin') : $q->where('user_id', $user->id);
        $q->update(['read_at' => now()]);
        return response()->json(['message' => 'All read.']);
    }

    public function destroy(Request $request, AppNotification $notification)
    {
        $this->authorizeRow($request, $notification);
        $notification->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    private function authorizeRow(Request $request, AppNotification $notification): void
    {
        $user = $request->user();
        $owns = $user->isAdmin()
            ? $notification->role === 'admin'
            : $notification->user_id === $user->id;
        abort_unless($owns, 403, 'Forbidden.');
    }
}
