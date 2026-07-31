<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use App\Models\District;
use App\Models\Division;
use App\Models\LoyaltyReward;
use App\Models\LoyaltyTier;
use App\Models\PricingSetting;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * STRUCTURAL SEED ONLY (prompt §0A.B):
 * 8 divisions + 64 districts, default pricing, one super_admin,
 * settings row, loyalty tier thresholds. No demo entities.
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedRegions();
        $this->seedPricing();
        $this->seedAdmin();
        $this->seedSettings();
        $this->seedLoyalty();

        // Demo accounts are opt-in only (never production).
        if (filter_var(env('SEED_DEMO_USERS', false), FILTER_VALIDATE_BOOLEAN)) {
            $this->call(DemoUsersSeeder::class);
        }
    }

    private function seedRegions(): void
    {
        $divisions = [
            ['id' => 'dhaka', 'name' => 'Dhaka', 'zone' => 'Central Hub', 'districts' => ['Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur', 'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur', 'Tangail']],
            ['id' => 'chattogram', 'name' => 'Chattogram', 'zone' => 'Coastal Hub', 'districts' => ['Bandarban', 'Brahmanbaria', 'Chandpur', 'Chattogram', 'Cumilla', "Cox's Bazar", 'Feni', 'Khagrachhari', 'Lakshmipur', 'Noakhali', 'Rangamati']],
            ['id' => 'rajshahi', 'name' => 'Rajshahi', 'zone' => 'Northwest', 'districts' => ['Bogura', 'Chapainawabganj', 'Joypurhat', 'Naogaon', 'Natore', 'Pabna', 'Rajshahi', 'Sirajganj']],
            ['id' => 'khulna', 'name' => 'Khulna', 'zone' => 'Southwest', 'districts' => ['Bagerhat', 'Chuadanga', 'Jashore', 'Jhenaidah', 'Khulna', 'Kushtia', 'Magura', 'Meherpur', 'Narail', 'Satkhira']],
            ['id' => 'barishal', 'name' => 'Barishal', 'zone' => 'Southern', 'districts' => ['Barguna', 'Barishal', 'Bhola', 'Jhalokathi', 'Patuakhali', 'Pirojpur']],
            ['id' => 'sylhet', 'name' => 'Sylhet', 'zone' => 'Northeast', 'districts' => ['Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet']],
            ['id' => 'rangpur', 'name' => 'Rangpur', 'zone' => 'Northern Zone', 'districts' => ['Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Rangpur', 'Thakurgaon']],
            ['id' => 'mymensingh', 'name' => 'Mymensingh', 'zone' => 'North-Central', 'districts' => ['Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur']],
        ];

        // Default open map mirrors current product state: Dhaka (minus Gazipur),
        // most of Chattogram, Khulna and part of Barishal open; rest closed.
        $closedDefaults = [
            'Gazipur', 'Bandarban', 'Khagrachhari', 'Rangamati',
            'Bogura', 'Chapainawabganj', 'Joypurhat', 'Naogaon', 'Natore', 'Pabna', 'Rajshahi', 'Sirajganj',
            'Barguna', 'Pirojpur',
            'Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet',
            'Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Rangpur', 'Thakurgaon',
            'Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur',
        ];

        foreach ($divisions as $div) {
            Division::updateOrCreate(['id' => $div['id']], ['name' => $div['name'], 'zone' => $div['zone']]);
            foreach ($div['districts'] as $name) {
                $closed = in_array($name, $closedDefaults, true);
                District::updateOrCreate(
                    ['id' => $div['id'] . '__' . Str::slug($name)],
                    [
                        'division_id' => $div['id'],
                        'name' => $name,
                        'status' => $closed ? 'closed' : 'open',
                        'opened_at' => $closed ? null : now(),
                        'allow_customer' => ! $closed,
                        'allow_rider' => ! $closed,
                        'allow_merchant' => ! $closed,
                        'allow_courier' => ! $closed,
                        'updated_by' => 'Seeder',
                    ]
                );
            }
        }
    }

    private function seedPricing(): void
    {
        $pricing = [
            'customer' => [
                'rideBase' => 30, 'ridePerKm' => 15, 'ridePerMin' => 1, 'rideMinimum' => 50,
                'foodDeliveryFee' => 30, 'freeDeliveryThreshold' => 300,
                'parcelBase' => 40, 'parcelPerKm' => 12, 'parcelPerKg' => 8, 'parcelMinimum' => 50,
                'marketplaceDelivery' => 40, 'hotelServiceFeePct' => 5,
                'rentalDriverPerDay' => 1500, 'rentalInsurancePerDay' => 300,
            ],
            'rider' => [
                'rideBase' => 30, 'ridePerKm' => 15, 'ridePerMin' => 1, 'rideMinimum' => 50,
                'bikeMultiplier' => 0.7, 'carMultiplier' => 1.0, 'xlMultiplier' => 1.5,
                'foodJobFee' => 30, 'parcelBase' => 40, 'parcelPerKm' => 12, 'parcelPerKg' => 8, 'parcelMinimum' => 50,
                'defaultSurge' => 1.8, 'platformCommissionPct' => 15,
            ],
            'merchant' => [
                'platformCommissionPct' => 15, 'orderServiceFee' => 25, 'taxVatPct' => 5,
                'settlementCycle' => 'weekly', 'earlyPayoutFeePct' => 2, 'minPayoutAmount' => 1000,
            ],
            'courier' => [
                'parcelBase' => 50, 'perKm' => 12, 'perKg' => 8,
                'expressMultiplier' => 1.4, 'priorityMultiplier' => 1.25,
                'surgeCap' => 100, 'platformCommissionPct' => 12,
                'weeklyGoalDeliveries' => 50, 'topPerformerMultiplier' => 1.2, 'withdrawalMin' => 500,
            ],
        ];

        foreach ($pricing as $panel => $values) {
            PricingSetting::updateOrCreate(['panel' => $panel], ['values' => $values]);
        }
    }

    private function seedAdmin(): void
    {
        $admin = User::firstOrNew(['email' => 'admin@hillgo.app']);
        $admin->fill(['name' => 'HillGo Super Admin']);
        $admin->password = env('SEED_ADMIN_PASSWORD', 'HillGo@2026!');
        $admin->role = 'super_admin';
        $admin->status = 'active';
        $admin->save();
    }

    private function seedSettings(): void
    {
        $defaults = [
            'orgName' => 'HillGo Enterprise',
            'orgEmail' => 'admin@hillgo.app',
            'orgPhone' => '+880 9612-445566',
            'orgAddress' => 'Level 8, Rangs Tower, Dhaka 1215',
            'timezone' => 'Asia/Dhaka',
            'twoFactor' => false,
            'emailAlerts' => true,
            'smsAlerts' => false,
        ];
        foreach ($defaults as $key => $value) {
            AppSetting::firstOrCreate(['key' => $key], ['value' => $value]);
        }
    }

    private function seedLoyalty(): void
    {
        foreach ([['Bronze', 0, 0], ['Silver', 1000, 1], ['Gold', 2000, 2], ['Platinum', 5000, 3]] as [$name, $threshold, $sort]) {
            LoyaltyTier::updateOrCreate(['name' => $name], ['threshold' => $threshold, 'sort' => $sort]);
        }
        if (LoyaltyReward::count() === 0) {
            LoyaltyReward::insert([
                ['title' => 'Delivery voucher', 'description' => '৳50 off any delivery', 'points' => 500, 'type' => 'voucher', 'active' => true, 'created_at' => now(), 'updated_at' => now()],
                ['title' => 'Free delivery pass', 'description' => 'One free delivery', 'points' => 800, 'type' => 'voucher', 'active' => true, 'created_at' => now(), 'updated_at' => now()],
                ['title' => 'Marketplace coupon', 'description' => '৳100 marketplace coupon', 'points' => 1200, 'type' => 'voucher', 'active' => true, 'created_at' => now(), 'updated_at' => now()],
                ['title' => 'Priority support', 'description' => '30 days priority support', 'points' => 1500, 'type' => 'entitlement', 'active' => true, 'created_at' => now(), 'updated_at' => now()],
            ]);
        }
    }
}
