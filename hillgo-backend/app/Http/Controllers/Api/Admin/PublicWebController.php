<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\BlogPost;
use App\Models\ContactInquiry;
use App\Models\Faq;
use App\Models\NewsletterSubscriber;
use App\Models\PartnerApplication;
use App\Models\RiderProfile;
use App\Models\Testimonial;
use App\Models\User;
use App\Services\Audit;
use App\Services\Codes;
use App\Services\Notifier;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/** Admin inbox + CMS for the public marketing site. */
class PublicWebController extends Controller
{
    // —— Contact inquiries ——

    public function inquiries(Request $request)
    {
        $rows = ContactInquiry::when($request->query('status') && $request->query('status') !== 'all',
            fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);
        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function inquiryStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:new,read,replied,archived']]);
        $inquiry = ContactInquiry::findOrFail($id);
        $inquiry->update($data);
        return response()->json($inquiry->fresh());
    }

    // —— Partner applications → rider onboarding ——

    public function partnerApplications(Request $request)
    {
        $rows = PartnerApplication::with('district')
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($a) => [
                'id' => $a->id,
                'fullName' => $a->full_name,
                'phone' => $a->phone,
                'email' => $a->email,
                'vehicleType' => $a->vehicle_type,
                'city' => $a->city,
                'district' => $a->district?->name,
                'status' => $a->status,
                'riderUserId' => $a->rider_user_id,
                'submitted' => $a->created_at->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    /** Approve → create rider account in onboarding status (KYC pipeline). */
    public function partnerApplicationStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:pending,approved,rejected']]);
        $app = PartnerApplication::findOrFail($id);

        if ($data['status'] === 'approved' && ! $app->rider_user_id) {
            if (User::where('phone', $app->phone)->exists()) {
                return response()->json(['message' => 'A user with this phone already exists.'], 422);
            }
            $user = new User([
                'name' => $app->full_name,
                'phone' => $app->phone,
                'email' => User::where('email', $app->email)->exists() ? null : $app->email,
                'district_id' => $app->district_id,
            ]);
            $user->password = Str::random(32); // rider sets real password via reset OTP
            $user->role = 'rider';
            $user->status = 'onboarding';
            $user->save();

            $vehicleType = match (strtolower($app->vehicle_type)) {
                'car' => 'car',
                default => 'bike',
            };
            RiderProfile::create([
                'user_id' => $user->id,
                'code' => Codes::make('HG-RD'),
                'vehicle_type' => $vehicleType,
            ]);
            $app->rider_user_id = $user->id;
        }

        $app->status = $data['status'];
        $app->save();

        Audit::log("Partner application {$app->full_name}: {$data['status']}", $request->user()->name, 'kyc');
        return response()->json(['id' => $app->id, 'status' => $app->status, 'riderUserId' => $app->rider_user_id]);
    }

    // —— Newsletter ——

    public function newsletter(Request $request)
    {
        $rows = NewsletterSubscriber::latest()->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    // —— FAQ CMS ——

    public function faqs(Request $request)
    {
        $rows = Faq::orderBy('category')->orderBy('sort')
            ->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function storeFaq(Request $request)
    {
        $faq = Faq::create($this->validateFaq($request));
        return response()->json($faq, 201);
    }

    public function updateFaq(Request $request, int $id)
    {
        $faq = Faq::findOrFail($id);
        $faq->update($this->validateFaq($request, false));
        return response()->json($faq->fresh());
    }

    public function deleteFaq(int $id)
    {
        Faq::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Blog CMS ——

    public function blogPosts(Request $request)
    {
        $rows = BlogPost::latest()->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function storeBlogPost(Request $request)
    {
        $data = $this->validateBlog($request);
        $data['slug'] = $data['slug'] ?? Str::slug($data['title']);
        $post = BlogPost::create($data);
        return response()->json($post, 201);
    }

    public function updateBlogPost(Request $request, int $id)
    {
        $post = BlogPost::findOrFail($id);
        $post->update($this->validateBlog($request, false, $id));
        return response()->json($post->fresh());
    }

    public function deleteBlogPost(int $id)
    {
        BlogPost::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Testimonials ——

    public function testimonials(Request $request)
    {
        $rows = Testimonial::orderBy('sort')->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function storeTestimonial(Request $request)
    {
        $row = Testimonial::create($request->validate([
            'name' => ['required', 'string', 'max:120'],
            'role' => ['nullable', 'string', 'max:120'],
            'quote' => ['required', 'string', 'max:1000'],
            'rating' => ['nullable', 'integer', 'between:1,5'],
            'sort' => ['nullable', 'integer'],
            'active' => ['nullable', 'boolean'],
        ]));
        return response()->json($row, 201);
    }

    public function updateTestimonial(Request $request, int $id)
    {
        $row = Testimonial::findOrFail($id);
        $row->update($request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'role' => ['sometimes', 'nullable', 'string', 'max:120'],
            'quote' => ['sometimes', 'string', 'max:1000'],
            'rating' => ['sometimes', 'integer', 'between:1,5'],
            'sort' => ['sometimes', 'integer'],
            'active' => ['sometimes', 'boolean'],
        ]));
        return response()->json($row->fresh());
    }

    public function deleteTestimonial(int $id)
    {
        Testimonial::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    private function validateFaq(Request $request, bool $create = true): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'category' => ['nullable', 'string', 'max:64'],
            'question' => [$req, 'string', 'max:300'],
            'answer' => [$req, 'string', 'max:5000'],
            'sort' => ['nullable', 'integer'],
            'active' => ['nullable', 'boolean'],
        ]);
    }

    private function validateBlog(Request $request, bool $create = true, ?int $ignoreId = null): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'title' => [$req, 'string', 'max:190'],
            'slug' => ['nullable', 'string', 'max:190', 'unique:blog_posts,slug' . ($ignoreId ? ",$ignoreId" : '')],
            'body' => [$req, 'string'],
            'author' => ['nullable', 'string', 'max:120'],
            'cover_image' => ['nullable', 'string', 'max:500'],
            'published_at' => ['nullable', 'date'],
        ]);
    }
}
