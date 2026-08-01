<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\CourierProfile;
use App\Models\Parcel;
use App\Models\ParcelOtpLog;
use App\Models\ParcelProof;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class ParcelController extends Controller
{
    public function assigned(Request $request)
    {
        $limit = min(50, max(1, (int) $request->query('per_page', 50)));
        $rows = Parcel::where('courier_id', $request->user()->id)
            ->whereIn('status', ['assigned', 'picked_up', 'in_transit'])
            ->latest()->limit($limit)->get();

        return response()->json($rows->map(fn ($p) => $this->shape($p)));
    }

    public function history(Request $request)
    {
        $perPage = min(50, max(1, (int) $request->query('per_page', 30)));
        $rows = Parcel::where('courier_id', $request->user()->id)
            ->whereIn('status', ['delivered', 'failed'])
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhere('pickup_address', 'like', "%$q%")->orWhere('drop_address', 'like', "%$q%")
                    ->orWhere('receiver_name', 'like', "%$q%"));
            })
            ->when($request->query('period') === 'today', fn ($q) => $q->whereDate('updated_at', today()))
            ->when($request->query('period') === 'week', fn ($q) => $q->where('updated_at', '>=', now()->startOfWeek()))
            ->when($request->query('period') === 'month', fn ($q) => $q->where('updated_at', '>=', now()->startOfMonth()))
            ->latest('updated_at')->paginate($perPage);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => $this->shape($p)),
            'total' => $rows->total(),
        ]);
    }

    public function show(Request $request, Parcel $parcel)
    {
        $this->authorizeParcel($request, $parcel);
        return response()->json($this->shape($parcel));
    }

    public function pickupOtp(Request $request, Parcel $parcel)
    {
        $this->authorizeParcel($request, $parcel);
        abort_unless($parcel->status === 'assigned', 422, 'Parcel is not awaiting pickup.');

        $data = $request->validate(['otp' => ['required', 'string', 'digits:4']]);
        $ok = $parcel->pickup_otp_hash && Hash::check($data['otp'], $parcel->pickup_otp_hash);

        ParcelOtpLog::create(['parcel_id' => $parcel->id, 'stage' => 'pickup', 'success' => $ok, 'by_user_id' => $request->user()->id]);

        if (! $ok) {
            $this->throttleAttempts($parcel, 'pickup');
            throw ValidationException::withMessages(['otp' => 'Incorrect pickup OTP.']);
        }

        $parcel->update(['status' => 'picked_up', 'picked_up_at' => now()]);
        Notifier::user($parcel->customer_id, 'Parcel picked up', "Parcel {$parcel->code} was collected by the courier.", 'parcel', ['parcel_id' => $parcel->id]);

        return response()->json($this->shape($parcel->fresh()));
    }

    public function startTransit(Request $request, Parcel $parcel)
    {
        $this->authorizeParcel($request, $parcel);
        abort_unless($parcel->status === 'picked_up', 422, 'Pick up the parcel first.');
        $parcel->update(['status' => 'in_transit']);
        Notifier::user($parcel->customer_id, 'Parcel in transit', "Parcel {$parcel->code} is on the way.", 'parcel', ['parcel_id' => $parcel->id]);
        return response()->json($this->shape($parcel->fresh()));
    }

    public function deliveryOtp(Request $request, Parcel $parcel)
    {
        $this->authorizeParcel($request, $parcel);
        abort_unless(in_array($parcel->status, ['picked_up', 'in_transit'], true), 422, 'Parcel is not out for delivery.');

        $data = $request->validate(['otp' => ['required', 'string', 'digits:4']]);
        $ok = $parcel->delivery_otp_hash && Hash::check($data['otp'], $parcel->delivery_otp_hash);

        ParcelOtpLog::create(['parcel_id' => $parcel->id, 'stage' => 'delivery', 'success' => $ok, 'by_user_id' => $request->user()->id]);

        if (! $ok) {
            $this->throttleAttempts($parcel, 'delivery');
            throw ValidationException::withMessages(['otp' => 'Incorrect delivery OTP.']);
        }

        DB::transaction(function () use ($parcel, $request) {
            $parcel->update(['status' => 'delivered', 'delivered_at' => now()]);

            // Credit courier: earnings + surge − commission (ledger-backed).
            $pricing = PricingService::get('courier');
            $commissionPct = (float) ($pricing['platformCommissionPct'] ?? 12);
            $net = round(($parcel->earnings + $parcel->surge_bonus) * (1 - $commissionPct / 100), 2);

            Wallet::adjustCourier($request->user()->id, $net, "Parcel {$parcel->code} earnings", 'parcel', $parcel->id,
                "Net of {$commissionPct}% commission");
            CourierProfile::where('user_id', $request->user()->id)->increment('deliveries_count');

            // Progress active incentive enrollments.
            \App\Models\IncentiveEnrollment::where('courier_id', $request->user()->id)->where('completed', false)
                ->get()->each(function ($enrollment) use ($request) {
                    $enrollment->increment('progress');
                    $incentive = $enrollment->incentive ?? \App\Models\Incentive::find($enrollment->incentive_id);
                    if ($incentive && $incentive->goal_deliveries > 0 && $enrollment->progress >= $incentive->goal_deliveries) {
                        $enrollment->update(['completed' => true]);
                        Wallet::adjustCourier($request->user()->id, (float) $incentive->bonus_tk,
                            "Incentive bonus: {$incentive->title}", 'incentive', $incentive->id);
                        Notifier::user($request->user()->id, 'Incentive goal reached!', "{$incentive->title}: bonus ৳{$incentive->bonus_tk} credited.", 'incentive');
                    }
                });
        });

        Notifier::user($parcel->customer_id, 'Parcel delivered', "Parcel {$parcel->code} was delivered successfully.", 'parcel', ['parcel_id' => $parcel->id]);
        Notifier::user($request->user(), 'Delivery complete', "৳{$parcel->earnings} earned for {$parcel->code}.", 'earning');

        return response()->json($this->shape($parcel->fresh()));
    }

    public function fail(Request $request, Parcel $parcel)
    {
        $this->authorizeParcel($request, $parcel);
        abort_if(in_array($parcel->status, ['delivered', 'failed', 'cancelled'], true), 422, 'Parcel already finished.');

        $data = $request->validate(['reason' => ['required', 'string', 'max:300']]);
        $parcel->update(['status' => 'failed', 'fail_reason' => $data['reason']]);

        Notifier::user($parcel->customer_id, 'Delivery failed', "Parcel {$parcel->code}: {$data['reason']}. Our team will follow up.", 'parcel', ['parcel_id' => $parcel->id]);
        Notifier::admins('Parcel delivery failed', "{$parcel->code}: {$data['reason']}", 'parcel', ['parcel_id' => $parcel->id]);

        return response()->json($this->shape($parcel->fresh()));
    }

    /** Photo / signature proof when OTP is unavailable (audited alternative). */
    public function proof(Request $request, Parcel $parcel)
    {
        $this->authorizeParcel($request, $parcel);
        $data = $request->validate([
            'type' => ['required', 'in:photo,signature'],
            'file' => ['required', 'file', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
        ]);

        $path = \App\Support\StoredFiles::putPrivate($request->file('file'), 'proofs/' . $parcel->id);
        $proof = ParcelProof::create(['parcel_id' => $parcel->id, 'type' => $data['type'], 'file_path' => $path]);

        return response()->json(['message' => 'Proof stored.', 'id' => $proof->id], 201);
    }

    private function authorizeParcel(Request $request, Parcel $parcel): void
    {
        abort_unless($parcel->courier_id === $request->user()->id, 403);
    }

    private function throttleAttempts(Parcel $parcel, string $stage): void
    {
        $failures = ParcelOtpLog::where('parcel_id', $parcel->id)->where('stage', $stage)
            ->where('success', false)->where('created_at', '>=', now()->subMinutes(10))->count();
        if ($failures >= 5) {
            Notifier::admins('OTP abuse suspected', "Parcel {$parcel->code}: {$failures} failed {$stage} OTP attempts.", 'security');
            abort(429, 'Too many attempts. Try again later.');
        }
    }

    private function shape(Parcel $p): array
    {
        return [
            'id' => $p->id,
            'order_id' => $p->code,
            'code' => $p->code,
            'type' => $p->type,
            'priority' => $p->priority,
            'status' => $p->status,
            'sender_name' => $p->sender_name,
            'sender_phone' => $p->sender_phone,
            'pickup_address' => $p->pickup_address,
            'pickup_lat' => $p->pickup_lat, 'pickup_lng' => $p->pickup_lng,
            'receiver_name' => $p->receiver_name,
            'receiver_phone' => $p->receiver_phone,
            'drop_address' => $p->drop_address,
            'drop_lat' => $p->drop_lat, 'drop_lng' => $p->drop_lng,
            'weight_kg' => (float) $p->weight_kg,
            'distance_km' => (float) $p->distance_km,
            'estimated_earnings' => (float) $p->earnings,
            'surge_bonus' => (float) $p->surge_bonus,
            'notes' => $p->notes,
            'fragile' => (bool) $p->fragile,
            'customer_name' => $p->sender_name,
            'created_at' => $p->created_at->toIso8601String(),
            'picked_up_at' => $p->picked_up_at?->toIso8601String(),
            'delivered_at' => $p->delivered_at?->toIso8601String(),
            'fail_reason' => $p->fail_reason,
        ];
    }
}
