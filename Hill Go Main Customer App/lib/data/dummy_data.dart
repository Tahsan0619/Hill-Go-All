import 'package:flutter/material.dart';

import 'app_images.dart';
import '../theme/app_theme.dart';

/// Simple in-memory product model used to power the marketplace screens
/// with dummy data until a real catalog API is wired in.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.description,
    this.icon = Icons.shopping_bag_outlined,
    this.imageColor = AppColors.accentBlueSoft,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final String description;
  final IconData icon;
  final Color imageColor;
  final String? imageUrl;
}

/// Category metadata for the marketplace category grid.
class ProductCategory {
  const ProductCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
}

const List<ProductCategory> dummyCategories = [
  ProductCategory(
    label: 'Electronics',
    icon: Icons.headphones_outlined,
    color: AppColors.primaryNavy,
    background: Color(0xFFEAF1FB),
  ),
  ProductCategory(
    label: 'Fashion',
    icon: Icons.checkroom_outlined,
    color: AppColors.accentOrange,
    background: AppColors.accentOrangeSoft,
  ),
  ProductCategory(
    label: 'Home',
    icon: Icons.chair_outlined,
    color: Color(0xFF5B8A00),
    background: Color(0xFFEFFAE6),
  ),
  ProductCategory(
    label: 'Beauty',
    icon: Icons.spa_outlined,
    color: Color(0xFFB4218C),
    background: Color(0xFFFCE4F3),
  ),
  ProductCategory(
    label: 'Groceries',
    icon: Icons.local_grocery_store_outlined,
    color: Color(0xFF2E9E44),
    background: Color(0xFFE8F8EB),
  ),
  ProductCategory(
    label: 'Sports',
    icon: Icons.sports_soccer_outlined,
    color: AppColors.accentBlue,
    background: AppColors.accentBlueSoft,
  ),
];

const List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'Acoustic Pro Wireless Headphones',
    category: 'Electronics',
    price: 299.00,
    rating: 4.9,
    description:
        'Studio-grade over-ear headphones with ANC, 40-hour battery and '
        'premium memory-foam cushions.',
    icon: Icons.headphones_outlined,
    imageColor: AppColors.accentBlueSoft,
    imageUrl: AppImages.headphones,
  ),
  Product(
    id: 'p2',
    name: 'HillGo Book Air M3 Pro',
    category: 'Electronics',
    price: 1299.00,
    rating: 4.8,
    description:
        'Ultra-thin laptop with M3 chip, 18-hour battery and a stunning '
        'Liquid Retina display.',
    icon: Icons.laptop_mac_outlined,
    imageColor: AppColors.accentBlueSoft,
    imageUrl: AppImages.laptop,
  ),
  Product(
    id: 'p3',
    name: 'Velocity Smart Watch Series 7',
    category: 'Electronics',
    price: 189.99,
    rating: 4.7,
    description:
        'Track fitness, heart rate and sleep with a bright always-on '
        'AMOLED display and GPS.',
    icon: Icons.watch_outlined,
    imageColor: AppColors.accentBlueSoft,
    imageUrl: AppImages.smartwatch,
  ),
  Product(
    id: 'p4',
    name: 'Alpha 900 Mirrorless Camera',
    category: 'Electronics',
    price: 2450.00,
    rating: 4.9,
    description:
        'Full-frame mirrorless camera with 4K video, fast autofocus and '
        'professional-grade image quality.',
    icon: Icons.camera_alt_outlined,
    imageColor: AppColors.accentOrangeSoft,
    imageUrl: AppImages.camera,
  ),
  Product(
    id: 'p5',
    name: 'SonicBoom Portable Speaker',
    category: 'Electronics',
    price: 129.00,
    rating: 4.6,
    description:
        'Waterproof Bluetooth speaker with 360° sound and 24-hour playtime.',
    icon: Icons.speaker_outlined,
    imageColor: Color(0xFFEFFAE6),
    imageUrl: AppImages.speaker,
  ),
  Product(
    id: 'p6',
    name: 'Urban Runner Sneakers',
    category: 'Sports',
    price: 74.50,
    rating: 4.6,
    description:
        'Lightweight breathable sneakers with responsive cushioning for '
        'daily runs and street style.',
    icon: Icons.directions_run,
    imageColor: AppColors.accentBlueSoft,
    imageUrl: AppImages.sneakers,
  ),
  Product(
    id: 'p7',
    name: 'Organic Face Serum',
    category: 'Beauty',
    price: 22.50,
    rating: 4.4,
    description:
        'Vitamin C serum with botanical extracts to brighten and even skin tone.',
    icon: Icons.spa_outlined,
    imageColor: Color(0xFFFCE4F3),
    imageUrl: AppImages.skincare,
  ),
  Product(
    id: 'p8',
    name: 'Yoga Mat Pro',
    category: 'Sports',
    price: 27.00,
    rating: 4.8,
    description:
        'Extra-thick non-slip yoga mat with carry strap for home workouts.',
    icon: Icons.self_improvement_outlined,
    imageColor: AppColors.accentBlueSoft,
    imageUrl: AppImages.yogaMat,
  ),
];

/// A single line item inside the marketplace cart.
class CartLine {
  CartLine({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get lineTotal => product.price * quantity;
}

/// Saved address entry for the profile "Saved Addresses" screen.
class SavedAddress {
  const SavedAddress({
    required this.label,
    required this.address,
    this.icon = Icons.location_on_outlined,
    this.isDefault = false,
  });

  final String label;
  final String address;
  final IconData icon;
  final bool isDefault;
}

const List<SavedAddress> dummyAddresses = [
  SavedAddress(
    label: 'Home',
    address: 'House 12, Road 5, Banani, Dhaka 1213',
    icon: Icons.home_outlined,
    isDefault: true,
  ),
  SavedAddress(
    label: 'Work',
    address: 'Level 4, Gulshan Avenue, Dhaka 1212',
    icon: Icons.work_outline,
  ),
  SavedAddress(
    label: 'Other',
    address: 'Plot 8, Block C, Bashundhara R/A, Dhaka',
    icon: Icons.place_outlined,
  ),
];

/// Wallet transaction entry for the wallet screen history list.
class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.dateLabel,
    required this.amount,
    this.isCredit = false,
    this.icon = Icons.receipt_long_outlined,
  });

  final String title;
  final String dateLabel;
  final double amount;
  final bool isCredit;
  final IconData icon;
}

const List<WalletTransaction> dummyTransactions = [
  WalletTransaction(
    title: 'Added money via bKash',
    dateLabel: 'Today, 10:24 AM',
    amount: 100.00,
    isCredit: true,
    icon: Icons.add_card_outlined,
  ),
  WalletTransaction(
    title: 'Parcel delivery payment',
    dateLabel: 'Yesterday, 6:12 PM',
    amount: 8.50,
    icon: Icons.local_shipping_outlined,
  ),
  WalletTransaction(
    title: 'Marketplace order #4821',
    dateLabel: 'Jul 27, 2:45 PM',
    amount: 59.99,
    icon: Icons.shopping_bag_outlined,
  ),
  WalletTransaction(
    title: 'Cashback reward',
    dateLabel: 'Jul 25, 9:00 AM',
    amount: 5.00,
    isCredit: true,
    icon: Icons.card_giftcard_outlined,
  ),
  WalletTransaction(
    title: 'Ride to Gulshan',
    dateLabel: 'Jul 24, 8:30 AM',
    amount: 6.20,
    icon: Icons.two_wheeler_outlined,
  ),
];

/// Mutable booking draft carried across the parcel booking flow screens.
class ParcelBooking {
  ParcelBooking({
    this.parcelType,
    this.pickupAddress = '',
    this.pickupContact = '',
    this.pickupPhone = '',
    this.receiverAddress = '',
    this.receiverContact = '',
    this.receiverPhone = '',
    this.distanceKm = 6.4,
    this.weightKg = 2.0,
  });

  String? parcelType;
  String pickupAddress;
  String pickupContact;
  String pickupPhone;
  String receiverAddress;
  String receiverContact;
  String receiverPhone;
  double distanceKm;
  double weightKg;

  static const double baseFare = 2.5;
  static const double perKmRate = 0.6;
  static const double perKgRate = 0.8;

  double get distanceFare => distanceKm * perKmRate;
  double get weightFare => weightKg * perKgRate;
  double get total => baseFare + distanceFare + weightFare;
}

/// Past parcel entry for the parcel history screen.
class ParcelHistoryEntry {
  const ParcelHistoryEntry({
    required this.trackingId,
    required this.type,
    required this.destination,
    required this.dateLabel,
    required this.status,
  });

  final String trackingId;
  final String type;
  final String destination;
  final String dateLabel;
  final String status;
}

const List<ParcelHistoryEntry> dummyParcelHistory = [
  ParcelHistoryEntry(
    trackingId: 'HG-93021',
    type: 'Document',
    destination: 'Chittagong',
    dateLabel: 'Jul 26, 2026',
    status: 'Delivered',
  ),
  ParcelHistoryEntry(
    trackingId: 'HG-93044',
    type: 'Box',
    destination: 'Sylhet',
    dateLabel: 'Jul 22, 2026',
    status: 'Delivered',
  ),
  ParcelHistoryEntry(
    trackingId: 'HG-93102',
    type: 'Fragile',
    destination: 'Cox\'s Bazar',
    dateLabel: 'Jul 18, 2026',
    status: 'Cancelled',
  ),
  ParcelHistoryEntry(
    trackingId: 'HG-93188',
    type: 'Box',
    destination: 'Rajshahi',
    dateLabel: 'Jul 10, 2026',
    status: 'Delivered',
  ),
];

// ---------------------------------------------------------------------------
// The section below powers the home dashboard / discovery / main-shell
// screens (restaurants, shops, nearby services, ride history, vouchers,
// addresses, languages, payment methods, food items and quick categories).
// Kept separate from the marketplace/profile/wallet/parcel models above to
// avoid clashing with their existing types.
// ---------------------------------------------------------------------------

class RestaurantItem {
  const RestaurantItem({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.icon,
    required this.iconColor,
    this.imageUrl,
    this.deliveryFee = 0,
    this.distanceKm = 1.0,
  });

  final String name;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final IconData icon;
  final Color iconColor;
  final String? imageUrl;
  final double deliveryFee;
  final double distanceKm;
}

class ShopItem {
  const ShopItem({
    required this.name,
    required this.category,
    required this.rating,
    required this.icon,
    required this.iconColor,
    this.imageUrl,
  });

  final String name;
  final String category;
  final double rating;
  final IconData icon;
  final Color iconColor;
  final String? imageUrl;
}

class ProductItem {
  const ProductItem({
    required this.name,
    required this.price,
    required this.category,
    required this.icon,
    required this.iconColor,
  });

  final String name;
  final double price;
  final String category;
  final IconData icon;
  final Color iconColor;
}

class NearbyServiceItem {
  const NearbyServiceItem({
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.rating,
    required this.icon,
    this.imageUrl,
    this.hours = 'Open now',
    this.filterCategory,
  });

  final String name;
  final String type;
  final double distanceKm;
  final double rating;
  final IconData icon;
  final String? imageUrl;
  final String hours;
  /// Matches filter chips on the nearby services screen (e.g. Salon, Pharmacy).
  final String? filterCategory;
}

class RideHistoryItem {
  const RideHistoryItem({
    required this.from,
    required this.to,
    required this.date,
    required this.fare,
    required this.status,
  });

  final String from;
  final String to;
  final String date;
  final double fare;
  final String status;
}

class ParcelItem {
  const ParcelItem({
    required this.trackingId,
    required this.recipient,
    required this.date,
    required this.status,
  });

  final String trackingId;
  final String recipient;
  final String date;
  final String status;
}

class VoucherItem {
  const VoucherItem({
    required this.title,
    required this.description,
    required this.expiry,
    required this.icon,
  });

  final String title;
  final String description;
  final String expiry;
  final IconData icon;
}

class AddressItem {
  const AddressItem({
    required this.label,
    required this.details,
    required this.icon,
  });

  final String label;
  final String details;
  final IconData icon;
}

class LanguageItem {
  const LanguageItem({required this.name, required this.nativeName});

  final String name;
  final String nativeName;
}

class PaymentMethodItem {
  const PaymentMethodItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
}

class FoodItem {
  const FoodItem({
    required this.name,
    required this.price,
    required this.icon,
    required this.iconColor,
  });

  final String name;
  final double price;
  final IconData icon;
  final Color iconColor;
}

class CategoryItem {
  const CategoryItem({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
}

class DummyData {
  DummyData._();

  static const List<RestaurantItem> restaurants = [
    RestaurantItem(
      name: 'Urban Grill House',
      cuisine: 'Burgers • 1.2 km • 20 mins',
      rating: 4.8,
      deliveryTime: '20-30 min',
      icon: Icons.lunch_dining,
      iconColor: AppColors.accentOrange,
      imageUrl: AppImages.burger,
      deliveryFee: 0,
      distanceKm: 1.2,
    ),
    RestaurantItem(
      name: 'Zen Sushi House',
      cuisine: 'Japanese • 0.8 km • 25 mins',
      rating: 4.9,
      deliveryTime: '25-35 min',
      icon: Icons.set_meal,
      iconColor: AppColors.accentBlue,
      imageUrl: AppImages.sushi,
      deliveryFee: 2.99,
      distanceKm: 0.8,
    ),
    RestaurantItem(
      name: 'Artisan Pizza Hub',
      cuisine: 'Italian • 1.5 km • 18 mins',
      rating: 4.7,
      deliveryTime: '18-28 min',
      icon: Icons.local_pizza,
      iconColor: AppColors.brandLime,
      imageUrl: AppImages.pizza,
      deliveryFee: 0,
      distanceKm: 1.5,
    ),
    RestaurantItem(
      name: 'Spice Route Kitchen',
      cuisine: 'Bengali • 2.1 km • 30 mins',
      rating: 4.6,
      deliveryTime: '28-38 min',
      icon: Icons.rice_bowl,
      iconColor: AppColors.primaryNavy,
      imageUrl: AppImages.biryani,
      deliveryFee: 1.99,
      distanceKm: 2.1,
    ),
    RestaurantItem(
      name: 'Green Bowl Cafe',
      cuisine: 'Healthy • 0.6 km • 15 mins',
      rating: 4.5,
      deliveryTime: '15-22 min',
      icon: Icons.eco,
      iconColor: AppColors.brandLime,
      imageUrl: AppImages.salad,
      deliveryFee: 0,
      distanceKm: 0.6,
    ),
  ];

  static const List<ShopItem> shops = [
    ShopItem(
      name: 'Bloom & Stem',
      category: 'Gifts • Boutique',
      rating: 4.9,
      icon: Icons.local_florist,
      iconColor: AppColors.accentOrange,
      imageUrl: AppImages.flowers,
    ),
    ShopItem(
      name: 'Fresh Mart',
      category: 'Groceries • Organic',
      rating: 4.7,
      icon: Icons.storefront,
      iconColor: AppColors.brandLime,
      imageUrl: AppImages.groceries,
    ),
    ShopItem(
      name: 'Tech Corner',
      category: 'Electronics • Gadgets',
      rating: 4.8,
      icon: Icons.devices_other,
      iconColor: AppColors.accentBlue,
      imageUrl: AppImages.electronics,
    ),
    ShopItem(
      name: 'Style Studio',
      category: 'Fashion • Lifestyle',
      rating: 4.5,
      icon: Icons.checkroom,
      iconColor: AppColors.primaryNavy,
      imageUrl: AppImages.boutique,
    ),
  ];

  static const List<ProductItem> products = [
    ProductItem(
      name: 'Organic Rice 5kg',
      price: 450,
      category: 'Groceries',
      icon: Icons.rice_bowl_outlined,
      iconColor: AppColors.accentOrange,
    ),
    ProductItem(
      name: 'Fresh Vegetable Pack',
      price: 220,
      category: 'Groceries',
      icon: Icons.eco_outlined,
      iconColor: AppColors.brandLime,
    ),
    ProductItem(
      name: 'Cotton T-Shirt',
      price: 590,
      category: 'Fashion',
      icon: Icons.checkroom_outlined,
      iconColor: AppColors.accentBlue,
    ),
    ProductItem(
      name: 'Wireless Earbuds',
      price: 2500,
      category: 'Electronics',
      icon: Icons.headphones,
      iconColor: AppColors.primaryNavy,
    ),
  ];

  static const List<NearbyServiceItem> nearbyServices = [
    NearbyServiceItem(
      name: 'Express Courier Hub',
      type: 'Parcel pickup & drop-off',
      distanceKm: 0.4,
      rating: 4.8,
      icon: Icons.local_shipping_outlined,
      imageUrl: AppImages.parcelCounter,
      hours: 'Closes 10 PM',
    ),
    NearbyServiceItem(
      name: 'Eco-Bike Station',
      type: 'Sustainable last-mile travel',
      distanceKm: 1.2,
      rating: 4.5,
      icon: Icons.pedal_bike_outlined,
      imageUrl: AppImages.ebike,
      hours: '24/7 Available',
    ),
    NearbyServiceItem(
      name: 'Marketplace Hub',
      type: 'Local merchant collection',
      distanceKm: 2.8,
      rating: 4.9,
      icon: Icons.warehouse_outlined,
      imageUrl: AppImages.warehouse,
      hours: 'Closes 8 PM',
    ),
    NearbyServiceItem(
      name: 'Hill Salon & Spa',
      type: 'Beauty & wellness',
      distanceKm: 1.5,
      rating: 4.6,
      icon: Icons.content_cut,
      imageUrl: AppImages.salon,
      hours: 'Closes 9 PM',
      filterCategory: 'Salon',
    ),
    NearbyServiceItem(
      name: 'Metro Pharmacy',
      type: '24h medicine delivery',
      distanceKm: 0.5,
      rating: 4.8,
      icon: Icons.local_pharmacy_outlined,
      imageUrl: AppImages.pharmacy,
      hours: 'Open 24/7',
      filterCategory: 'Pharmacy',
    ),
    NearbyServiceItem(
      name: 'QuickFix Mobile Repair',
      type: 'Phone & gadget repair',
      distanceKm: 0.9,
      rating: 4.7,
      icon: Icons.build_outlined,
      imageUrl: AppImages.electronics,
      hours: 'Closes 8 PM',
      filterCategory: 'Repair',
    ),
    NearbyServiceItem(
      name: 'FreshFold Laundry',
      type: 'Wash, dry & fold service',
      distanceKm: 1.1,
      rating: 4.4,
      icon: Icons.local_laundry_service_outlined,
      imageUrl: AppImages.laundry,
      hours: 'Open now',
      filterCategory: 'Laundry',
    ),
  ];

  static const List<RideHistoryItem> rideHistory = [
    RideHistoryItem(
      from: 'Home',
      to: 'Central Mall',
      date: 'Jul 28, 4:30 PM',
      fare: 180,
      status: 'Completed',
    ),
    RideHistoryItem(
      from: 'Office',
      to: 'Riverside Cafe',
      date: 'Jul 26, 1:10 PM',
      fare: 120,
      status: 'Completed',
    ),
    RideHistoryItem(
      from: 'Home',
      to: 'Airport',
      date: 'Jul 20, 6:00 AM',
      fare: 450,
      status: 'Cancelled',
    ),
  ];

  static const List<ParcelItem> parcels = [
    ParcelItem(
      trackingId: 'HG-93821',
      recipient: 'Ayesha Rahman',
      date: 'Jul 29, 2026',
      status: 'In Transit',
    ),
    ParcelItem(
      trackingId: 'HG-93744',
      recipient: 'Tanvir Ahmed',
      date: 'Jul 25, 2026',
      status: 'Delivered',
    ),
    ParcelItem(
      trackingId: 'HG-93650',
      recipient: 'Nusrat Jahan',
      date: 'Jul 18, 2026',
      status: 'Delivered',
    ),
  ];

  static const List<VoucherItem> vouchers = [
    VoucherItem(
      title: '30% Off Ride',
      description: 'Valid on your next 3 rides',
      expiry: 'Expires Aug 15',
      icon: Icons.local_taxi,
    ),
    VoucherItem(
      title: 'Free Delivery',
      description: 'On orders above 500 BDT',
      expiry: 'Expires Aug 10',
      icon: Icons.delivery_dining,
    ),
    VoucherItem(
      title: '10% Cashback',
      description: 'Pay with Hill Wallet',
      expiry: 'Expires Sep 01',
      icon: Icons.account_balance_wallet,
    ),
  ];

  static const List<AddressItem> addresses = [
    AddressItem(
      label: 'Home',
      details: '24 Hilltop Road, Chattogram',
      icon: Icons.home_outlined,
    ),
    AddressItem(
      label: 'Office',
      details: 'Level 4, Trade Center, GEC Circle',
      icon: Icons.apartment_outlined,
    ),
    AddressItem(
      label: 'Gym',
      details: 'Fitness Hub, Khulshi Road',
      icon: Icons.fitness_center,
    ),
  ];

  static const List<LanguageItem> languages = [
    LanguageItem(name: 'English', nativeName: 'English'),
    LanguageItem(name: 'Bengali', nativeName: 'বাংলা'),
    LanguageItem(name: 'Hindi', nativeName: 'हिन्दी'),
    LanguageItem(name: 'Chakma', nativeName: 'Chakma'),
  ];

  static const List<PaymentMethodItem> paymentMethods = [
    PaymentMethodItem(
      name: 'Hill Wallet',
      subtitle: 'Balance: 1,250 BDT',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.primaryNavy,
    ),
    PaymentMethodItem(
      name: 'bKash',
      subtitle: 'Linked account',
      iconColor: AppColors.accentOrange,
      icon: Icons.phone_iphone,
    ),
    PaymentMethodItem(
      name: 'Visa Card',
      subtitle: '**** **** **** 4821',
      icon: Icons.credit_card,
      iconColor: AppColors.accentBlue,
    ),
    PaymentMethodItem(
      name: 'Cash',
      subtitle: 'Pay on delivery',
      icon: Icons.payments_outlined,
      iconColor: AppColors.brandLime,
    ),
  ];

  static const List<FoodItem> foodItems = [
    FoodItem(
      name: 'Beef Burger',
      price: 350,
      icon: Icons.lunch_dining,
      iconColor: AppColors.accentOrange,
    ),
    FoodItem(
      name: 'Chicken Biriyani',
      price: 280,
      icon: Icons.rice_bowl,
      iconColor: AppColors.accentBlue,
    ),
    FoodItem(
      name: 'Veggie Pizza',
      price: 590,
      icon: Icons.local_pizza,
      iconColor: AppColors.brandLime,
    ),
    FoodItem(
      name: 'Cold Coffee',
      price: 150,
      icon: Icons.coffee,
      iconColor: AppColors.primaryNavy,
    ),
  ];

  static const List<CategoryItem> categories = [
    CategoryItem(
      label: 'Food',
      icon: Icons.restaurant,
      iconColor: AppColors.accentOrange,
    ),
    CategoryItem(
      label: 'Marketplace',
      icon: Icons.storefront,
      iconColor: AppColors.accentBlue,
    ),
    CategoryItem(
      label: 'Ride',
      icon: Icons.two_wheeler,
      iconColor: AppColors.primaryNavy,
    ),
    CategoryItem(
      label: 'Hotel',
      icon: Icons.hotel_outlined,
      iconColor: Color(0xFF7C4DFF),
    ),
    CategoryItem(
      label: 'Rental',
      icon: Icons.directions_car_filled_outlined,
      iconColor: Color(0xFF00897B),
    ),
    CategoryItem(
      label: 'SOS',
      icon: Icons.sos_outlined,
      iconColor: Color(0xFFE53935),
    ),
  ];
}

// ---------------------------------------------------------------------------
// The section below powers the dedicated ride-hailing and food-delivery flow
// screens (pickup/drop, vehicle selection, fare estimate, live tracking,
// restaurant browsing, checkout, order tracking, etc). Kept separate with
// distinct type names to avoid clashing with the models above.
// ---------------------------------------------------------------------------

class VehicleOption {
  const VehicleOption({
    required this.name,
    required this.icon,
    required this.eta,
    required this.price,
    required this.description,
  });

  final String name;
  final IconData icon;
  final String eta;
  final double price;
  final String description;
}

const List<VehicleOption> dummyVehicleOptions = [
  VehicleOption(
    name: 'Bike',
    icon: Icons.two_wheeler,
    eta: '3 min away',
    price: 45,
    description: '1 seat • Fastest way around town',
  ),
  VehicleOption(
    name: 'Car',
    icon: Icons.directions_car_filled,
    eta: '5 min away',
    price: 120,
    description: '4 seats • Comfortable AC ride',
  ),
  VehicleOption(
    name: 'XL',
    icon: Icons.airport_shuttle,
    eta: '8 min away',
    price: 190,
    description: '6 seats • Extra space for groups',
  ),
];

class RideDriverInfo {
  const RideDriverInfo({
    required this.name,
    required this.rating,
    required this.vehicleModel,
    required this.plateNumber,
    required this.etaMinutes,
    required this.phone,
  });

  final String name;
  final double rating;
  final String vehicleModel;
  final String plateNumber;
  final int etaMinutes;
  final String phone;
}

const RideDriverInfo dummyRideDriver = RideDriverInfo(
  name: 'Rakib Hasan',
  rating: 4.8,
  vehicleModel: 'Honda CB Shine · Red',
  plateNumber: 'DHK METRO-LA 12-3456',
  etaMinutes: 4,
  phone: '+880 1712-345678',
);

class RideHistoryEntry {
  const RideHistoryEntry({
    required this.date,
    required this.pickup,
    required this.drop,
    required this.fare,
    required this.status,
  });

  final String date;
  final String pickup;
  final String drop;
  final double fare;
  final String status;
}

const List<RideHistoryEntry> dummyRideHistoryEntries = [
  RideHistoryEntry(
    date: 'Today, 9:24 AM',
    pickup: 'Bashundhara R/A',
    drop: 'Gulshan 2 Circle',
    fare: 180,
    status: 'Completed',
  ),
  RideHistoryEntry(
    date: 'Yesterday, 6:10 PM',
    pickup: 'Dhanmondi 27',
    drop: 'Uttara Sector 7',
    fare: 320,
    status: 'Completed',
  ),
  RideHistoryEntry(
    date: 'Yesterday, 11:02 AM',
    pickup: 'Banani',
    drop: 'Mirpur 10',
    fare: 150,
    status: 'Cancelled',
  ),
  RideHistoryEntry(
    date: 'Mon, 8:45 AM',
    pickup: 'Mohammadpur',
    drop: 'Motijheel',
    fare: 210,
    status: 'Completed',
  ),
  RideHistoryEntry(
    date: 'Sun, 7:30 PM',
    pickup: 'Khilgaon',
    drop: 'Airport Road',
    fare: 260,
    status: 'Completed',
  ),
];

class FoodMenuItem {
  const FoodMenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    this.icon = Icons.restaurant_menu,
    this.imageUrl,
  });

  final String name;
  final String description;
  final double price;
  final Color color;
  final IconData icon;
  final String? imageUrl;
}

class FoodMenuCategory {
  const FoodMenuCategory({required this.name, required this.items});

  final String name;
  final List<FoodMenuItem> items;
}

class RestaurantInfo {
  const RestaurantInfo({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.time,
    required this.fee,
    required this.color,
    required this.menu,
    this.imageUrl,
    this.freeDelivery = false,
  });

  final String name;
  final String cuisine;
  final double rating;
  final String time;
  final double fee;
  final Color color;
  final List<FoodMenuCategory> menu;
  final String? imageUrl;
  final bool freeDelivery;
}

const List<String> dummyCuisineChips = [
  'All',
  'Fast Food',
  'Bengali',
  'Chinese',
  'Pizza',
  'Desserts',
];

const List<RestaurantInfo> dummyRestaurants = [
  RestaurantInfo(
    name: 'The Pizza Artisan',
    cuisine: 'Italian • Pizza • Gourmet',
    rating: 4.8,
    time: '20-30 min',
    fee: 2.99,
    color: AppColors.accentOrangeSoft,
    imageUrl: AppImages.pizza,
    freeDelivery: false,
    menu: [
      FoodMenuCategory(
        name: 'Popular',
        items: [
          FoodMenuItem(
            name: 'Truffle Margherita',
            description: 'Fresh mozzarella, basil and truffle oil on sourdough',
            price: 420,
            color: AppColors.accentOrangeSoft,
            icon: Icons.local_pizza,
            imageUrl: AppImages.pizza,
          ),
          FoodMenuItem(
            name: 'Pepperoni Feast',
            description: 'Double pepperoni with mozzarella and oregano',
            price: 380,
            color: AppColors.accentBlueSoft,
            icon: Icons.local_pizza,
            imageUrl: AppImages.pizza,
          ),
        ],
      ),
    ],
  ),
  RestaurantInfo(
    name: 'Zen Sushi House',
    cuisine: 'Japanese • Sushi • Asian',
    rating: 4.9,
    time: '25-35 min',
    fee: 0,
    color: AppColors.illustrationSky,
    imageUrl: AppImages.sushi,
    freeDelivery: true,
    menu: [
      FoodMenuCategory(
        name: 'Rolls',
        items: [
          FoodMenuItem(
            name: 'Dragon Roll',
            description: 'Eel, avocado and cucumber with spicy mayo',
            price: 520,
            color: AppColors.illustrationSky,
            icon: Icons.set_meal,
            imageUrl: AppImages.sushi,
          ),
          FoodMenuItem(
            name: 'Salmon Nigiri Set',
            description: '6 pieces of fresh Atlantic salmon nigiri',
            price: 450,
            color: AppColors.accentBlueSoft,
            icon: Icons.set_meal,
            imageUrl: AppImages.sushi,
          ),
        ],
      ),
    ],
  ),
  RestaurantInfo(
    name: 'Urban Smash Burgers',
    cuisine: 'American • Burgers • Fast Food',
    rating: 4.7,
    time: '15-25 min',
    fee: 1.99,
    color: AppColors.accentOrangeSoft,
    imageUrl: AppImages.burger,
    freeDelivery: false,
    menu: [
      FoodMenuCategory(
        name: 'Burgers',
        items: [
          FoodMenuItem(
            name: 'Classic Smash Burger',
            description: 'Double patty, cheddar, pickles and secret sauce',
            price: 320,
            color: AppColors.accentOrangeSoft,
            icon: Icons.lunch_dining,
            imageUrl: AppImages.burger,
          ),
          FoodMenuItem(
            name: 'Loaded Fries',
            description: 'Crispy fries with cheese sauce and jalapeños',
            price: 180,
            color: AppColors.accentBlueSoft,
            icon: Icons.tapas,
            imageUrl: AppImages.burger,
          ),
        ],
      ),
    ],
  ),
  RestaurantInfo(
    name: 'Spice Villa',
    cuisine: 'Bengali • Curry • Rice',
    rating: 4.6,
    time: '28-38 min',
    fee: 2.50,
    color: AppColors.accentOrangeSoft,
    imageUrl: AppImages.biryani,
    menu: [
      FoodMenuCategory(
        name: 'Popular',
        items: [
          FoodMenuItem(
            name: 'Kacchi Biryani',
            description: 'Slow-cooked mutton biryani with saffron rice',
            price: 320,
            color: AppColors.accentOrangeSoft,
            icon: Icons.rice_bowl,
            imageUrl: AppImages.biryani,
          ),
          FoodMenuItem(
            name: 'Chicken Rezala',
            description: 'Creamy white chicken curry with cashew',
            price: 260,
            color: AppColors.accentBlueSoft,
            icon: Icons.soup_kitchen,
            imageUrl: AppImages.biryani,
          ),
        ],
      ),
    ],
  ),
  RestaurantInfo(
    name: 'Dragon Wok',
    cuisine: 'Chinese • Noodles • Stir-fry',
    rating: 4.5,
    time: '22-32 min',
    fee: 2.00,
    color: AppColors.illustrationSky,
    imageUrl: AppImages.noodles,
    menu: [
      FoodMenuCategory(
        name: 'Mains',
        items: [
          FoodMenuItem(
            name: 'Chicken Chowmein',
            description: 'Wok-tossed noodles with crisp vegetables',
            price: 220,
            color: AppColors.accentOrangeSoft,
            icon: Icons.ramen_dining,
            imageUrl: AppImages.noodles,
          ),
          FoodMenuItem(
            name: 'Sweet & Sour Chicken',
            description: 'Crispy chicken in tangy house sauce',
            price: 260,
            color: AppColors.accentBlueSoft,
            icon: Icons.set_meal,
            imageUrl: AppImages.noodles,
          ),
        ],
      ),
    ],
  ),
];

class FoodCartLine {
  FoodCartLine({required this.item, required this.restaurantName, this.quantity = 1});

  final FoodMenuItem item;
  final String restaurantName;
  int quantity;

  double get lineTotal => item.price * quantity;
}

/// Minimal in-memory cart used to pass data between the food delivery screens
/// without introducing a full state-management dependency.
class FoodCartStore {
  FoodCartStore._();

  static final List<FoodCartLine> _lines = [];

  static List<FoodCartLine> get lines => List.unmodifiable(_lines);

  static bool get isEmpty => _lines.isEmpty;

  static void add(FoodMenuItem item, String restaurantName, {int quantity = 1}) {
    final existingIndex = _lines.indexWhere(
      (line) => line.item.name == item.name && line.restaurantName == restaurantName,
    );
    if (existingIndex != -1) {
      _lines[existingIndex].quantity += quantity;
    } else {
      _lines.add(FoodCartLine(item: item, restaurantName: restaurantName, quantity: quantity));
    }
  }

  static void removeAt(int index) {
    if (index >= 0 && index < _lines.length) {
      _lines.removeAt(index);
    }
  }

  static void clear() => _lines.clear();

  static double get subtotal =>
      _lines.fold(0, (sum, line) => sum + line.lineTotal);
}

// ---------------------------------------------------------------------------
// Hotel booking module
// ---------------------------------------------------------------------------

class HotelInfo {
  const HotelInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerNight,
    required this.amenities,
    required this.description,
    required this.imageUrl,
    required this.color,
    this.reviews = 120,
    this.stars = 4,
  });

  final String id;
  final String name;
  final String location;
  final double rating;
  final double pricePerNight;
  final List<String> amenities;
  final String description;
  final String imageUrl;
  final Color color;
  final int reviews;
  final int stars;
}

const List<String> dummyHotelChips = [
  'All',
  'Dhaka',
  'Sylhet',
  'Cox\'s Bazar',
  'Chittagong',
];

const List<HotelInfo> dummyHotels = [
  HotelInfo(
    id: 'h1',
    name: 'HillView Grand Hotel',
    location: 'Gulshan, Dhaka',
    rating: 4.8,
    pricePerNight: 8500,
    amenities: ['Wi‑Fi', 'Pool', 'Breakfast', 'Parking'],
    description:
        'A modern city hotel with skyline views, a rooftop pool and '
        'spacious rooms ideal for business or leisure stays.',
    imageUrl: AppImages.hotelLobby,
    color: Color(0xFFE8E0FF),
    reviews: 412,
    stars: 5,
  ),
  HotelInfo(
    id: 'h2',
    name: 'Bayfront Resort',
    location: 'Cox\'s Bazar',
    rating: 4.7,
    pricePerNight: 12000,
    amenities: ['Beach', 'Spa', 'Restaurant', 'Wi‑Fi'],
    description:
        'Beachfront resort with private cabanas, spa treatments and '
        'fresh seafood dining on the shore.',
    imageUrl: AppImages.hotelResort,
    color: Color(0xFFE0F4FF),
    reviews: 288,
    stars: 5,
  ),
  HotelInfo(
    id: 'h3',
    name: 'Tea Garden Inn',
    location: 'Sylhet',
    rating: 4.5,
    pricePerNight: 6200,
    amenities: ['Garden', 'Wi‑Fi', 'Breakfast', 'Tour Desk'],
    description:
        'Boutique stay surrounded by tea estates — quiet rooms, '
        'garden walks and local cuisine.',
    imageUrl: AppImages.hotelBoutique,
    color: Color(0xFFE8F8EB),
    reviews: 156,
    stars: 4,
  ),
  HotelInfo(
    id: 'h4',
    name: 'Harbour Suites',
    location: 'Chittagong',
    rating: 4.6,
    pricePerNight: 7800,
    amenities: ['Wi‑Fi', 'Gym', 'Airport Shuttle', 'Parking'],
    description:
        'Business-friendly suites near the harbour with fast Wi‑Fi, '
        'meeting rooms and complimentary shuttle.',
    imageUrl: AppImages.hotelRoom,
    color: Color(0xFFFFE8D6),
    reviews: 203,
    stars: 4,
  ),
  HotelInfo(
    id: 'h5',
    name: 'Lakeside Retreat',
    location: 'Dhaka',
    rating: 4.4,
    pricePerNight: 5400,
    amenities: ['Lake View', 'Wi‑Fi', 'Cafe', 'Parking'],
    description:
        'Calm lakeside rooms with a café terrace — perfect for a '
        'short city escape without leaving Dhaka.',
    imageUrl: AppImages.hotelPool,
    color: Color(0xFFEAF1FB),
    reviews: 97,
    stars: 3,
  ),
];

class HotelBooking {
  HotelBooking({
    required this.hotel,
    this.checkInLabel = 'Aug 2, 2026',
    this.checkOutLabel = 'Aug 4, 2026',
    this.nights = 2,
    this.guests = 2,
    this.rooms = 1,
    this.guestName = '',
    this.guestPhone = '',
  });

  final HotelInfo hotel;
  String checkInLabel;
  String checkOutLabel;
  int nights;
  int guests;
  int rooms;
  String guestName;
  String guestPhone;

  double get roomTotal => hotel.pricePerNight * nights * rooms;
  double get serviceFee => roomTotal * 0.05;
  double get total => roomTotal + serviceFee;
}

class HotelBookingEntry {
  const HotelBookingEntry({
    required this.bookingId,
    required this.hotelName,
    required this.location,
    required this.datesLabel,
    required this.status,
    required this.amount,
  });

  final String bookingId;
  final String hotelName;
  final String location;
  final String datesLabel;
  final String status;
  final double amount;
}

const List<HotelBookingEntry> dummyHotelBookings = [
  HotelBookingEntry(
    bookingId: 'HT-10421',
    hotelName: 'HillView Grand Hotel',
    location: 'Gulshan, Dhaka',
    datesLabel: 'Jul 12 – Jul 14',
    status: 'Completed',
    amount: 17850,
  ),
  HotelBookingEntry(
    bookingId: 'HT-10502',
    hotelName: 'Bayfront Resort',
    location: 'Cox\'s Bazar',
    datesLabel: 'Aug 20 – Aug 23',
    status: 'Upcoming',
    amount: 37800,
  ),
];

// ---------------------------------------------------------------------------
// Vehicle rental module
// ---------------------------------------------------------------------------

class RentalVehicle {
  const RentalVehicle({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuel,
    required this.rating,
    required this.description,
    required this.imageUrl,
    required this.color,
    required this.icon,
    this.features = const [],
  });

  final String id;
  final String name;
  final String category;
  final double pricePerDay;
  final int seats;
  final String transmission;
  final String fuel;
  final double rating;
  final String description;
  final String imageUrl;
  final Color color;
  final IconData icon;
  final List<String> features;
}

const List<String> dummyRentalChips = [
  'All',
  'Car',
  'SUV',
  'Bike',
  'Scooter',
  'Van',
];

const List<RentalVehicle> dummyRentals = [
  RentalVehicle(
    id: 'r1',
    name: 'Toyota Axio',
    category: 'Car',
    pricePerDay: 3500,
    seats: 5,
    transmission: 'Auto',
    fuel: 'Petrol',
    rating: 4.8,
    description:
        'Reliable sedan for city trips — AC, Bluetooth audio and '
        'unlimited km within Dhaka.',
    imageUrl: AppImages.rentalCar,
    color: Color(0xFFEAF1FB),
    icon: Icons.directions_car_filled,
    features: ['AC', 'Bluetooth', 'Unlimited km'],
  ),
  RentalVehicle(
    id: 'r2',
    name: 'Mitsubishi Pajero',
    category: 'SUV',
    pricePerDay: 7500,
    seats: 7,
    transmission: 'Auto',
    fuel: 'Diesel',
    rating: 4.7,
    description:
        'Rugged SUV for family getaways and hill-track weekends '
        'with ample luggage space.',
    imageUrl: AppImages.rentalSuv,
    color: Color(0xFFE8F8EB),
    icon: Icons.airport_shuttle,
    features: ['4WD', 'AC', 'Roof rack'],
  ),
  RentalVehicle(
    id: 'r3',
    name: 'Yamaha FZ-S',
    category: 'Bike',
    pricePerDay: 900,
    seats: 2,
    transmission: 'Manual',
    fuel: 'Petrol',
    rating: 4.6,
    description:
        'Agile bike for quick errands and traffic — helmets '
        'included with every rental.',
    imageUrl: AppImages.rentalBike,
    color: Color(0xFFFFE8D6),
    icon: Icons.two_wheeler,
    features: ['Helmet', 'Phone mount'],
  ),
  RentalVehicle(
    id: 'r4',
    name: 'Honda Dio',
    category: 'Scooter',
    pricePerDay: 700,
    seats: 2,
    transmission: 'Auto',
    fuel: 'Petrol',
    rating: 4.5,
    description:
        'Easy scooter for short hops — automatic transmission and '
        'under-seat storage.',
    imageUrl: AppImages.rentalScooter,
    color: Color(0xFFE0F4FF),
    icon: Icons.electric_scooter,
    features: ['Helmet', 'Storage'],
  ),
  RentalVehicle(
    id: 'r5',
    name: 'Toyota HiAce',
    category: 'Van',
    pricePerDay: 9500,
    seats: 12,
    transmission: 'Manual',
    fuel: 'Diesel',
    rating: 4.4,
    description:
        'Group van for office tours and family trips — AC and '
        'driver option available.',
    imageUrl: AppImages.rentalVan,
    color: Color(0xFFE8E0FF),
    icon: Icons.airport_shuttle_outlined,
    features: ['AC', 'Driver optional', 'Luggage bay'],
  ),
];

class RentalBooking {
  RentalBooking({
    required this.vehicle,
    this.pickupLocation = 'Gulshan 1, Dhaka',
    this.dropoffLocation = 'Same as pickup',
    this.startLabel = 'Aug 1, 10:00 AM',
    this.endLabel = 'Aug 3, 10:00 AM',
    this.days = 2,
    this.withDriver = false,
    this.renterName = '',
    this.renterPhone = '',
  });

  final RentalVehicle vehicle;
  String pickupLocation;
  String dropoffLocation;
  String startLabel;
  String endLabel;
  int days;
  bool withDriver;
  String renterName;
  String renterPhone;

  double get vehicleTotal => vehicle.pricePerDay * days;
  double get driverFee => withDriver ? 1500.0 * days : 0;
  double get insuranceFee => 300.0 * days;
  double get total => vehicleTotal + driverFee + insuranceFee;
}

class RentalHistoryEntry {
  const RentalHistoryEntry({
    required this.rentalId,
    required this.vehicleName,
    required this.category,
    required this.datesLabel,
    required this.status,
    required this.amount,
  });

  final String rentalId;
  final String vehicleName;
  final String category;
  final String datesLabel;
  final String status;
  final double amount;
}

const List<RentalHistoryEntry> dummyRentalHistory = [
  RentalHistoryEntry(
    rentalId: 'RN-22011',
    vehicleName: 'Toyota Axio',
    category: 'Car',
    datesLabel: 'Jul 8 – Jul 9',
    status: 'Completed',
    amount: 7300,
  ),
  RentalHistoryEntry(
    rentalId: 'RN-22140',
    vehicleName: 'Yamaha FZ-S',
    category: 'Bike',
    datesLabel: 'Jul 20 – Jul 21',
    status: 'Completed',
    amount: 2100,
  ),
  RentalHistoryEntry(
    rentalId: 'RN-22205',
    vehicleName: 'Mitsubishi Pajero',
    category: 'SUV',
    datesLabel: 'Aug 15 – Aug 18',
    status: 'Upcoming',
    amount: 27000,
  ),
];

// ---------------------------------------------------------------------------
// SOS / emergency contacts
// ---------------------------------------------------------------------------

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  final String id;
  final String name;
  final String phone;
  final String relation;
}

class SosAlertEntry {
  const SosAlertEntry({
    required this.id,
    required this.type,
    required this.timeLabel,
    required this.status,
  });

  final String id;
  final String type;
  final String timeLabel;
  final String status;
}

const List<EmergencyContact> dummyEmergencyContacts = [
  EmergencyContact(
    id: 'ec1',
    name: 'Sam Lee',
    phone: '+880 1800-000000',
    relation: 'Spouse',
  ),
  EmergencyContact(
    id: 'ec2',
    name: 'Jordan Blake',
    phone: '+880 1700-111222',
    relation: 'Sibling',
  ),
];

const List<SosAlertEntry> dummySosHistory = [
  SosAlertEntry(
    id: 'sos1',
    type: 'Ride SOS',
    timeLabel: 'Jul 18, 9:42 PM',
    status: 'Resolved',
  ),
];
