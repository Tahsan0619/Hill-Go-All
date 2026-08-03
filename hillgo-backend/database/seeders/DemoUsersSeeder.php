<?php

namespace Database\Seeders;

use App\Models\CourierProfile;
use App\Models\CustomerProfile;
use App\Models\MerchantOnboarding;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\RiderProfile;
use App\Models\Store;
use App\Models\User;
use App\Services\Codes;
use Illuminate\Database\Seeder;

/**
 * Local/dev demo accounts only. Never run in production.
 * Gate: SEED_DEMO_USERS=true  (or: php artisan db:seed --class=DemoUsersSeeder)
 */
class DemoUsersSeeder extends Seeder
{
    public const DEMO_OTP = '1234';

    public function run(): void
    {
        // Defense in depth: even if SEED_DEMO_USERS is accidentally left on in an
        // env file, this seeder must never create demo/test accounts in production.
        if (app()->environment('production')) {
            throw new \RuntimeException('DemoUsersSeeder must never run with APP_ENV=production.');
        }

        $password = env('SEED_DEMO_PASSWORD', 'HillGoDemo@2026!');
        $district = 'dhaka__dhaka';

        $this->seedCustomer($password, $district);
        $this->seedRider($password, $district);
        $this->seedMerchant($password, $district);
        $this->seedCourier($password, $district);
    }

    private function seedCustomer(string $password, string $district): void
    {
        $user = User::firstOrNew(['email' => 'customer@demo.hillgo.app']);
        $user->fill([
            'name' => 'Demo Customer',
            'phone' => '+8801710000001',
            'district_id' => $district,
        ]);
        $user->password = $password;
        $user->role = 'customer';
        $user->status = 'active';
        $user->save();

        CustomerProfile::firstOrCreate(
            ['user_id' => $user->id],
            ['code' => Codes::make('HG'), 'tier' => 'Bronze']
        );
        $profile = CustomerProfile::where('user_id', $user->id)->first();
        if ((float) $profile->wallet_balance <= 0) {
            $profile->wallet_balance = 500;
            $profile->save();
        }
    }

    private function seedRider(string $password, string $district): void
    {
        $user = User::firstOrNew(['email' => 'rider@demo.hillgo.app']);
        $user->fill([
            'name' => 'Demo Rider',
            'phone' => '+8801710000002',
            'district_id' => $district,
        ]);
        $user->password = $password;
        $user->role = 'rider';
        $user->status = 'active';
        $user->save();

        $profile = RiderProfile::firstOrNew(['user_id' => $user->id]);
        if (! $profile->exists) {
            $profile->code = Codes::make('HG-RD');
        }
        $profile->fill([
            'vehicle_type' => 'bike',
            'vehicle_make' => 'Honda',
            'vehicle_model' => 'CB',
            'plate' => 'DHAKA-DEMO-02',
            'legal_name' => 'Demo Rider',
        ]);
        $profile->kyc_status = 'verified';
        $profile->save();
    }

    private function seedMerchant(string $password, string $district): void
    {
        $user = User::firstOrNew(['email' => 'merchant@demo.hillgo.app']);
        $user->fill([
            'name' => 'Demo Merchant',
            'phone' => '+8801710000003',
            'district_id' => $district,
        ]);
        $user->password = $password;
        $user->role = 'merchant';
        $user->status = 'active';
        $user->save();

        $store = Store::firstOrNew(['user_id' => $user->id]);
        if (! $store->exists) {
            $store->code = Codes::make('HG-MRT');
        }
        $store->fill([
            'name' => 'Demo Kitchen',
            'owner_name' => 'Demo Merchant',
            // Must match FoodController::FOOD_CATEGORIES so customer food listing works.
            'category' => 'Restaurant & Cafe',
            'description' => 'HillGo demo merchant store',
            'address' => 'Gulshan 1, Dhaka',
            'city' => 'Dhaka',
            'district_id' => $district,
            'is_open' => true,
            'accepting_orders' => true,
            'eta_label' => '25-35 min',
            'profile_strength' => 80,
        ]);
        $store->status = 'active';
        $store->save();

        MerchantOnboarding::updateOrCreate(
            ['user_id' => $user->id],
            [
                'store_id' => $store->id,
                'business_name' => 'Demo Kitchen',
                'description' => 'HillGo demo merchant store',
                'owner' => 'Demo Merchant',
                'category' => 'Restaurant & Cafe',
                'phone' => '+8801710000003',
                'email' => 'merchant@demo.hillgo.app',
                'address' => 'Gulshan 1, Dhaka',
                'city' => 'Dhaka',
                'district_id' => $district,
                'status' => 'approved',
            ]
        );

        $category = ProductCategory::firstOrCreate(
            ['store_id' => $store->id, 'name' => 'Mains'],
            ['is_visible' => true, 'sort_order' => 0]
        );

        $biryani = Product::firstOrCreate(
            ['store_id' => $store->id, 'name' => 'Demo Biryani'],
            [
                'category_id' => $category->id,
                'description' => 'Signature demo dish for cross-app testing',
                'price' => 220,
                'stock' => 100,
                'track_stock' => false,
                'status' => 'active',
                'images' => [
                    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&h=400&fit=crop',
                ],
            ]
        );
        if (empty($biryani->images)) {
            $biryani->update([
                'images' => [
                    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&h=400&fit=crop',
                ],
            ]);
        }

        $drink = Product::firstOrCreate(
            ['store_id' => $store->id, 'name' => 'Demo Soft Drink'],
            [
                'category_id' => $category->id,
                'description' => 'Cold drink add-on',
                'price' => 40,
                'stock' => 200,
                'track_stock' => false,
                'status' => 'active',
                'images' => [
                    'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=600&h=400&fit=crop',
                ],
            ]
        );
        if (empty($drink->images)) {
            $drink->update([
                'images' => [
                    'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=600&h=400&fit=crop',
                ],
            ]);
        }

        if (! $store->banner) {
            $store->update([
                'banner' => 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&h=400&fit=crop',
                'logo' => 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&h=200&fit=crop',
            ]);
        }
    }

    private function seedCourier(string $password, string $district): void
    {
        $user = User::firstOrNew(['email' => 'courier@demo.hillgo.app']);
        $user->fill([
            'name' => 'Demo Courier',
            'phone' => '+8801710000004',
            'district_id' => $district,
        ]);
        $user->password = $password;
        $user->role = 'courier_agent';
        $user->status = 'active';
        $user->save();

        $profile = CourierProfile::firstOrNew(['user_id' => $user->id]);
        if (! $profile->exists) {
            $profile->code = Codes::make('CG');
        }
        $profile->fill([
            'vehicle_type' => 'Motorbike',
            'vehicle_name' => 'Demo Bike',
            'plate' => 'DHAKA-DEMO-04',
            'verified' => true,
        ]);
        $profile->kyc_status = 'verified';
        $profile->save();
    }

    /** Phones that accept the fixed local demo OTP. */
    public static function demoPhones(): array
    {
        return [
            '+8801710000001',
            '+8801710000002',
            '+8801710000003',
            '+8801710000004',
            '01710000001',
            '01710000002',
            '01710000003',
            '01710000004',
            '1710000001',
            '1710000002',
            '1710000003',
            '1710000004',
        ];
    }
}
