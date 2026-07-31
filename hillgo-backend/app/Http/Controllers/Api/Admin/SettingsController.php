<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\AppSetting;
use App\Models\CourierProfile;
use App\Models\District;
use App\Models\Order;
use App\Models\Parcel;
use App\Models\PricingAudit;
use App\Models\PricingSetting;
use App\Models\Ride;
use App\Models\RiderProfile;
use App\Models\SosAlert;
use App\Models\Store;
use App\Models\Trip;
use App\Models\User;
use App\Services\Audit;
use App\Services\PricingService;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    // —— Settings ——

    public function getSettings()
    {
        return response()->json(AppSetting::pluck('value', 'key'));
    }

    public function saveSettings(Request $request)
    {
        $data = $request->validate([
            'orgName' => ['sometimes', 'string', 'max:150'],
            'orgEmail' => ['sometimes', 'email', 'max:190'],
            'orgPhone' => ['sometimes', 'string', 'max:40'],
            'orgAddress' => ['sometimes', 'string', 'max:300'],
            'timezone' => ['sometimes', 'string', 'max:64'],
            'twoFactor' => ['sometimes', 'boolean'],
            'emailAlerts' => ['sometimes', 'boolean'],
            'smsAlerts' => ['sometimes', 'boolean'],
        ]);
        foreach ($data as $key => $value) {
            AppSetting::updateOrCreate(['key' => $key], ['value' => $value]);
        }
        Audit::log('Settings saved', $request->user()->name);
        return $this->getSettings();
    }

    // —— Pricing ——

    public function getPricing(string $panel)
    {
        abort_unless(in_array($panel, ['customer', 'rider', 'merchant', 'courier'], true), 404);
        return response()->json(PricingService::get($panel));
    }

    public function savePricing(Request $request, string $panel)
    {
        abort_unless(in_array($panel, ['customer', 'rider', 'merchant', 'courier'], true), 404);
        $values = $request->validate(['values' => ['required', 'array']])['values'];

        $row = PricingSetting::firstOrCreate(['panel' => $panel], ['values' => []]);
        $prev = $row->values ?? [];

        // Only accept known fields for this panel; numbers coerced.
        $clean = [];
        foreach ($values as $field => $value) {
            if (! array_key_exists($field, $prev) && $prev !== []) {
                continue;
            }
            $clean[$field] = is_numeric($value) ? (float) $value : $value;
        }

        foreach ($clean as $field => $value) {
            if (($prev[$field] ?? null) != $value) {
                PricingAudit::create([
                    'panel' => $panel,
                    'field' => $field,
                    'old_value' => (string) ($prev[$field] ?? ''),
                    'new_value' => (string) $value,
                    'by' => $request->user()->name,
                    'by_user_id' => $request->user()->id,
                ]);
            }
        }

        $row->update(['values' => array_merge($prev, $clean)]);
        PricingService::forget($panel);
        Audit::log("Pricing saved: {$panel}", $request->user()->name, 'pricing');

        return response()->json($row->fresh()->values);
    }

    public function pricingAudit(Request $request)
    {
        $rows = PricingAudit::when($request->query('panel'), fn ($q, $panel) => $q->where('panel', $panel))
            ->latest()->limit(200)->get()
            ->map(fn ($a) => [
                'id' => $a->id, 'panel' => $a->panel, 'field' => $a->field,
                'oldValue' => $a->old_value, 'newValue' => $a->new_value,
                'by' => $a->by, 'at' => $a->created_at->toIso8601String(),
            ]);
        return response()->json($rows);
    }

    // —— Overview KPIs ——

    public function overview()
    {
        $revenue = (float) Ride::where('status', 'completed')->sum('fare')
            + (float) Order::where('status', 'delivered')->sum('total');

        $pendingKyc = RiderProfile::where('kyc_status', '!=', 'verified')->whereHas('user', fn ($q) => $q->where('role', 'rider'))->count()
            + CourierProfile::where('kyc_status', '!=', 'verified')->count();

        return response()->json([
            'revenue' => $revenue,
            'activeTrips' => Trip::whereIn('status', ['accepted', 'arriving', 'arrived', 'in_progress', 'picked_up', 'in_transit'])->count(),
            'foodOrders' => Order::where('channel', 'food')->count(),
            'issues' => $pendingKyc + User::where('role', 'customer')->where('status', 'suspended')->count(),
            'customers' => User::where('role', 'customer')->where('status', 'active')->count(),
            'riders' => RiderProfile::where('online', true)->whereHas('user', fn ($q) => $q->where('status', 'active'))->count(),
            'stores' => Store::where('status', 'active')->count(),
            'parcelsInTransit' => Parcel::whereIn('status', ['assigned', 'picked_up', 'in_transit'])->count(),
            'openDistricts' => District::where('status', 'open')->count(),
            'totalDistricts' => District::count(),
        ]);
    }

    public function customerDashboard()
    {
        return response()->json([
            'activeCustomers' => User::where('role', 'customer')->where('status', 'active')->count(),
            'ridesToday' => Ride::whereDate('created_at', today())->count(),
            'foodOrders' => Order::where('channel', 'food')->whereDate('created_at', today())->count(),
            'parcels' => Parcel::whereDate('created_at', today())->count(),
            'walletVolume' => (float) \App\Models\WalletTransaction::whereDate('created_at', today())->sum('amount'),
            'openSos' => SosAlert::where('status', 'active')->count(),
        ]);
    }

    public function riderDashboard()
    {
        return response()->json([
            'onlineRiders' => RiderProfile::where('online', true)->count(),
            'tripsToday' => Trip::whereDate('created_at', today())->count(),
            'earningsPool' => (float) Trip::where('status', 'completed')->whereDate('completed_at', today())->sum('earning'),
            'pendingKyc' => RiderProfile::where('kyc_status', '!=', 'verified')->count(),
            'pendingPayouts' => \App\Models\RiderPayout::whereIn('status', ['pending', 'processing'])->count(),
        ]);
    }

    public function merchantDashboard()
    {
        return response()->json([
            'activeStores' => Store::where('status', 'active')->count(),
            'ordersToday' => Order::whereDate('created_at', today())->count(),
            'gmv' => (float) Order::whereDate('created_at', today())->whereNotIn('status', ['rejected', 'cancelled'])->sum('total'),
            'pendingPayouts' => \App\Models\MerchantPayout::where('status', 'pending')->count(),
            'avgRating' => round((float) Store::where('rating', '>', 0)->avg('rating'), 2),
            'storesInClosedDistricts' => Store::whereHas('district', fn ($q) => $q->where('status', 'closed'))->count(),
        ]);
    }

    public function courierDashboard()
    {
        return response()->json([
            'activeAgents' => User::where('role', 'courier_agent')->where('status', 'active')->count(),
            'inTransit' => Parcel::where('fulfillment_channel', 'courier')->whereIn('status', ['picked_up', 'in_transit'])->count(),
            'deliveredToday' => Parcel::where('fulfillment_channel', 'courier')->whereDate('delivered_at', today())->count(),
            'pendingWithdrawals' => \App\Models\CourierWithdrawal::where('status', 'pending')->count(),
            'activeIncentives' => \App\Models\Incentive::where('active', true)->count(),
        ]);
    }

    // —— Activity log ——

    public function activity()
    {
        return response()->json(
            ActivityLog::latest()->limit(100)->get()->map(fn ($l) => [
                'id' => $l->id, 'text' => $l->text, 'by' => $l->by, 'at' => $l->created_at->toIso8601String(),
            ])
        );
    }
}
