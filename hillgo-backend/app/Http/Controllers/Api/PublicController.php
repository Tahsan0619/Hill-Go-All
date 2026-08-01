<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\BlogPost;
use App\Models\ContactInquiry;
use App\Models\District;
use App\Models\Faq;
use App\Models\NewsletterSubscriber;
use App\Models\Parcel;
use App\Models\PartnerApplication;
use App\Models\Ride;
use App\Models\Testimonial;
use App\Services\Audit;
use App\Services\Notifier;
use App\Services\PricingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;

class PublicController extends Controller
{
    /** 3.1 Contact inquiry */
    public function contact(Request $request)
    {
        $data = $request->validate([
            'first_name' => ['required', 'string', 'max:80'],
            'last_name' => ['required', 'string', 'max:80'],
            'email' => ['required', 'email', 'max:190'],
            'service_interest' => ['required', 'in:Ride-Hailing,Food Delivery,Parcel Logistics,Merchant Partnership,Consulting'],
            'message' => ['required', 'string', 'max:5000'],
        ]);

        $inquiry = ContactInquiry::create($data);
        Notifier::admins('New contact inquiry', "{$inquiry->first_name} {$inquiry->last_name} — {$inquiry->service_interest}", 'contact', ['inquiry_id' => $inquiry->id]);
        Audit::log("Contact inquiry from {$inquiry->email} ({$inquiry->service_interest})", 'Public Web');

        return response()->json(['message' => 'Thanks — our team will reach out shortly.', 'id' => $inquiry->id], 201);
    }

    /** 3.2 Partner / driver application (Region Lock enforced) */
    public function partnerApplication(Request $request)
    {
        $data = $request->validate([
            'full_name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:32'],
            'email' => ['required', 'email', 'max:190'],
            'vehicle_type' => ['required', 'in:Car,Bike,Scooter'],
            'city' => ['required', 'string', 'max:120'],
        ]);

        $district = $this->resolveDistrict($data['city']);
        if (! $district) {
            throw ValidationException::withMessages(['city' => 'We could not match this city to a Bangladesh district.']);
        }
        if ($district->status !== 'open' || ! $district->allow_rider) {
            throw ValidationException::withMessages(['city' => "HillGo rider onboarding is not open in {$district->name} yet."]);
        }

        $app = PartnerApplication::create(array_merge($data, ['district_id' => $district->id]));
        Notifier::admins('New partner application', "{$app->full_name} — {$app->vehicle_type} ({$district->name})", 'partner_application', ['application_id' => $app->id]);
        Audit::log("Partner application: {$app->full_name} ({$district->name})", 'Public Web', 'kyc');

        return response()->json(['message' => 'Application received. Our onboarding team will contact you.', 'id' => $app->id], 201);
    }

    /** 3.3 Ride / parcel quote from live Admin pricing (BDT) */
    public function quote(Request $request)
    {
        $data = $request->validate([
            'type' => ['required', 'in:ride,parcel'],
            'origin' => ['required', 'string', 'max:190'],
            'destination' => ['required', 'string', 'max:190'],
            'distance_km' => ['nullable', 'numeric', 'min:0.1', 'max:1000'],
            'duration_min' => ['nullable', 'numeric', 'min:0', 'max:2000'],
            'weight_kg' => ['nullable', 'numeric', 'min:0.1', 'max:500'],
            'vehicle_type' => ['nullable', 'in:bike,car,xl'],
        ]);

        // Public quote uses provided distance or a conservative default estimate.
        $km = (float) ($data['distance_km'] ?? 8);
        if ($data['type'] === 'ride') {
            $breakdown = PricingService::rideFare($km, (float) ($data['duration_min'] ?? $km * 3), $data['vehicle_type'] ?? 'car');
        } else {
            $breakdown = PricingService::parcelFare($km, (float) ($data['weight_kg'] ?? 1));
        }

        return response()->json([
            'type' => $data['type'],
            'origin' => $data['origin'],
            'destination' => $data['destination'],
            'estimated' => empty($data['distance_km']),
            'quote' => $breakdown,
        ]);
    }

    /** 3.4 Public tracking — sanitized timeline */
    public function track(string $code)
    {
        $parcel = Parcel::where('code', $code)->first();
        if ($parcel) {
            $publicStatus = match ($parcel->status) {
                'booked', 'assigned' => 'booked',
                'picked_up' => 'picked_up',
                'in_transit' => 'in_transit',
                'delivered' => 'delivered',
                'failed' => 'failed',
                default => 'cancelled',
            };
            $steps = ['booked', 'picked_up', 'in_transit', 'delivered'];
            $idx = array_search($publicStatus, $steps, true);
            $timeline = array_map(fn ($s, $i) => [
                'step' => $s,
                'done' => $idx !== false && $i <= $idx,
                'at' => match ($s) {
                    'booked' => $parcel->created_at?->toIso8601String(),
                    'picked_up' => $parcel->picked_up_at?->toIso8601String(),
                    'delivered' => $parcel->delivered_at?->toIso8601String(),
                    default => null,
                },
            ], $steps, array_keys($steps));

            return response()->json([
                'code' => $parcel->code,
                'kind' => 'parcel',
                'status' => $publicStatus,
                'from' => $parcel->pickup_address,
                'to' => $parcel->drop_address,
                'timeline' => $timeline,
            ]);
        }

        $ride = Ride::where('code', $code)->first();
        if ($ride) {
            return response()->json([
                'code' => $ride->code,
                'kind' => 'ride',
                'status' => $ride->status,
                'from' => $ride->pickup,
                'to' => $ride->drop,
            ]);
        }

        return response()->json(['message' => 'No shipment found for this tracking number.'], 404);
    }

    /** District directory for app registration pickers (Region Lock flags included). */
    public function districts()
    {
        $payload = Cache::remember('public.districts.v1', 300, function () {
            return District::with('division')->orderBy('name')->get()->map(fn ($d) => [
                'id' => $d->id,
                'name' => $d->name,
                'division' => $d->division?->name,
                'open' => $d->status === 'open',
                'allow_customer' => (bool) $d->allow_customer,
                'allow_rider' => (bool) $d->allow_rider,
                'allow_merchant' => (bool) $d->allow_merchant,
                'allow_courier' => (bool) $d->allow_courier,
            ])->values()->all();
        });

        return response()->json($payload);
    }

    /** 3.5 City availability → Region Lock */
    public function availability(Request $request)
    {
        $data = $request->validate(['city' => ['required', 'string', 'max:120']]);
        $district = $this->resolveDistrict($data['city']);

        if (! $district) {
            return response()->json([
                'available' => false,
                'message' => 'City not recognized. Try one of the 64 Bangladesh districts.',
            ]);
        }

        return response()->json([
            'available' => $district->status === 'open',
            'district' => $district->name,
            'division' => $district->division?->name,
            'allow_customer' => (bool) $district->allow_customer,
            'allow_rider' => (bool) $district->allow_rider,
            'allow_merchant' => (bool) $district->allow_merchant,
            'allow_courier' => (bool) $district->allow_courier,
        ]);
    }

    /** 3.6 Newsletter */
    public function newsletter(Request $request)
    {
        $data = $request->validate(['email' => ['required', 'email', 'max:190']]);
        $row = NewsletterSubscriber::firstOrCreate(['email' => strtolower($data['email'])]);
        return response()->json(['message' => 'Subscribed.', 'already' => ! $row->wasRecentlyCreated]);
    }

    public function faq()
    {
        return response()->json(
            Faq::where('active', true)->orderBy('category')->orderBy('sort')->get()
        );
    }

    public function blog()
    {
        return response()->json(
            BlogPost::whereNotNull('published_at')->where('published_at', '<=', now())
                ->latest('published_at')
                ->get(['id', 'title', 'slug', 'author', 'cover_image', 'published_at'])
        );
    }

    public function blogPost(string $slug)
    {
        $post = BlogPost::where('slug', $slug)->whereNotNull('published_at')->firstOrFail();
        return response()->json($post);
    }

    /** Homepage aggregate: testimonials, contact strip, pricing display */
    public function homeContent()
    {
        $settings = AppSetting::whereIn('key', ['orgName', 'orgEmail', 'orgPhone', 'orgAddress'])
            ->pluck('value', 'key');

        return response()->json([
            'testimonials' => Testimonial::where('active', true)->orderBy('sort')->get(),
            'contact' => $settings,
            'pricing' => [
                'customer' => PricingService::get('customer'),
            ],
        ]);
    }

    /**
     * Proxied driving directions. Clients send coordinates to HillGo only;
     * the backend may call a routing provider server-side (never required of apps).
     */
    public function route(Request $request)
    {
        $data = $request->validate([
            'from_lat' => ['required', 'numeric', 'between:-90,90'],
            'from_lng' => ['required', 'numeric', 'between:-180,180'],
            'to_lat' => ['required', 'numeric', 'between:-90,90'],
            'to_lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        $url = sprintf(
            'https://router.project-osrm.org/route/v1/driving/%F,%F;%F,%F?overview=full&geometries=geojson&steps=true&annotations=false',
            $data['from_lng'],
            $data['from_lat'],
            $data['to_lng'],
            $data['to_lat'],
        );

        try {
            $raw = Cache::remember('osrm:'.md5($url), 30, function () use ($url) {
                $ch = curl_init($url);
                curl_setopt_array($ch, [
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_TIMEOUT => 12,
                    CURLOPT_HTTPHEADER => ['User-Agent: HillGo-Backend/1.0'],
                    CURLOPT_FOLLOWLOCATION => true,
                ]);
                $body = curl_exec($ch);
                $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
                if ($code !== 200 || ! is_string($body)) {
                    return null;
                }

                return $body;
            });
        } catch (\Throwable $e) {
            $raw = null;
        }

        if ($raw) {
            return response($raw, 200, ['Content-Type' => 'application/json']);
        }

        // Offline / provider-down fallback: straight-line geometry (still HillGo-owned).
        $fromLat = (float) $data['from_lat'];
        $fromLng = (float) $data['from_lng'];
        $toLat = (float) $data['to_lat'];
        $toLng = (float) $data['to_lng'];
        $distanceM = $this->haversineMeters($fromLat, $fromLng, $toLat, $toLng);
        $durationS = max(60, $distanceM / 8.3); // ~30 km/h

        return response()->json([
            'code' => 'Ok',
            'routes' => [[
                'distance' => $distanceM,
                'duration' => $durationS,
                'geometry' => [
                    'type' => 'LineString',
                    'coordinates' => [[$fromLng, $fromLat], [$toLng, $toLat]],
                ],
                'legs' => [[
                    'steps' => [
                        [
                            'name' => '',
                            'distance' => $distanceM,
                            'duration' => $durationS,
                            'maneuver' => [
                                'type' => 'depart',
                                'modifier' => 'straight',
                                'location' => [$fromLng, $fromLat],
                            ],
                        ],
                        [
                            'name' => '',
                            'distance' => 0,
                            'duration' => 0,
                            'maneuver' => [
                                'type' => 'arrive',
                                'modifier' => '',
                                'location' => [$toLng, $toLat],
                            ],
                        ],
                    ],
                ]],
            ]],
        ]);
    }

    private function haversineMeters(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earth = 6371000.0;
        $r1 = deg2rad($lat1);
        $r2 = deg2rad($lat2);
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos($r1) * cos($r2) * sin($dLng / 2) ** 2;

        return 2 * $earth * asin(min(1, sqrt($a)));
    }

    /** Map a free-text city to a district row (name or district containing city name). */
    private function resolveDistrict(string $city): ?District
    {
        $needle = trim($city);
        return District::whereRaw('LOWER(name) = ?', [mb_strtolower($needle)])->first()
            ?? District::where('name', 'like', "%{$needle}%")->first();
    }
}
