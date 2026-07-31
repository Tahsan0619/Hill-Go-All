<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CourierProfile;
use App\Models\CustomerProfile;
use App\Models\District;
use App\Models\RiderProfile;
use App\Models\User;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\OtpService;
use App\Services\Phone;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

/**
 * Shared auth for admin + customer + rider + merchant + courier_agent.
 * The role comes from route defaults (never from request input).
 */
class AuthController extends Controller
{
    // ---------- Registration ----------

    public function register(Request $request)
    {
        $role = $request->route()->parameter('role') ?? $request->route()->defaults['role'];

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:32', 'unique:users,phone'],
            'email' => ['nullable', 'email', 'max:190', 'unique:users,email'],
            'password' => [$role === 'customer' ? 'nullable' : 'required', 'string', 'min:8'],
            'district_id' => ['nullable', 'string', 'exists:districts,id'],
            'otp' => ['nullable', 'string'],
        ]);

        $this->enforceRegionLock($role, $data['district_id'] ?? null);

        // Customer registration is OTP-first: request OTP, then verify here.
        if ($role === 'customer') {
            if (empty($data['otp'])) {
                OtpService::issue($data['phone'], $role, 'register');
                return response()->json(['message' => 'OTP sent. Verify to complete registration.', 'otp_required' => true]);
            }
            if (! OtpService::verify($data['phone'], $role, $data['otp'], 'register')) {
                throw ValidationException::withMessages(['otp' => 'Invalid or expired OTP.']);
            }
        }

        $user = new User([
            'name' => $data['name'],
            'phone' => $data['phone'],
            'email' => $data['email'] ?? null,
            'district_id' => $data['district_id'] ?? null,
        ]);
        $user->password = $data['password'] ?? str()->random(32);
        $user->role = $role;
        $user->status = in_array($role, ['rider', 'merchant', 'courier_agent'], true) ? 'onboarding' : 'active';
        $user->save();

        $this->createProfile($user);
        Notifier::admins('New ' . str_replace('_', ' ', $role) . ' registered', "{$user->name} ({$user->phone})", 'registration');

        $token = $user->createToken($role)->plainTextToken;
        return response()->json(['token' => $token, 'user' => $this->me($request, $user)->getData()], 201);
    }

    // ---------- Email/password login ----------

    public function login(Request $request)
    {
        $role = $request->route()->defaults['role'];
        $data = $request->validate([
            'email' => ['nullable', 'email'],
            'phone' => ['nullable', 'string'],
            'password' => ['required', 'string'],
        ]);
        if (empty($data['email']) && empty($data['phone'])) {
            throw ValidationException::withMessages(['email' => 'Email or phone is required.']);
        }

        $query = User::query();
        if ($role === 'admin') {
            $query->whereIn('role', ['super_admin', 'admin']);
        } else {
            $query->where('role', $role);
        }
        $user = $query
            ->when(! empty($data['email']), fn ($q) => $q->where('email', $data['email']))
            ->when(empty($data['email']) && ! empty($data['phone']), fn ($q) => $q->whereIn('phone', Phone::lookupVariants($data['phone'])))
            ->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['email' => 'Invalid credentials.']);
        }
        if ($user->status === 'suspended') {
            throw ValidationException::withMessages(['email' => 'Account suspended. Contact support.']);
        }

        $token = $user->createToken($role)->plainTextToken;
        return response()->json(['token' => $token, 'user' => $this->me($request, $user)->getData()]);
    }

    // ---------- Phone OTP login ----------

    public function otpRequest(Request $request)
    {
        $role = $request->route()->defaults['role'];
        $data = $request->validate(['phone' => ['required', 'string']]);
        $phone = Phone::normalize($data['phone']) ?? $data['phone'];

        $user = User::where('role', $role)->whereIn('phone', Phone::lookupVariants($data['phone']))->first();
        if (! $user) {
            throw ValidationException::withMessages(['phone' => 'No account found for this phone number.']);
        }

        OtpService::issue($user->phone ?: $phone, $role, 'login');
        return response()->json(['message' => 'OTP sent.']);
    }

    public function otpVerify(Request $request)
    {
        $role = $request->route()->defaults['role'];
        $data = $request->validate(['phone' => ['required', 'string'], 'otp' => ['required', 'string']]);

        $user = User::where('role', $role)->whereIn('phone', Phone::lookupVariants($data['phone']))->first();
        if (! $user) {
            throw ValidationException::withMessages(['phone' => 'No account found for this phone number.']);
        }

        $otpPhone = $user->phone ?: (Phone::normalize($data['phone']) ?? $data['phone']);
        if (! OtpService::verify($otpPhone, $role, $data['otp'], 'login')
            && ! OtpService::verify($data['phone'], $role, $data['otp'], 'login')) {
            throw ValidationException::withMessages(['otp' => 'Invalid or expired OTP.']);
        }

        if ($user->status === 'suspended') {
            throw ValidationException::withMessages(['phone' => 'Account suspended. Contact support.']);
        }

        $token = $user->createToken($role)->plainTextToken;
        return response()->json(['token' => $token, 'user' => $this->me($request, $user)->getData()]);
    }

    // ---------- Password reset via OTP ----------

    public function passwordForgot(Request $request)
    {
        $role = $request->route()->defaults['role'];
        $data = $request->validate(['phone' => ['required', 'string']]);
        $user = User::where('role', $role)->whereIn('phone', Phone::lookupVariants($data['phone']))->first();
        if ($user) {
            OtpService::issue($user->phone ?: $data['phone'], $role, 'reset');
        }
        // Same response either way (no account enumeration).
        return response()->json(['message' => 'If the account exists, a reset code was sent.']);
    }

    public function passwordReset(Request $request)
    {
        $role = $request->route()->defaults['role'];
        $data = $request->validate([
            'phone' => ['required', 'string'],
            'otp' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8'],
        ]);
        $user = User::where('role', $role)->whereIn('phone', Phone::lookupVariants($data['phone']))->firstOrFail();
        $otpPhone = $user->phone ?: $data['phone'];
        if (! OtpService::verify($otpPhone, $role, $data['otp'], 'reset')
            && ! OtpService::verify($data['phone'], $role, $data['otp'], 'reset')) {
            throw ValidationException::withMessages(['otp' => 'Invalid or expired OTP.']);
        }
        $user->password = $data['password'];
        $user->save();
        $user->tokens()->delete();
        return response()->json(['message' => 'Password reset. Please log in.']);
    }

    // ---------- Session ----------

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out.']);
    }

    public function me(Request $request, ?User $user = null)
    {
        $u = $user ?? $request->user();
        $u->load('district');
        $payload = [
            'id' => $u->id,
            'name' => $u->name,
            'email' => $u->email,
            'phone' => $u->phone,
            'role' => $u->role,
            'status' => $u->status,
            'avatar' => $u->avatar,
            'language' => $u->language,
            'district_id' => $u->district_id,
            'district' => $u->district?->name,
        ];

        switch ($u->role) {
            case 'customer':
                $p = $u->customerProfile;
                $payload['profile'] = $p ? [
                    'code' => $p->code, 'tier' => $p->tier,
                    'wallet_balance' => (float) $p->wallet_balance,
                    'loyalty_points' => (int) $p->loyalty_points,
                    'orders_count' => (int) $p->orders_count,
                    'rating' => (float) $p->rating,
                ] : null;
                break;
            case 'rider':
                $p = $u->riderProfile;
                $payload['profile'] = $p ? array_merge($p->only([
                    'code', 'vehicle_type', 'vehicle_make', 'vehicle_model', 'vehicle_year', 'plate',
                    'online', 'payout_method', 'kyc_status', 'legal_name', 'home_address', 'dob', 'nid',
                ]), ['balance' => (float) $p->balance, 'rating' => (float) $p->rating]) : null;
                break;
            case 'courier_agent':
                $p = $u->courierProfile;
                $payload['profile'] = $p ? array_merge($p->only([
                    'code', 'vehicle_type', 'vehicle_name', 'plate', 'verified', 'bank_verified',
                    'bank_last4', 'online', 'kyc_status', 'deliveries_count', 'nid',
                ]), ['balance' => (float) $p->balance, 'rating' => (float) $p->rating, 'partner_since' => $p->created_at?->toDateString()]) : null;
                break;
            case 'merchant':
                $store = $u->store;
                $payload['store'] = $store?->only(['id', 'code', 'name', 'status', 'is_open', 'accepting_orders', 'category']);
                break;
        }

        return response()->json($payload);
    }

    public function updateMe(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'email' => ['sometimes', 'nullable', 'email', 'max:190', 'unique:users,email,' . $user->id],
            'phone' => ['sometimes', 'string', 'max:32', 'unique:users,phone,' . $user->id],
            'avatar' => ['sometimes', 'nullable', 'string', 'max:500'],
            'language' => ['sometimes', 'string', 'max:16'],
            'district_id' => ['sometimes', 'nullable', 'string', 'exists:districts,id'],
        ]);
        $user->update($data);
        return $this->me($request);
    }

    // ---------- Helpers ----------

    private function enforceRegionLock(string $role, ?string $districtId): void
    {
        if (! $districtId) {
            return;
        }
        $district = District::find($districtId);
        $flag = match ($role) {
            'customer' => 'allow_customer',
            'rider' => 'allow_rider',
            'merchant' => 'allow_merchant',
            'courier_agent' => 'allow_courier',
            default => null,
        };
        if ($flag && ($district->status !== 'open' || ! $district->{$flag})) {
            throw ValidationException::withMessages([
                'district_id' => "HillGo is not yet available for this service in {$district->name}.",
            ]);
        }
    }

    private function createProfile(User $user): void
    {
        match ($user->role) {
            'customer' => CustomerProfile::create(['user_id' => $user->id, 'code' => Codes::make('HG')]),
            'rider' => RiderProfile::create(['user_id' => $user->id, 'code' => Codes::make('HG-RD')]),
            'courier_agent' => CourierProfile::create(['user_id' => $user->id, 'code' => Codes::make('CG')]),
            default => null,
        };
    }
}
