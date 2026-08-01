<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Support\Media;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    // —— Categories ——

    public function categories(Request $request)
    {
        $store = $this->store($request);
        return response()->json(
            ProductCategory::where('store_id', $store->id)->withCount('products')
                ->orderBy('sort_order')->get()
                ->map(fn ($c) => [
                    'id' => $c->id, 'name' => $c->name, 'icon' => $c->icon, 'color' => $c->color,
                    'item_count' => $c->products_count, 'is_visible' => (bool) $c->is_visible,
                    'sort_order' => $c->sort_order,
                ])
        );
    }

    public function storeCategory(Request $request)
    {
        $store = $this->store($request);
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'icon' => ['nullable', 'string', 'max:64'],
            'color' => ['nullable', 'string', 'max:16'],
            'is_visible' => ['nullable', 'boolean'],
            'sort_order' => ['nullable', 'integer'],
        ]);
        $category = ProductCategory::create($data + ['store_id' => $store->id]);
        return response()->json($category, 201);
    }

    public function updateCategory(Request $request, ProductCategory $category)
    {
        $this->authorizeCategory($request, $category);
        $category->update($request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'icon' => ['sometimes', 'nullable', 'string', 'max:64'],
            'color' => ['sometimes', 'nullable', 'string', 'max:16'],
            'is_visible' => ['sometimes', 'boolean'],
            'sort_order' => ['sometimes', 'integer'],
        ]));
        return response()->json($category->fresh());
    }

    public function deleteCategory(Request $request, ProductCategory $category)
    {
        $this->authorizeCategory($request, $category);
        $category->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    public function reorderCategories(Request $request)
    {
        $store = $this->store($request);
        $data = $request->validate(['order' => ['required', 'array'], 'order.*' => ['integer']]);
        foreach ($data['order'] as $index => $categoryId) {
            ProductCategory::where('store_id', $store->id)->where('id', $categoryId)->update(['sort_order' => $index]);
        }
        return response()->json(['message' => 'Reordered.']);
    }

    // —— Products ——

    public function products(Request $request)
    {
        $store = $this->store($request);
        $rows = Product::where('store_id', $store->id)->with('category')
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->when($request->query('category_id'), fn ($q, $id) => $q->where('category_id', $id))
            ->when($request->query('filter') === 'low_stock',
                fn ($q) => $q->where('track_stock', true)->whereColumn('stock', '<=', 'low_stock_alert'))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => $this->productShape($p)),
            'total' => $rows->total(),
        ]);
    }

    public function storeProduct(Request $request)
    {
        $store = $this->store($request);
        $data = $this->validateProduct($request);
        $data['store_id'] = $store->id;

        // Retail categories surface in the customer marketplace.
        $data['marketplace_category'] = $this->marketplaceCategory($store->category, $data['marketplace_category'] ?? null);

        if ($request->hasFile('image')) {
            $data['images'] = [\App\Support\StoredFiles::putPublic($request->file('image'), "products/{$store->id}")];
        }

        $product = Product::create(collect($data)->except('image')->all());
        return response()->json($this->productShape($product->load('category')), 201);
    }

    public function updateProduct(Request $request, Product $product)
    {
        $this->authorizeProduct($request, $product);
        $data = $this->validateProduct($request, false);
        if ($request->hasFile('image')) {
            $old = ($product->images ?? [])[0] ?? null;
            $data['images'] = [\App\Support\StoredFiles::replacePublic($old, $request->file('image'), "products/{$product->store_id}")];
        }
        $product->update(collect($data)->except('image')->all());
        return response()->json($this->productShape($product->fresh('category')));
    }

    public function deleteProduct(Request $request, Product $product)
    {
        $this->authorizeProduct($request, $product);
        foreach ($product->images ?? [] as $img) {
            \App\Support\StoredFiles::deletePublic($img);
        }
        $product->delete();
        return response()->json(['message' => 'Deleted.']);
    }

    // —— Helpers ——

    private function store(Request $request)
    {
        $store = $request->user()->store;
        abort_unless($store, 404, 'No store yet. Complete onboarding first.');
        return $store;
    }

    private function authorizeCategory(Request $request, ProductCategory $category): void
    {
        abort_unless($category->store_id === $request->user()->store?->id, 403);
    }

    private function authorizeProduct(Request $request, Product $product): void
    {
        abort_unless($product->store_id === $request->user()->store?->id, 403);
    }

    private function validateProduct(Request $request, bool $create = true): array
    {
        $req = $create ? 'required' : 'sometimes';
        return $request->validate([
            'name' => [$req, 'string', 'max:190'],
            'description' => ['nullable', 'string', 'max:2000'],
            'category_id' => ['nullable', 'integer', 'exists:product_categories,id'],
            'price' => [$req, 'numeric', 'min:0'],
            'sku' => ['nullable', 'string', 'max:64'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'low_stock_alert' => ['nullable', 'integer', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'status' => ['nullable', 'in:active,hidden'],
            'marketplace_category' => ['nullable', 'in:' . implode(',', \App\Http\Controllers\Api\Customer\MarketplaceController::CATEGORIES)],
            'image' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
        ]);
    }

    /** Derive marketplace category from store category when not explicit. */
    private function marketplaceCategory(?string $storeCategory, ?string $explicit): ?string
    {
        if ($explicit) {
            return $explicit;
        }
        return match ($storeCategory) {
            'Electronics' => 'Electronics',
            'Fashion & Apparel' => 'Fashion',
            'Home & Lifestyle' => 'Home',
            'Health & Beauty' => 'Beauty',
            'Grocery & Market' => 'Groceries',
            default => null, // food items stay out of marketplace
        };
    }

    private function productShape(Product $p): array
    {
        return [
            'id' => $p->id,
            'name' => $p->name,
            'description' => $p->description,
            'category_id' => $p->category_id,
            'category' => $p->category?->name,
            'price' => (float) $p->price,
            'sku' => $p->sku,
            'stock' => $p->stock,
            'low_stock_alert' => $p->low_stock_alert,
            'track_stock' => (bool) $p->track_stock,
            'low_stock' => $p->track_stock && $p->stock <= $p->low_stock_alert,
            'images' => Media::urls($p->images),
            'status' => $p->status,
            'marketplace_category' => $p->marketplace_category,
        ];
    }
}
