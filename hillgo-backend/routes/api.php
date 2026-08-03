<?php

use App\Http\Controllers\Api\Admin\CommerceController;
use App\Http\Controllers\Api\Admin\CourierController as AdminCourier;
use App\Http\Controllers\Api\Admin\CustomerController as AdminCustomer;
use App\Http\Controllers\Api\Admin\MerchantController as AdminMerchant;
use App\Http\Controllers\Api\Admin\PublicWebController;
use App\Http\Controllers\Api\Admin\RegionController;
use App\Http\Controllers\Api\Admin\RiderController as AdminRider;
use App\Http\Controllers\Api\Admin\SettingsController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Courier\EarningsController as CourierEarnings;
use App\Http\Controllers\Api\Courier\ParcelController as CourierParcels;
use App\Http\Controllers\Api\Courier\ProfileController as CourierProfileCtl;
use App\Http\Controllers\Api\Customer\FoodController;
use App\Http\Controllers\Api\Customer\HotelController;
use App\Http\Controllers\Api\Customer\MarketplaceController;
use App\Http\Controllers\Api\Customer\ParcelController as CustomerParcels;
use App\Http\Controllers\Api\Customer\ProfileController as CustomerProfileCtl;
use App\Http\Controllers\Api\Customer\RentalController;
use App\Http\Controllers\Api\Customer\RideController;
use App\Http\Controllers\Api\Customer\SosController;
use App\Http\Controllers\Api\Customer\WalletController;
use App\Http\Controllers\Api\Merchant\CatalogController;
use App\Http\Controllers\Api\Merchant\OnboardingController as MerchantOnboardingCtl;
use App\Http\Controllers\Api\Merchant\OrderController as MerchantOrders;
use App\Http\Controllers\Api\Merchant\PayoutController as MerchantPayouts;
use App\Http\Controllers\Api\Merchant\StoreController as MerchantStore;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PublicController;
use App\Http\Controllers\Api\Rider\EarningsController as RiderEarnings;
use App\Http\Controllers\Api\Rider\OnboardingController as RiderOnboarding;
use App\Http\Controllers\Api\Rider\PresenceController;
use App\Http\Controllers\Api\Rider\TripController;
use App\Http\Controllers\HealthController;
use Illuminate\Support\Facades\Route;

// ------------------------------------------------------------------
// Health (unauthenticated, outside all middleware groups)
// ------------------------------------------------------------------
Route::get('/health', [HealthController::class, 'check']);

// ------------------------------------------------------------------
// Public Web (rate limited, unauthenticated)
// ------------------------------------------------------------------
Route::prefix('public')->middleware('throttle:public-read')->group(function () {
    Route::post('/contact', [PublicController::class, 'contact'])->middleware('throttle:public-write');
    Route::post('/partner-applications', [PublicController::class, 'partnerApplication'])->middleware('throttle:public-write');
    Route::post('/quotes', [PublicController::class, 'quote']);
    Route::get('/track/{code}', [PublicController::class, 'track']);
    Route::get('/availability', [PublicController::class, 'availability']);
    Route::get('/districts', [PublicController::class, 'districts']);
    Route::post('/newsletter', [PublicController::class, 'newsletter'])->middleware('throttle:public-write');
    Route::get('/faq', [PublicController::class, 'faq']);
    Route::get('/blog', [PublicController::class, 'blog']);
    Route::get('/blog/{slug}', [PublicController::class, 'blogPost']);
    Route::get('/content/home', [PublicController::class, 'homeContent']);
    // Rider nav proxy — apps must not call third-party OSRM with live GPS.
    Route::get('/route', [PublicController::class, 'route'])->middleware('throttle:public-write');
});

// ------------------------------------------------------------------
// Auth per role (throttled)
// ------------------------------------------------------------------
$authRoutes = function (string $role) {
    Route::post('/auth/register', [AuthController::class, 'register'])->defaults('role', $role)->middleware('throttle:auth');
    Route::post('/auth/login', [AuthController::class, 'login'])->defaults('role', $role)->middleware('throttle:auth');
    Route::post('/auth/otp/request', [AuthController::class, 'otpRequest'])->defaults('role', $role)->middleware('throttle:otp');
    Route::post('/auth/otp/verify', [AuthController::class, 'otpVerify'])->defaults('role', $role)->middleware('throttle:auth');
    Route::post('/auth/password/forgot', [AuthController::class, 'passwordForgot'])->defaults('role', $role)->middleware('throttle:otp');
    Route::post('/auth/password/reset', [AuthController::class, 'passwordReset'])->defaults('role', $role)->middleware('throttle:auth');
};

Route::prefix('admin')->group(fn () => Route::post('/auth/login', [AuthController::class, 'login'])->defaults('role', 'admin')->middleware('throttle:auth'));
Route::prefix('customer')->group(fn () => $authRoutes('customer'));
Route::prefix('rider')->group(fn () => $authRoutes('rider'));
Route::prefix('merchant')->group(fn () => $authRoutes('merchant'));
Route::prefix('courier')->group(fn () => $authRoutes('courier_agent'));

// Shared session endpoints for every authenticated role
$sessionRoutes = function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    // Backend 7.4.22 — rotate the current Sanctum token for a new one, same
    // {token, user} shape as login/register. Mirrored across every role group.
    Route::post('/auth/refresh', [AuthController::class, 'refresh']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::patch('/me', [AuthController::class, 'updateMe']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
    Route::delete('/notifications/{notification}', [NotificationController::class, 'destroy']);
};

// ------------------------------------------------------------------
// Admin
// ------------------------------------------------------------------
Route::prefix('admin')->middleware(['auth:sanctum', 'role:admin'])->group(function () use ($sessionRoutes) {
    $sessionRoutes();

    // Region Lock
    Route::get('/regions/divisions', [RegionController::class, 'divisions']);
    Route::get('/regions/divisions/{division}/districts', [RegionController::class, 'districts']);
    Route::post('/regions/divisions/{division}/bulk-status', [RegionController::class, 'bulkStatus']);
    // Backend 7.4.23 — batched read of every district (all divisions) in one call.
    Route::get('/regions/districts', [RegionController::class, 'allDistricts']);
    Route::get('/regions/districts/{district}', [RegionController::class, 'show']);
    Route::patch('/regions/districts/{district}', [RegionController::class, 'update']);

    // Customers + ops lists
    Route::get('/customers', [AdminCustomer::class, 'index']);
    Route::get('/customers/{id}', [AdminCustomer::class, 'show']);
    Route::patch('/customers/{id}', [AdminCustomer::class, 'update']);
    Route::post('/customers/{id}/wallet', [AdminCustomer::class, 'adjustWallet']);
    Route::get('/customers/{id}/wallet/transactions', [AdminCustomer::class, 'walletTransactions']);
    Route::get('/rides', [AdminCustomer::class, 'rides']);
    Route::get('/food-orders', [AdminCustomer::class, 'foodOrders']);
    Route::get('/marketplace-orders', [AdminCustomer::class, 'marketplaceOrders']);
    Route::get('/customer-parcels', [AdminCustomer::class, 'parcels']);
    Route::get('/sos-alerts', [AdminCustomer::class, 'sosAlerts']);
    Route::post('/sos-alerts/{id}/resolve', [AdminCustomer::class, 'resolveSos']);

    // Marketplace / hotels / rentals / loyalty / promos
    Route::get('/marketplace/products', [CommerceController::class, 'products']);
    Route::patch('/marketplace/products/{id}', [CommerceController::class, 'updateProduct']);
    Route::delete('/marketplace/products/{id}', [CommerceController::class, 'deleteProduct']);
    Route::get('/hotels', [CommerceController::class, 'hotels']);
    Route::post('/hotels', [CommerceController::class, 'storeHotel']);
    Route::patch('/hotels/{id}', [CommerceController::class, 'updateHotel']);
    Route::delete('/hotels/{id}', [CommerceController::class, 'deleteHotel']);
    Route::get('/hotel-bookings', [CommerceController::class, 'hotelBookings']);
    Route::get('/rentals', [CommerceController::class, 'rentals']);
    Route::post('/rentals', [CommerceController::class, 'storeRental']);
    Route::patch('/rentals/{id}', [CommerceController::class, 'updateRental']);
    Route::delete('/rentals/{id}', [CommerceController::class, 'deleteRental']);
    Route::get('/rental-bookings', [CommerceController::class, 'rentalBookings']);
    Route::get('/loyalty', [CommerceController::class, 'loyalty']);
    Route::patch('/loyalty/tiers/{id}', [CommerceController::class, 'saveTier']);
    Route::post('/loyalty/rewards', [CommerceController::class, 'storeReward']);
    Route::patch('/loyalty/rewards/{id}', [CommerceController::class, 'updateReward']);
    Route::delete('/loyalty/rewards/{id}', [CommerceController::class, 'deleteReward']);
    Route::get('/promos', [CommerceController::class, 'promos']);
    Route::post('/promos', [CommerceController::class, 'storePromo']);
    Route::patch('/promos/{id}', [CommerceController::class, 'updatePromo']);
    Route::delete('/promos/{id}', [CommerceController::class, 'deletePromo']);

    // Riders
    Route::get('/riders', [AdminRider::class, 'index']);
    Route::patch('/riders/{id}', [AdminRider::class, 'update']);
    Route::get('/riders/kyc', [AdminRider::class, 'kycIndex']);
    Route::post('/riders/kyc/{id}/status', [AdminRider::class, 'kycStatus']);
    Route::post('/riders/kyc/bulk', [AdminRider::class, 'kycBulk']);
    Route::get('/riders/documents/{document}', [AdminRider::class, 'document'])->name('admin.rider.doc');
    Route::get('/trips', [AdminRider::class, 'trips']);
    Route::get('/rider-payouts', [AdminRider::class, 'payouts']);
    Route::post('/rider-payouts', [AdminRider::class, 'createPayout']);
    Route::post('/rider-payouts/{id}/status', [AdminRider::class, 'payoutStatus']);
    Route::get('/riders/map', [AdminRider::class, 'mapPoints']);

    // Merchants
    Route::get('/merchants', [AdminMerchant::class, 'index']);
    Route::get('/merchants/{id}', [AdminMerchant::class, 'show']);
    Route::patch('/merchants/{id}', [AdminMerchant::class, 'update']);
    Route::get('/merchant-onboarding', [AdminMerchant::class, 'onboarding']);
    Route::get('/merchant-onboarding/{id}/docs/{index}', [AdminMerchant::class, 'onboardingDoc'])->name('admin.merchant.onboarding.doc');
    Route::post('/merchant-onboarding/{id}/status', [AdminMerchant::class, 'onboardingStatus']);
    Route::get('/merchant-orders', [AdminMerchant::class, 'orders']);
    Route::get('/merchant-payouts', [AdminMerchant::class, 'payouts']);
    Route::post('/merchant-payouts/{id}/status', [AdminMerchant::class, 'payoutStatus']);
    Route::get('/merchant-catalog', [AdminMerchant::class, 'catalog']);
    Route::post('/merchant-catalog/{id}/toggle', [AdminMerchant::class, 'toggleProduct']);

    // Courier
    Route::get('/courier/agents', [AdminCourier::class, 'agents']);
    Route::patch('/courier/agents/{id}', [AdminCourier::class, 'updateAgent']);
    Route::get('/courier/kyc', [AdminCourier::class, 'kycIndex']);
    Route::post('/courier/kyc/{id}/status', [AdminCourier::class, 'kycStatus']);
    Route::get('/courier/documents/{document}', [AdminCourier::class, 'document'])->name('admin.courier.doc');
    Route::get('/courier/proofs/{proof}', [AdminCourier::class, 'proofFile'])->name('admin.parcel.proof');
    Route::get('/courier/parcels', [AdminCourier::class, 'parcels']);
    Route::post('/courier/parcels/{id}/reassign', [AdminCourier::class, 'reassignParcel']);
    Route::get('/courier/withdrawals', [AdminCourier::class, 'withdrawals']);
    Route::post('/courier/withdrawals/{id}/status', [AdminCourier::class, 'withdrawalStatus']);
    Route::get('/courier/incentives', [AdminCourier::class, 'incentives']);
    Route::post('/courier/incentives', [AdminCourier::class, 'createIncentive']);
    Route::post('/courier/incentives/{id}/toggle', [AdminCourier::class, 'toggleIncentive']);

    // Pricing / settings / KPIs / activity
    Route::get('/pricing/{panel}', [SettingsController::class, 'getPricing']);
    Route::put('/pricing/{panel}', [SettingsController::class, 'savePricing']);
    Route::get('/pricing-audit', [SettingsController::class, 'pricingAudit']);
    Route::get('/settings', [SettingsController::class, 'getSettings']);
    Route::put('/settings', [SettingsController::class, 'saveSettings']);
    Route::get('/overview', [SettingsController::class, 'overview']);
    Route::get('/dashboards/customer', [SettingsController::class, 'customerDashboard']);
    Route::get('/dashboards/rider', [SettingsController::class, 'riderDashboard']);
    Route::get('/dashboards/merchant', [SettingsController::class, 'merchantDashboard']);
    Route::get('/dashboards/courier', [SettingsController::class, 'courierDashboard']);
    Route::get('/activity', [SettingsController::class, 'activity']);

    // Public Web inbox + CMS
    Route::get('/public-web/inquiries', [PublicWebController::class, 'inquiries']);
    Route::post('/public-web/inquiries/{id}/status', [PublicWebController::class, 'inquiryStatus']);
    Route::get('/public-web/partner-applications', [PublicWebController::class, 'partnerApplications']);
    Route::post('/public-web/partner-applications/{id}/status', [PublicWebController::class, 'partnerApplicationStatus']);
    Route::get('/public-web/newsletter', [PublicWebController::class, 'newsletter']);
    Route::get('/public-web/faqs', [PublicWebController::class, 'faqs']);
    Route::post('/public-web/faqs', [PublicWebController::class, 'storeFaq']);
    Route::patch('/public-web/faqs/{id}', [PublicWebController::class, 'updateFaq']);
    Route::delete('/public-web/faqs/{id}', [PublicWebController::class, 'deleteFaq']);
    Route::get('/public-web/blog', [PublicWebController::class, 'blogPosts']);
    Route::post('/public-web/blog', [PublicWebController::class, 'storeBlogPost']);
    Route::patch('/public-web/blog/{id}', [PublicWebController::class, 'updateBlogPost']);
    Route::delete('/public-web/blog/{id}', [PublicWebController::class, 'deleteBlogPost']);
    Route::get('/public-web/testimonials', [PublicWebController::class, 'testimonials']);
    Route::post('/public-web/testimonials', [PublicWebController::class, 'storeTestimonial']);
    Route::patch('/public-web/testimonials/{id}', [PublicWebController::class, 'updateTestimonial']);
    Route::delete('/public-web/testimonials/{id}', [PublicWebController::class, 'deleteTestimonial']);
});

// ------------------------------------------------------------------
// Customer App
// ------------------------------------------------------------------
Route::prefix('customer')->middleware(['auth:sanctum', 'role:customer'])->group(function () use ($sessionRoutes) {
    $sessionRoutes();

    Route::get('/addresses', [CustomerProfileCtl::class, 'addresses']);
    Route::post('/addresses', [CustomerProfileCtl::class, 'storeAddress']);
    Route::patch('/addresses/{address}', [CustomerProfileCtl::class, 'updateAddress']);
    Route::delete('/addresses/{address}', [CustomerProfileCtl::class, 'deleteAddress']);
    Route::get('/payment-methods', [CustomerProfileCtl::class, 'paymentMethods']);
    Route::post('/payment-methods', [CustomerProfileCtl::class, 'storePaymentMethod']);
    Route::delete('/payment-methods/{paymentMethod}', [CustomerProfileCtl::class, 'deletePaymentMethod']);
    Route::patch('/preferences', [CustomerProfileCtl::class, 'preferences']);

    // Rides (create + status-transition are idempotency-key aware — 7.4.21)
    Route::post('/rides/quote', [RideController::class, 'quote']);
    Route::post('/rides', [RideController::class, 'store'])->middleware('idempotent');
    Route::get('/rides', [RideController::class, 'index']);
    Route::get('/rides/{ride}', [RideController::class, 'show']);
    Route::post('/rides/{ride}/cancel', [RideController::class, 'cancel'])->middleware('idempotent');
    Route::post('/rides/{ride}/rate', [RideController::class, 'rate']);

    // Food
    Route::get('/food/restaurants', [FoodController::class, 'restaurants']);
    Route::get('/food/restaurants/{id}', [FoodController::class, 'restaurant']);
    Route::post('/food/orders', [FoodController::class, 'checkout'])->middleware('idempotent');
    Route::get('/food/orders', [FoodController::class, 'orders']);
    Route::get('/food/orders/{order}', [FoodController::class, 'order']);

    // Parcels (create + status-transition are idempotency-key aware — 7.4.21)
    Route::post('/parcels/quote', [CustomerParcels::class, 'quote']);
    Route::post('/parcels', [CustomerParcels::class, 'store'])->middleware('idempotent');
    Route::get('/parcels', [CustomerParcels::class, 'index']);
    Route::get('/parcels/{parcel}', [CustomerParcels::class, 'show']);
    Route::post('/parcels/{parcel}/cancel', [CustomerParcels::class, 'cancel'])->middleware('idempotent');

    // Marketplace
    Route::get('/marketplace/categories', [MarketplaceController::class, 'categories']);
    Route::get('/marketplace/products', [MarketplaceController::class, 'products']);
    Route::get('/marketplace/products/{id}', [MarketplaceController::class, 'product']);
    Route::post('/marketplace/orders', [MarketplaceController::class, 'checkout'])->middleware('idempotent');
    Route::get('/marketplace/orders', [MarketplaceController::class, 'orders']);

    // Hotels & rentals
    Route::get('/hotels', [HotelController::class, 'index']);
    Route::get('/hotels/{id}', [HotelController::class, 'show']);
    Route::post('/hotels/bookings', [HotelController::class, 'book']);
    Route::get('/hotels/bookings/list', [HotelController::class, 'bookings']);
    Route::post('/hotels/bookings/{booking}/cancel', [HotelController::class, 'cancelBooking']);
    Route::get('/rentals', [RentalController::class, 'index']);
    Route::get('/rentals/{id}', [RentalController::class, 'show']);
    Route::post('/rentals/bookings', [RentalController::class, 'book']);
    Route::get('/rentals/bookings/list', [RentalController::class, 'bookings']);
    Route::post('/rentals/bookings/{booking}/cancel', [RentalController::class, 'cancelBooking']);

    // Wallet / loyalty / promos
    Route::get('/wallet', [WalletController::class, 'summary']);
    Route::get('/wallet/transactions', [WalletController::class, 'transactions']);
    Route::post('/wallet/top-up', [WalletController::class, 'topUp']);
    Route::get('/rewards', [WalletController::class, 'rewards']);
    Route::post('/rewards/{rewardId}/redeem', [WalletController::class, 'redeem']);
    Route::get('/promos', [WalletController::class, 'promos']);

    // SOS
    Route::get('/sos/contacts', [SosController::class, 'contacts']);
    Route::post('/sos/contacts', [SosController::class, 'storeContact']);
    Route::patch('/sos/contacts/{contact}', [SosController::class, 'updateContact']);
    Route::delete('/sos/contacts/{contact}', [SosController::class, 'deleteContact']);
    Route::get('/sos/alerts', [SosController::class, 'alerts']);
    Route::post('/sos/alerts', [SosController::class, 'trigger']);
});

// ------------------------------------------------------------------
// Rider App
// ------------------------------------------------------------------
Route::prefix('rider')->middleware(['auth:sanctum', 'role:rider'])->group(function () use ($sessionRoutes) {
    $sessionRoutes();

    Route::patch('/onboarding/personal', [RiderOnboarding::class, 'personal']);
    Route::put('/vehicle', [RiderOnboarding::class, 'vehicle']);
    Route::patch('/vehicle', [RiderEarnings::class, 'updateVehicle']);
    Route::get('/documents', [RiderOnboarding::class, 'documents']);
    Route::post('/documents/id_proof/token', [RiderOnboarding::class, 'idProofToken']);
    Route::post('/documents/{docKey}/upload', [RiderOnboarding::class, 'upload']);
    Route::get('/onboarding/status', [RiderOnboarding::class, 'status']);
    Route::post('/onboarding/complete', [RiderOnboarding::class, 'complete']);

    Route::post('/presence', [PresenceController::class, 'presence']);
    Route::post('/location', [PresenceController::class, 'location']);

    Route::get('/offers/current', [TripController::class, 'currentOffer']);
    Route::post('/offers/{trip}/accept', [TripController::class, 'accept']);
    Route::post('/offers/{trip}/decline', [TripController::class, 'decline']);
    Route::get('/trips/active', [TripController::class, 'active']);
    Route::post('/trips/{trip}/advance', [TripController::class, 'advance']);
    Route::post('/trips/{trip}/status', [TripController::class, 'setStatus']);
    Route::get('/trips', [TripController::class, 'index']);
    Route::get('/trips/{trip}', [TripController::class, 'show']);

    Route::get('/earnings', [RiderEarnings::class, 'summary']);
    Route::get('/payouts', [RiderEarnings::class, 'payouts']);
    Route::post('/payouts/cash-out', [RiderEarnings::class, 'cashOut']);
});

// ------------------------------------------------------------------
// Merchant App
// ------------------------------------------------------------------
Route::prefix('merchant')->middleware(['auth:sanctum', 'role:merchant'])->group(function () use ($sessionRoutes) {
    $sessionRoutes();

    Route::post('/onboarding', [MerchantOnboardingCtl::class, 'submit']);
    Route::get('/onboarding/status', [MerchantOnboardingCtl::class, 'status']);

    Route::get('/store', [MerchantStore::class, 'show']);
    Route::put('/store', [MerchantStore::class, 'update']);
    Route::patch('/store/status', [MerchantStore::class, 'setStatus']);
    Route::post('/store/branding', [MerchantStore::class, 'branding']);

    Route::get('/categories', [CatalogController::class, 'categories']);
    Route::post('/categories', [CatalogController::class, 'storeCategory']);
    Route::patch('/categories/{category}', [CatalogController::class, 'updateCategory']);
    Route::delete('/categories/{category}', [CatalogController::class, 'deleteCategory']);
    Route::post('/categories/reorder', [CatalogController::class, 'reorderCategories']);
    Route::get('/products', [CatalogController::class, 'products']);
    Route::post('/products', [CatalogController::class, 'storeProduct']);
    Route::patch('/products/{product}', [CatalogController::class, 'updateProduct']);
    Route::post('/products/{product}', [CatalogController::class, 'updateProduct']); // multipart-friendly
    Route::delete('/products/{product}', [CatalogController::class, 'deleteProduct']);

    // Status-transition endpoints are idempotency-key aware — 7.4.21.
    Route::get('/orders', [MerchantOrders::class, 'index']);
    Route::get('/orders/{order}', [MerchantOrders::class, 'show']);
    Route::post('/orders/{order}/accept', [MerchantOrders::class, 'accept'])->middleware('idempotent');
    Route::post('/orders/{order}/ready', [MerchantOrders::class, 'ready'])->middleware('idempotent');
    Route::post('/orders/{order}/deliver', [MerchantOrders::class, 'deliver'])->middleware('idempotent');
    Route::post('/orders/{order}/reject', [MerchantOrders::class, 'reject'])->middleware('idempotent');

    Route::get('/revenue', [MerchantPayouts::class, 'revenue']);
    Route::get('/payouts', [MerchantPayouts::class, 'payouts']);
    Route::post('/payouts/early-request', [MerchantPayouts::class, 'earlyRequest']);
    Route::get('/transactions', [MerchantPayouts::class, 'transactions']);
    Route::get('/reviews', [MerchantPayouts::class, 'reviews']);
    Route::post('/reviews/{review}/reply', [MerchantPayouts::class, 'reply']);
    Route::patch('/settings', [MerchantPayouts::class, 'settings']);
});

// ------------------------------------------------------------------
// Courier Agent App
// ------------------------------------------------------------------
Route::prefix('courier')->middleware(['auth:sanctum', 'role:courier_agent'])->group(function () use ($sessionRoutes) {
    $sessionRoutes();

    Route::patch('/presence', [CourierProfileCtl::class, 'presence']);
    Route::post('/location', [CourierProfileCtl::class, 'location']);
    Route::patch('/vehicle', [CourierProfileCtl::class, 'updateVehicle']);
    Route::patch('/bank', [CourierProfileCtl::class, 'updateBank']);
    Route::get('/documents', [CourierProfileCtl::class, 'documents']);
    Route::post('/documents/{docKey}/upload', [CourierProfileCtl::class, 'upload']);
    Route::patch('/settings', [CourierProfileCtl::class, 'settings']);

    // Status-transition endpoints are idempotency-key aware — 7.4.21.
    Route::get('/parcels/assigned', [CourierParcels::class, 'assigned']);
    Route::get('/parcels/history', [CourierParcels::class, 'history']);
    Route::get('/parcels/{parcel}', [CourierParcels::class, 'show']);
    Route::post('/parcels/{parcel}/pickup-otp', [CourierParcels::class, 'pickupOtp'])->middleware(['throttle:otp-verify', 'idempotent']);
    Route::post('/parcels/{parcel}/start-transit', [CourierParcels::class, 'startTransit'])->middleware('idempotent');
    Route::post('/parcels/{parcel}/delivery-otp', [CourierParcels::class, 'deliveryOtp'])->middleware(['throttle:otp-verify', 'idempotent']);
    Route::post('/parcels/{parcel}/fail', [CourierParcels::class, 'fail'])->middleware('idempotent');
    Route::post('/parcels/{parcel}/proof', [CourierParcels::class, 'proof']);

    Route::get('/earnings/dashboard', [CourierEarnings::class, 'dashboard']);
    Route::get('/earnings/weekly', [CourierEarnings::class, 'weekly']);
    Route::get('/earnings/payout-summary', [CourierEarnings::class, 'payoutSummary']);
    Route::post('/withdrawals', [CourierEarnings::class, 'withdraw']);
    Route::get('/incentives', [CourierEarnings::class, 'incentives']);
    Route::post('/incentives/{id}/accept', [CourierEarnings::class, 'acceptIncentive']);
});
