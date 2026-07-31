<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\SosAlert;
use App\Models\SosContact;
use App\Services\Notifier;
use Illuminate\Http\Request;

class SosController extends Controller
{
    // —— Emergency contacts ——

    public function contacts(Request $request)
    {
        return response()->json($request->user()->sosContacts()->get());
    }

    public function storeContact(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:32'],
            'relation' => ['nullable', 'string', 'max:64'],
        ]);
        return response()->json($request->user()->sosContacts()->create($data), 201);
    }

    public function updateContact(Request $request, SosContact $contact)
    {
        abort_unless($contact->user_id === $request->user()->id, 403);
        $contact->update($request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'phone' => ['sometimes', 'string', 'max:32'],
            'relation' => ['sometimes', 'nullable', 'string', 'max:64'],
        ]));
        return response()->json($contact->fresh());
    }

    public function deleteContact(Request $request, SosContact $contact)
    {
        abort_unless($contact->user_id === $request->user()->id, 403);
        $contact->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Alerts ——

    public function alerts(Request $request)
    {
        return response()->json(
            SosAlert::where('user_id', $request->user()->id)->latest()->paginate(30)
        );
    }

    public function trigger(Request $request)
    {
        $data = $request->validate([
            'type' => ['required', 'in:sos,ride_sos,police,ambulance,location_share'],
            'location_label' => ['nullable', 'string', 'max:300'],
            'lat' => ['nullable', 'numeric', 'between:-90,90'],
            'lng' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $alert = SosAlert::create([
            'user_id' => $request->user()->id,
            'type' => $data['type'],
            'location_label' => $data['location_label'] ?? '',
            'lat' => $data['lat'] ?? null,
            'lng' => $data['lng'] ?? null,
            'status' => 'active',
        ]);

        // Persist + notify ops immediately. (SMS to contacts when provider is wired.)
        Notifier::admins('SOS ALERT', "{$request->user()->name} triggered {$data['type']}" . ($alert->location_label ? " at {$alert->location_label}" : ''), 'sos', [
            'alert_id' => $alert->id, 'user_id' => $request->user()->id, 'lat' => $alert->lat, 'lng' => $alert->lng,
        ]);
        \App\Services\Audit::log("SOS alert by {$request->user()->name} ({$data['type']})", 'System');

        return response()->json($alert, 201);
    }
}
