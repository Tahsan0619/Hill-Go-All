<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\PaymentMethod;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    // —— Addresses ——

    public function addresses(Request $request)
    {
        return response()->json($request->user()->addresses()->orderByDesc('is_default')->get());
    }

    public function storeAddress(Request $request)
    {
        $data = $this->validateAddress($request);
        $address = $request->user()->addresses()->create($data);
        if ($data['is_default'] ?? false) {
            $this->makeDefault($request, $address);
        }
        return response()->json($address, 201);
    }

    public function updateAddress(Request $request, Address $address)
    {
        abort_unless($address->user_id === $request->user()->id, 403);
        $address->update($this->validateAddress($request, false));
        if ($request->boolean('is_default')) {
            $this->makeDefault($request, $address);
        }
        return response()->json($address->fresh());
    }

    public function deleteAddress(Request $request, Address $address)
    {
        abort_unless($address->user_id === $request->user()->id, 403);
        $address->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Payment methods ——

    public function paymentMethods(Request $request)
    {
        return response()->json($request->user()->paymentMethods()->orderByDesc('is_default')->get());
    }

    public function storePaymentMethod(Request $request)
    {
        $data = $request->validate([
            'type' => ['required', 'in:wallet,card,bkash,nagad'],
            'label' => ['required', 'string', 'max:120'],
            'details' => ['nullable', 'array'], // masked only (e.g. last4)
            'is_default' => ['nullable', 'boolean'],
        ]);
        $method = $request->user()->paymentMethods()->create($data);
        if ($data['is_default'] ?? false) {
            $request->user()->paymentMethods()->where('id', '!=', $method->id)->update(['is_default' => false]);
        }
        return response()->json($method, 201);
    }

    public function deletePaymentMethod(Request $request, PaymentMethod $paymentMethod)
    {
        abort_unless($paymentMethod->user_id === $request->user()->id, 403);
        $paymentMethod->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    public function preferences(Request $request)
    {
        $data = $request->validate(['language' => ['required', 'in:en,bn,hi,ccp']]);
        $request->user()->update($data);
        return response()->json(['language' => $request->user()->language]);
    }

    private function validateAddress(Request $request, bool $create = true): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'label' => [$req, 'string', 'max:64'],
            'address' => [$req, 'string', 'max:300'],
            'lat' => ['nullable', 'numeric', 'between:-90,90'],
            'lng' => ['nullable', 'numeric', 'between:-180,180'],
            'is_default' => ['nullable', 'boolean'],
        ]);
    }

    private function makeDefault(Request $request, Address $address): void
    {
        $request->user()->addresses()->where('id', '!=', $address->id)->update(['is_default' => false]);
        $address->update(['is_default' => true]);
    }
}
