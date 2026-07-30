import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/store_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrder(String id);
  Future<OrderModel> updateStatus(String id, OrderStatus status);
  Future<void> rejectOrder(String id);
}

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel> saveProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> saveCategories(List<CategoryModel> categories);
}

abstract class StoreRepository {
  Future<StoreModel> getStore();
  Future<StoreModel> saveStore(StoreModel store);
  Future<List<ReviewModel>> getReviews();
  Future<ReviewModel> replyToReview(String id, String reply);
  Future<List<PayoutModel>> getPayouts();
  Future<List<TransactionModel>> getTransactions();
  Future<Map<String, dynamic>> getRevenueSummary();
  Future<List<double>> getRevenueTrend(String period);
  Future<void> requestEarlyPayout();
}

class MockOrderRepository implements OrderRepository {
  MockOrderRepository() {
    _seed();
  }

  late List<OrderModel> _orders;
  final _rng = Random(42);

  Future<void> _latency() async {
    await Future<void>.delayed(
      Duration(milliseconds: 300 + _rng.nextInt(700)),
    );
  }

  void _seed() {
    final now = DateTime.now();
    _orders = [
      OrderModel(
        id: 'HG-8821',
        customerName: 'Marcus Thompson',
        customerPhone: '+1 (555) 012-3456',
        customerRating: 4.9,
        customerOrderCount: 12,
        priority: OrderPriority.priority,
        status: OrderStatus.newOrder,
        createdAt: now.subtract(const Duration(minutes: 2)),
        customerNote:
            'Please leave the bag on the bench outside and ring the bell once. Thank you!',
        items: const [
          OrderItem(
            name: 'Truffle Umami Burger',
            quantity: 1,
            price: 18.50,
            imageUrl:
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop',
            notes: 'Medium Rare • No Onions',
          ),
          OrderItem(
            name: 'Sweet Potato Fries',
            quantity: 1,
            price: 6.00,
            imageUrl:
                'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=200&h=200&fit=crop',
            notes: 'Large • Extra Dip',
          ),
          OrderItem(
            name: 'House Lemonade',
            quantity: 2,
            price: 4.50,
            imageUrl:
                'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=200&h=200&fit=crop',
            notes: 'Iced • Less Sugar',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8822',
        customerName: 'Sarah Jenkins',
        customerPhone: '+1 (555) 234-7890',
        customerRating: 4.7,
        customerOrderCount: 5,
        priority: OrderPriority.standard,
        status: OrderStatus.newOrder,
        createdAt: now.subtract(const Duration(minutes: 8)),
        items: const [
          OrderItem(
            name: 'Garden Fresh Salad',
            quantity: 1,
            price: 14.00,
            imageUrl:
                'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&h=200&fit=crop',
            notes: 'Vinaigrette on side',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8823',
        customerName: 'Priya Patel',
        customerPhone: '+1 (555) 111-2222',
        customerRating: 4.8,
        customerOrderCount: 22,
        priority: OrderPriority.express,
        status: OrderStatus.newOrder,
        createdAt: now.subtract(const Duration(minutes: 15)),
        items: const [
          OrderItem(
            name: 'Family Feast Pack',
            quantity: 1,
            price: 68.00,
            imageUrl:
                'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&h=200&fit=crop',
            notes: 'Extra napkins',
          ),
          OrderItem(
            name: 'Craft Soft Drinks',
            quantity: 4,
            price: 12.50,
            imageUrl:
                'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8825',
        customerName: 'David Chen',
        customerPhone: '+1 (555) 444-5555',
        customerRating: 5.0,
        customerOrderCount: 8,
        priority: OrderPriority.scheduled,
        status: OrderStatus.newOrder,
        createdAt: now.subtract(const Duration(hours: 1)),
        scheduledFor: DateTime(now.year, now.month, now.day, 14, 0),
        items: const [
          OrderItem(
            name: 'Dim Sum Platters',
            quantity: 3,
            price: 22.67,
            imageUrl:
                'https://images.unsplash.com/photo-1496116218417-1a781b3317e7?w=200&h=200&fit=crop',
            notes: 'Assorted variety, Soy sauce extra',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8820',
        customerName: 'Alex Rivera',
        customerPhone: '+1 (555) 888-9999',
        customerRating: 4.6,
        customerOrderCount: 3,
        priority: OrderPriority.standard,
        status: OrderStatus.newOrder,
        createdAt: now.subtract(const Duration(minutes: 22)),
        items: const [
          OrderItem(
            name: 'Wagyu Truffle Burger',
            quantity: 1,
            price: 24.00,
            imageUrl:
                'https://images.unsplash.com/photo-1550547660-d9450f859349?w=200&h=200&fit=crop',
            notes: 'No onions, extra sauce',
          ),
          OrderItem(
            name: 'Loaded Fries',
            quantity: 1,
            price: 8.50,
            imageUrl:
                'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8818',
        customerName: 'Alex Thompson',
        customerPhone: '+1 (555) 321-6540',
        customerRating: 4.9,
        customerOrderCount: 15,
        priority: OrderPriority.priority,
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(minutes: 18)),
        customerNote: 'Extra spicy please!',
        items: const [
          OrderItem(
            name: 'Spicy Ramen Bowl',
            quantity: 2,
            price: 16.50,
            imageUrl:
                'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&h=200&fit=crop',
            notes: 'Extra chili oil',
          ),
          OrderItem(
            name: 'Gyoza Dumplings',
            quantity: 1,
            price: 9.00,
            imageUrl:
                'https://images.unsplash.com/photo-1496116218417-1a781b3317e7?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8817',
        customerName: 'Jordan Lee',
        customerPhone: '+1 (555) 777-1234',
        customerRating: 4.5,
        customerOrderCount: 7,
        priority: OrderPriority.standard,
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(minutes: 25)),
        items: const [
          OrderItem(
            name: 'Avocado Toast Plate',
            quantity: 1,
            price: 13.00,
            imageUrl:
                'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=200&h=200&fit=crop',
          ),
          OrderItem(
            name: 'Cold Brew Coffee',
            quantity: 2,
            price: 5.50,
            imageUrl:
                'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8816',
        customerName: 'Sam Okonkwo',
        customerPhone: '+1 (555) 555-0101',
        customerRating: 4.8,
        customerOrderCount: 19,
        priority: OrderPriority.express,
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(minutes: 32)),
        customerNote: 'Call on arrival',
        items: const [
          OrderItem(
            name: 'Grilled Salmon Bowl',
            quantity: 1,
            price: 22.00,
            imageUrl:
                'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8815',
        customerName: 'Mia Chen',
        customerPhone: '+1 (555) 202-3030',
        customerRating: 5.0,
        customerOrderCount: 4,
        priority: OrderPriority.standard,
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(minutes: 40)),
        items: const [
          OrderItem(
            name: 'Vegan Buddha Bowl',
            quantity: 2,
            price: 15.50,
            imageUrl:
                'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8810',
        customerName: 'Chris Walker',
        customerPhone: '+1 (555) 909-8080',
        customerRating: 4.4,
        customerOrderCount: 2,
        priority: OrderPriority.standard,
        status: OrderStatus.ready,
        createdAt: now.subtract(const Duration(minutes: 55)),
        items: const [
          OrderItem(
            name: 'Classic Cheese Pizza',
            quantity: 1,
            price: 18.00,
            imageUrl:
                'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-8809',
        customerName: 'Nina Volkov',
        customerPhone: '+1 (555) 606-7070',
        customerRating: 4.9,
        customerOrderCount: 30,
        priority: OrderPriority.priority,
        status: OrderStatus.ready,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
        items: const [
          OrderItem(
            name: 'Matcha Latte',
            quantity: 2,
            price: 6.50,
            imageUrl:
                'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=200&h=200&fit=crop',
          ),
          OrderItem(
            name: 'Croissant',
            quantity: 3,
            price: 4.25,
            imageUrl:
                'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-92834',
        customerName: 'Elena Rodriguez',
        customerPhone: '+1 (555) 111-0000',
        customerRating: 4.8,
        customerOrderCount: 11,
        priority: OrderPriority.standard,
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 2)),
        deliveredAt: now.subtract(const Duration(days: 2, hours: -2)),
        rating: 5.0,
        items: const [
          OrderItem(
            name: 'Premium Urban Backpack',
            quantity: 1,
            price: 124.00,
            imageUrl:
                'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-92830',
        customerName: 'Mark Thompson',
        customerPhone: '+1 (555) 222-1111',
        customerRating: 4.6,
        customerOrderCount: 6,
        priority: OrderPriority.standard,
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 3)),
        deliveredAt: now.subtract(const Duration(days: 3)),
        rating: 4.0,
        items: const [
          OrderItem(
            name: 'Wireless Earbuds Pro',
            quantity: 1,
            price: 89.00,
            imageUrl:
                'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=200&h=200&fit=crop',
          ),
        ],
      ),
      OrderModel(
        id: 'HG-92828',
        customerName: 'Chris Lee',
        customerPhone: '+1 (555) 333-2222',
        customerRating: 4.2,
        customerOrderCount: 9,
        priority: OrderPriority.express,
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 5)),
        deliveredAt: now.subtract(const Duration(days: 5)),
        rating: 3.0,
        items: const [
          OrderItem(
            name: 'Organic Coffee Bundle',
            quantity: 2,
            price: 32.00,
            imageUrl:
                'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200&h=200&fit=crop',
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    await _latency();
    return List.from(_orders);
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    await _latency();
    final clean = id.replaceAll('#', '');
    return _orders.firstWhere(
      (o) => o.id == clean || o.id == id,
      orElse: () => throw Exception('Order not found'),
    );
  }

  @override
  Future<OrderModel> updateStatus(String id, OrderStatus status) async {
    await _latency();
    final order = await getOrder(id);
    order.status = status;
    if (status == OrderStatus.delivered) {
      order.deliveredAt = DateTime.now();
      order.rating ??= 5.0;
    }
    return order;
  }

  @override
  Future<void> rejectOrder(String id) async {
    await _latency();
    final order = await getOrder(id);
    order.status = OrderStatus.rejected;
  }
}

class MockProductRepository implements ProductRepository {
  MockProductRepository() {
    _seed();
  }

  late List<ProductModel> _products;
  late List<CategoryModel> _categories;
  final _rng = Random(7);

  Future<void> _latency() async {
    await Future<void>.delayed(
      Duration(milliseconds: 300 + _rng.nextInt(600)),
    );
  }

  void _seed() {
    _categories = [
      CategoryModel(
        id: 'c1',
        name: 'Bakery',
        icon: Icons.bakery_dining_outlined,
        color: const Color(0xFFBBDEFB),
        itemCount: 24,
        isVisible: true,
        sortOrder: 0,
      ),
      CategoryModel(
        id: 'c2',
        name: 'Beverages',
        icon: Icons.local_cafe_outlined,
        color: const Color(0xFFFFE0B2),
        itemCount: 18,
        isVisible: true,
        sortOrder: 1,
      ),
      CategoryModel(
        id: 'c3',
        name: 'Dairy & Eggs',
        icon: Icons.egg_outlined,
        color: const Color(0xFFDCEDC8),
        itemCount: 12,
        isVisible: false,
        sortOrder: 2,
      ),
      CategoryModel(
        id: 'c4',
        name: 'Frozen Foods',
        icon: Icons.icecream_outlined,
        color: const Color(0xFFC5CAE9),
        itemCount: 9,
        isVisible: true,
        sortOrder: 3,
      ),
      CategoryModel(
        id: 'c5',
        name: 'Pantry',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFFE0E0E0),
        itemCount: 31,
        isVisible: true,
        sortOrder: 4,
      ),
      CategoryModel(
        id: 'c6',
        name: 'Electronics',
        icon: Icons.headphones_outlined,
        color: const Color(0xFFB3E5FC),
        itemCount: 14,
        isVisible: true,
        sortOrder: 5,
      ),
      CategoryModel(
        id: 'c7',
        name: 'Apparel',
        icon: Icons.checkroom_outlined,
        color: const Color(0xFFF8BBD0),
        itemCount: 22,
        isVisible: true,
        sortOrder: 6,
      ),
      CategoryModel(
        id: 'c8',
        name: 'Home',
        icon: Icons.chair_outlined,
        color: const Color(0xFFD7CCC8),
        itemCount: 16,
        isVisible: true,
        sortOrder: 7,
      ),
    ];

    _products = [
      ProductModel(
        id: 'p1',
        name: 'Aura Pro Wireless Headphones',
        description: 'Premium noise-cancelling over-ear headphones with 40h battery.',
        category: 'Electronics',
        price: 199.00,
        sku: 'AUR-2024',
        stock: 42,
        lowStockAlert: 5,
        imageUrls: const [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p2',
        name: 'Nordic Desk Lamp',
        description: 'Minimalist LED desk lamp with warm/cool modes.',
        category: 'Home',
        price: 64.00,
        sku: 'NDL-110',
        stock: 2,
        lowStockAlert: 5,
        imageUrls: const [
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p3',
        name: 'Hillside Roast Coffee',
        description: 'Single-origin medium roast, 12oz bag.',
        category: 'Beverages',
        price: 18.50,
        sku: 'COF-HS-12',
        stock: 56,
        lowStockAlert: 10,
        imageUrls: const [
          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p4',
        name: 'Aluminum Laptop Stand',
        description: 'Ergonomic adjustable stand for 13–16" laptops.',
        category: 'Electronics',
        stock: 3,
        lowStockAlert: 5,
        price: 49.00,
        sku: 'ALS-300',
        imageUrls: const [
          'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p5',
        name: 'Artisanal Sourdough Batard',
        description:
            'Our signature sourdough batard is fermented for 24 hours using a 50-year-old starter for deep flavor and a crisp crust.',
        category: 'Bakery',
        price: 8.50,
        sku: 'BAKE-SRD-01',
        stock: 18,
        lowStockAlert: 5,
        imageUrls: const [
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400&h=400&fit=crop',
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p6',
        name: 'Organic Cotton Tee',
        description: 'Soft unisex tee in forest green.',
        category: 'Apparel',
        price: 28.00,
        sku: 'APP-TEE-01',
        stock: 64,
        lowStockAlert: 8,
        imageUrls: const [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p7',
        name: 'Cold-Pressed Orange Juice',
        description: 'Fresh squeezed, no sugar added, 16oz.',
        category: 'Beverages',
        price: 6.50,
        sku: 'BEV-OJ-16',
        stock: 4,
        lowStockAlert: 6,
        imageUrls: const [
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=400&fit=crop',
        ],
      ),
      ProductModel(
        id: 'p8',
        name: 'Farm Fresh Eggs (Dozen)',
        description: 'Free-range eggs from local farms.',
        category: 'Dairy & Eggs',
        price: 5.99,
        sku: 'DRY-EGG-12',
        stock: 40,
        lowStockAlert: 10,
        imageUrls: const [
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop',
        ],
      ),
    ];
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    await _latency();
    return List.from(_products);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await _latency();
    final sorted = List<CategoryModel>.from(_categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  @override
  Future<ProductModel> saveProduct(ProductModel product) async {
    await _latency();
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
    } else {
      _products.insert(0, product);
    }
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _latency();
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _latency();
    _categories = List.from(categories);
  }
}

class MockStoreRepository implements StoreRepository {
  MockStoreRepository() {
    _seed();
  }

  late StoreModel _store;
  late List<ReviewModel> _reviews;
  late List<PayoutModel> _payouts;
  late List<TransactionModel> _transactions;
  final _rng = Random(11);

  Future<void> _latency() async {
    await Future<void>.delayed(
      Duration(milliseconds: 350 + _rng.nextInt(650)),
    );
  }

  void _seed() {
    _store = StoreModel(
      name: 'GreenLeaf Markets',
      description:
          'Premium organic groceries and artisanal products sourced from local farms across the hill region.',
      address: '128 Urban Center Dr, Suite 400',
      specialties: 'Organic, Fresh Produce, Local Bakery',
      bio:
          'Tell your customers about your store, your mission, and what makes you unique...',
      latitude: 40.7128,
      longitude: -74.0060,
      isOpen: true,
      acceptingOrders: true,
      bannerUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&h=400&fit=crop',
      logoUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop',
      hours: {
        'Monday': BusinessHours(
          open: const TimeOfDay(hour: 8, minute: 0),
          close: const TimeOfDay(hour: 20, minute: 0),
        ),
        'Tuesday': BusinessHours(
          open: const TimeOfDay(hour: 8, minute: 0),
          close: const TimeOfDay(hour: 20, minute: 0),
        ),
        'Wednesday': BusinessHours(
          open: const TimeOfDay(hour: 8, minute: 0),
          close: const TimeOfDay(hour: 20, minute: 0),
        ),
        'Thursday': BusinessHours(
          open: const TimeOfDay(hour: 8, minute: 0),
          close: const TimeOfDay(hour: 20, minute: 0),
        ),
        'Friday': BusinessHours(
          open: const TimeOfDay(hour: 8, minute: 0),
          close: const TimeOfDay(hour: 21, minute: 0),
        ),
        'Saturday': BusinessHours(
          open: const TimeOfDay(hour: 9, minute: 0),
          close: const TimeOfDay(hour: 18, minute: 0),
        ),
        'Sunday': BusinessHours(
          open: const TimeOfDay(hour: 10, minute: 0),
          close: const TimeOfDay(hour: 16, minute: 0),
          isClosed: true,
        ),
      },
    );

    final now = DateTime.now();
    _reviews = [
      ReviewModel(
        id: 'r1',
        customerName: 'Elena Rodriguez',
        avatarUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop',
        rating: 5,
        comment:
            'Fast delivery and eco-friendly packaging! Everything arrived fresh. Will order again.',
        createdAt: now.subtract(const Duration(hours: 2)),
        imageUrls: const [
          'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=200&h=200&fit=crop',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&h=200&fit=crop',
        ],
      ),
      ReviewModel(
        id: 'r2',
        customerName: 'Mark Thompson',
        avatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop',
        rating: 4,
        comment:
            'Great quality produce. Delivery was a bit late but the items made up for it.',
        createdAt: now.subtract(const Duration(hours: 8)),
        reply:
            'Thank you Mark! We apologize for the delay and appreciate your patience. Looking forward to serving you again.',
        repliedAt: now.subtract(const Duration(hours: 6)),
      ),
      ReviewModel(
        id: 'r3',
        customerName: 'Chris Lee',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop',
        rating: 3,
        comment:
            'Packaging was good but one item was missing from my order. Support was helpful though.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ReviewModel(
        id: 'r4',
        customerName: 'Alex Thompson',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop',
        rating: 4.8,
        comment:
            'The delivery was incredibly fast! The packaging was sustainable and my order arrived in perfect condition. I really appreciate the attention to detail on the custom notes. Will definitely order from this store again.',
        createdAt: now.subtract(const Duration(hours: 2)),
        imageUrls: const [
          'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=200&h=200&fit=crop',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&h=200&fit=crop',
        ],
      ),
    ];

    _payouts = [
      PayoutModel(
        id: 'HG-99281',
        amount: 1240.00,
        date: DateTime(2023, 10, 24),
        status: PayoutStatus.completed,
      ),
      PayoutModel(
        id: 'HG-99304',
        amount: 850.50,
        date: DateTime(2023, 10, 26),
        status: PayoutStatus.pending,
      ),
      PayoutModel(
        id: 'HG-99110',
        amount: 2100.00,
        date: DateTime(2023, 10, 17),
        status: PayoutStatus.completed,
      ),
      PayoutModel(
        id: 'HG-99055',
        amount: 540.25,
        date: DateTime(2023, 10, 10),
        status: PayoutStatus.completed,
      ),
      PayoutModel(
        id: 'HG-98990',
        amount: 3200.00,
        date: DateTime(2023, 9, 28),
        status: PayoutStatus.completed,
      ),
    ];

    _transactions = [
      TransactionModel(
        id: 't1',
        title: 'Order #HG-9921',
        subtitle: '20 Oct, 11:45 AM • HillGo Delivery',
        amount: 84.00,
        date: DateTime(2023, 10, 20, 11, 45),
        type: TransactionType.order,
        statusLabel: 'Completed',
      ),
      TransactionModel(
        id: 't2',
        title: 'Weekly Payout',
        subtitle: '19 Oct, 09:12 AM • Bank Transfer',
        amount: -2150.00,
        date: DateTime(2023, 10, 19, 9, 12),
        type: TransactionType.payout,
        statusLabel: 'Processed',
      ),
      TransactionModel(
        id: 't3',
        title: 'Order #HG-9844',
        subtitle: '18 Oct, 04:30 PM • HillGo Delivery',
        amount: 124.50,
        date: DateTime(2023, 10, 18, 16, 30),
        type: TransactionType.order,
        statusLabel: 'Completed',
      ),
    ];
  }

  @override
  Future<StoreModel> getStore() async {
    await _latency();
    return _store;
  }

  @override
  Future<StoreModel> saveStore(StoreModel store) async {
    await _latency();
    _store = store;
    return _store;
  }

  @override
  Future<List<ReviewModel>> getReviews() async {
    await _latency();
    return List.from(_reviews);
  }

  @override
  Future<ReviewModel> replyToReview(String id, String reply) async {
    await _latency();
    final review = _reviews.firstWhere((r) => r.id == id);
    review.reply = reply;
    review.repliedAt = DateTime.now();
    return review;
  }

  @override
  Future<List<PayoutModel>> getPayouts() async {
    await _latency();
    return List.from(_payouts);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await _latency();
    return List.from(_transactions);
  }

  @override
  Future<Map<String, dynamic>> getRevenueSummary() async {
    await _latency();
    return {
      'totalRevenue': 42850.20,
      'pendingPayout': 3240.00,
      'orders': 1204,
      'growthPercent': 12.5,
      'nextPayoutDate': DateTime(2023, 10, 24),
      'totalWithdrawn': 12450.00,
      'lastPayoutDate': DateTime(2023, 10, 24),
      'todaySales': 12840.50,
      'todayOrders': 148,
      'rating': 4.8,
      'reviewCount': 1284,
    };
  }

  @override
  Future<List<double>> getRevenueTrend(String period) async {
    await _latency();
    switch (period) {
      case 'Weekly':
        return [4200, 5100, 4800, 6200, 5900, 7100, 6800];
      case 'Monthly':
        return [28000, 31000, 29500, 34000, 36000, 42850];
      default:
        return [1800, 2200, 1950, 2400, 2100, 2800, 2650];
    }
  }

  @override
  Future<void> requestEarlyPayout() async {
    await _latency();
  }
}
