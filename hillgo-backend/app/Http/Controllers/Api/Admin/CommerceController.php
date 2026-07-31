<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use App\Models\HotelBooking;
use App\Models\LoyaltyReward;
use App\Models\LoyaltyTier;
use App\Models\Product;
use App\Models\Promo;
use App\Models\RentalBooking;
use App\Models\RentalVehicle;
use App\Services\Audit;
use Illuminate\Http\Request;

/**
 * Admin Customer Panel expansions (§22): marketplace catalog,
 * hotels, rentals, wallet & loyalty config, promos.
 */
class CommerceController extends Controller
{
    // —— Marketplace products (admin-managed rows live on merchant stores) ——

    public function products(Request $request)
    {
        $rows = Product::with('store')
            ->whereNotNull('marketplace_category')
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->when($request->query('category') && $request->query('category') !== 'all',
                fn ($q) => $q->where('marketplace_category', $request->query('category')))
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'name' => $p->name,
                'category' => $p->marketplace_category,
                'price' => (float) $p->price,
                'status' => $p->status,
                'image' => $p->images[0] ?? null,
                'store' => $p->store?->name,
                'storeId' => $p->store_id,
                'rating' => (float) $p->rating,
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function updateProduct(Request $request, int $id)
    {
        $product = Product::findOrFail($id);
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:190'],
            'category' => ['sometimes', 'string', 'max:64'],
            'price' => ['sometimes', 'numeric', 'min:0'],
            'status' => ['sometimes', 'in:active,hidden'],
            'image' => ['sometimes', 'nullable', 'string', 'max:500'],
            'description' => ['sometimes', 'nullable', 'string', 'max:2000'],
        ]);

        $patch = collect($data)->only(['name', 'price', 'status', 'description'])->all();
        if (isset($data['category'])) {
            $patch['marketplace_category'] = $data['category'];
        }
        if (array_key_exists('image', $data)) {
            $patch['images'] = $data['image'] ? [$data['image']] : [];
        }
        $product->update($patch);
        Audit::log("Marketplace product updated: {$product->name}", $request->user()->name);
        return response()->json($product->fresh());
    }

    public function deleteProduct(Request $request, int $id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
        Audit::log("Marketplace product deleted: {$product->name}", $request->user()->name);
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Hotels ——

    public function hotels(Request $request)
    {
        $rows = Hotel::latest()->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function storeHotel(Request $request)
    {
        $data = $this->validateHotel($request);
        $hotel = Hotel::create($data);
        Audit::log("Hotel created: {$hotel->name}", $request->user()->name);
        return response()->json($hotel, 201);
    }

    public function updateHotel(Request $request, int $id)
    {
        $hotel = Hotel::findOrFail($id);
        $hotel->update($this->validateHotel($request, false));
        Audit::log("Hotel updated: {$hotel->name}", $request->user()->name);
        return response()->json($hotel->fresh());
    }

    public function deleteHotel(Request $request, int $id)
    {
        Hotel::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    public function hotelBookings(Request $request)
    {
        $rows = HotelBooking::with(['hotel', 'customer'])
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($b) => [
                'id' => $b->id, 'code' => $b->code, 'hotel' => $b->hotel?->name,
                'customer' => $b->customer?->name, 'checkIn' => $b->check_in->toDateString(),
                'checkOut' => $b->check_out->toDateString(), 'nights' => $b->nights,
                'rooms' => $b->rooms, 'amount' => (float) $b->total, 'status' => $b->status,
            ]),
            'total' => $rows->total(),
        ]);
    }

    // —— Rentals ——

    public function rentals(Request $request)
    {
        $rows = RentalVehicle::latest()->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function storeRental(Request $request)
    {
        $vehicle = RentalVehicle::create($this->validateRental($request));
        Audit::log("Rental vehicle created: {$vehicle->name}", $request->user()->name);
        return response()->json($vehicle, 201);
    }

    public function updateRental(Request $request, int $id)
    {
        $vehicle = RentalVehicle::findOrFail($id);
        $vehicle->update($this->validateRental($request, false));
        return response()->json($vehicle->fresh());
    }

    public function deleteRental(Request $request, int $id)
    {
        RentalVehicle::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    public function rentalBookings(Request $request)
    {
        $rows = RentalBooking::with(['vehicle', 'customer'])
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($b) => [
                'id' => $b->id, 'code' => $b->code, 'vehicle' => $b->vehicle?->name,
                'customer' => $b->customer?->name, 'start' => $b->start_date->toDateString(),
                'end' => $b->end_date->toDateString(), 'days' => $b->days,
                'withDriver' => (bool) $b->with_driver, 'amount' => (float) $b->total, 'status' => $b->status,
            ]),
            'total' => $rows->total(),
        ]);
    }

    // —— Loyalty config ——

    public function loyalty()
    {
        return response()->json([
            'tiers' => LoyaltyTier::orderBy('sort')->get(),
            'rewards' => LoyaltyReward::latest()->get(),
        ]);
    }

    public function saveTier(Request $request, int $id)
    {
        $tier = LoyaltyTier::findOrFail($id);
        $data = $request->validate(['threshold' => ['required', 'integer', 'min:0']]);
        $tier->update($data);
        Audit::log("Loyalty tier {$tier->name} threshold → {$data['threshold']}", $request->user()->name, 'pricing');
        return response()->json($tier->fresh());
    }

    public function storeReward(Request $request)
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string', 'max:300'],
            'points' => ['required', 'integer', 'min:1'],
            'type' => ['nullable', 'string', 'max:32'],
            'active' => ['nullable', 'boolean'],
        ]);
        $reward = LoyaltyReward::create($data + ['description' => $data['description'] ?? '', 'type' => $data['type'] ?? 'voucher', 'active' => $data['active'] ?? true]);
        return response()->json($reward, 201);
    }

    public function updateReward(Request $request, int $id)
    {
        $reward = LoyaltyReward::findOrFail($id);
        $reward->update($request->validate([
            'title' => ['sometimes', 'string', 'max:150'],
            'description' => ['sometimes', 'nullable', 'string', 'max:300'],
            'points' => ['sometimes', 'integer', 'min:1'],
            'active' => ['sometimes', 'boolean'],
        ]));
        return response()->json($reward->fresh());
    }

    public function deleteReward(int $id)
    {
        LoyaltyReward::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Promos ——

    public function promos(Request $request)
    {
        $rows = Promo::latest()->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function storePromo(Request $request)
    {
        $data = $this->validatePromo($request);
        $promo = Promo::create($data);
        Audit::log("Promo created: {$promo->code}", $request->user()->name, 'pricing');
        return response()->json($promo, 201);
    }

    public function updatePromo(Request $request, int $id)
    {
        $promo = Promo::findOrFail($id);
        $promo->update($this->validatePromo($request, false, $id));
        Audit::log("Promo updated: {$promo->code}", $request->user()->name, 'pricing');
        return response()->json($promo->fresh());
    }

    public function deletePromo(int $id)
    {
        Promo::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Validators ——

    private function validateHotel(Request $request, bool $create = true): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'name' => [$req, 'string', 'max:190'],
            'location' => [$req, 'string', 'max:190'],
            'stars' => ['nullable', 'integer', 'between:1,5'],
            'price_per_night' => [$req, 'numeric', 'min:0'],
            'amenities' => ['nullable', 'array'],
            'description' => ['nullable', 'string', 'max:2000'],
            'image' => ['nullable', 'string', 'max:500'],
            'active' => ['nullable', 'boolean'],
        ]);
    }

    private function validateRental(Request $request, bool $create = true): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'name' => [$req, 'string', 'max:190'],
            'category' => [$req, 'in:Car,SUV,Bike,Scooter,Van'],
            'price_per_day' => [$req, 'numeric', 'min:0'],
            'seats' => ['nullable', 'integer', 'min:1'],
            'transmission' => ['nullable', 'string', 'max:32'],
            'fuel' => ['nullable', 'string', 'max:32'],
            'description' => ['nullable', 'string', 'max:2000'],
            'image' => ['nullable', 'string', 'max:500'],
            'features' => ['nullable', 'array'],
            'active' => ['nullable', 'boolean'],
        ]);
    }

    private function validatePromo(Request $request, bool $create = true, ?int $ignoreId = null): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'title' => [$req, 'string', 'max:150'],
            'description' => ['nullable', 'string', 'max:300'],
            'code' => [$req, 'string', 'max:32', 'unique:promos,code' . ($ignoreId ? ",$ignoreId" : '')],
            'type' => [$req, 'in:ride_percent,free_delivery,wallet_cashback,amount_off'],
            'value' => ['nullable', 'numeric', 'min:0'],
            'min_order_tk' => ['nullable', 'numeric', 'min:0'],
            'expires_at' => ['nullable', 'date'],
            'active' => ['nullable', 'boolean'],
            'usage_limit' => ['nullable', 'integer', 'min:1'],
        ]);
    }
}
