<?php

declare(strict_types=1);

require __DIR__.'/../vendor/autoload.php';
$app = require __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Ride;
use App\Models\Trip;
use App\Models\User;
use App\Services\Dispatch;

$code = $argv[1] ?? 'RID-G13CEV3';

// Free the demo rider from any stuck in-progress work.
$freed = Trip::where('rider_id', 5)
    ->whereIn('status', ['accepted', 'arriving', 'arrived', 'in_progress', 'picked_up', 'in_transit'])
    ->update(['status' => 'cancelled']);
echo "freed_active_trips={$freed}\n";

$ride = Ride::where('code', $code)->first();
if (! $ride) {
    fwrite(STDERR, "Ride {$code} not found\n");
    exit(1);
}

echo "ride_id={$ride->id} status={$ride->status}\n";

if (in_array($ride->status, ['cancelled', 'completed'], true)) {
    fwrite(STDERR, "Ride already finished\n");
    exit(1);
}

// Keep ride searchable.
$ride->update(['status' => 'searching', 'rider_id' => null]);

// Reset its trip (or create one via Dispatch).
$trip = Trip::where('ref_type', 'rides')->where('ref_id', $ride->id)->latest('id')->first();
if ($trip) {
    $trip->update([
        'status' => 'requested',
        'rider_id' => null,
        'offered_at' => null,
        'offer_expires_at' => null,
        'declined_rider_ids' => [],
        'accepted_at' => null,
    ]);
    echo "reset_trip={$trip->id}\n";
} else {
    $trip = Dispatch::offerRide($ride);
    echo 'created_trip='.($trip?->id ?? 'null')."\n";
}

$rider = User::find(5);
$rider?->riderProfile?->update(['online' => true]);
Dispatch::sweepExpired();
$claimed = Dispatch::claimPendingFor($rider);
$offer = Trip::where('rider_id', 5)
    ->where('status', 'requested')
    ->where('offer_expires_at', '>', now())
    ->latest('id')
    ->first();

if ($offer) {
    echo "OFFER_READY trip={$offer->id} ref={$offer->ref_id} expires={$offer->offer_expires_at}\n";
    exit(0);
}

echo 'claim='.($claimed?->id ?? 'null')."\n";
fwrite(STDERR, "No offer ready\n");
exit(1);
