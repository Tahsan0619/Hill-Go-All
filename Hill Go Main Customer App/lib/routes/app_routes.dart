import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../services/auth_service.dart';
import '../screens/cart_hub_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/email_login_screen.dart';
import '../screens/food/food_cart_screen.dart';
import '../screens/food/food_checkout_screen.dart';
import '../screens/food/food_details_screen.dart';
import '../screens/food/order_tracking_screen.dart';
import '../screens/food/restaurant_details_screen.dart';
import '../screens/food/restaurant_list_screen.dart';
import '../screens/hotel/hotel_booking_screen.dart';
import '../screens/hotel/hotel_bookings_screen.dart';
import '../screens/hotel/hotel_confirmation_screen.dart';
import '../screens/hotel/hotel_details_screen.dart';
import '../screens/hotel/hotel_list_screen.dart';
import '../screens/login_screen.dart';
import '../screens/loyalty/rewards_center_screen.dart';
import '../screens/main_shell_screen.dart';
import '../screens/marketplace/marketplace_cart_screen.dart';
import '../screens/marketplace/product_categories_screen.dart';
import '../screens/marketplace/product_details_screen.dart';
import '../screens/marketplace/product_listing_screen.dart';
import '../screens/nearby_services_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/parcel/parcel_history_screen.dart';
import '../screens/parcel/parcel_summary_screen.dart';
import '../screens/parcel/parcel_tracking_screen.dart';
import '../screens/parcel/parcel_type_screen.dart';
import '../screens/parcel/pickup_details_screen.dart';
import '../screens/parcel/price_estimate_screen.dart';
import '../screens/parcel/receiver_details_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/language_selection_screen.dart';
import '../screens/profile/saved_addresses_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/recommended_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/rental/rental_booking_screen.dart';
import '../screens/rental/rental_confirmation_screen.dart';
import '../screens/rental/rental_details_screen.dart';
import '../screens/rental/rental_history_screen.dart';
import '../screens/rental/rental_list_screen.dart';
import '../screens/ride/driver_assigned_screen.dart';
import '../screens/ride/driver_searching_screen.dart';
import '../screens/ride/fare_estimate_screen.dart';
import '../screens/ride/google_map_screen.dart';
import '../screens/ride/live_ride_tracking_screen.dart';
import '../screens/ride/pickup_drop_screen.dart';
import '../screens/ride/ride_details_screen.dart';
import '../screens/ride/ride_history_screen.dart';
import '../screens/ride/ride_rating_screen.dart';
import '../screens/ride/vehicle_selection_screen.dart';
import '../screens/search_screen.dart';
import '../screens/service_categories_screen.dart';
import '../screens/sos/sos_contacts_screen.dart';
import '../screens/sos/sos_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/wallet/payment_method_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../theme/app_theme.dart';

class AppRoutes {
  AppRoutes._();

  static Widget _notFound(String title) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title not found.\nOpen this screen from its list or flow.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  static Map<String, WidgetBuilder> get routes => {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        EmailLoginScreen.routeName: (_) => const EmailLoginScreen(),
        OtpVerificationScreen.routeName: (_) => const OtpVerificationScreen(),
        RegistrationScreen.routeName: (_) => const RegistrationScreen(),
        MainShellScreen.routeName: (_) => const MainShellScreen(),
        CartHubScreen.routeName: (_) => const CartHubScreen(),
        ChatbotScreen.routeName: (_) => const Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(child: ChatbotScreen()),
            ),
        SearchScreen.routeName: (_) => const SearchScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
        NearbyServicesScreen.routeName: (_) => const NearbyServicesScreen(),
        RecommendedScreen.routeName: (_) => Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('Recommended'),
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.navy,
                elevation: 0,
              ),
              body: const RecommendedScreen(),
            ),
        '/categories': (_) => Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('Categories'),
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.navy,
                elevation: 0,
              ),
              body: const ServiceCategoriesScreen(),
            ),

        // Ride
        PickupDropScreen.routeName: (_) => const PickupDropScreen(),
        VehicleSelectionScreen.routeName: (_) => const VehicleSelectionScreen(),
        FareEstimateScreen.routeName: (_) => const FareEstimateScreen(),
        GoogleMapScreen.routeName: (_) => const GoogleMapScreen(),
        DriverSearchingScreen.routeName: (_) => const DriverSearchingScreen(),
        DriverAssignedScreen.routeName: (_) => const DriverAssignedScreen(),
        LiveRideTrackingScreen.routeName: (_) => const LiveRideTrackingScreen(),
        RideDetailsScreen.routeName: (_) => const RideDetailsScreen(),
        RideHistoryScreen.routeName: (_) => const RideHistoryScreen(),
        RideRatingScreen.routeName: (_) => const RideRatingScreen(),

        // Food
        RestaurantListScreen.routeName: (_) => const RestaurantListScreen(),
        RestaurantDetailsScreen.routeName: (_) =>
            const RestaurantDetailsScreen(),
        FoodDetailsScreen.routeName: (_) => const FoodDetailsScreen(),
        FoodCartScreen.routeName: (_) => const FoodCartScreen(),
        FoodCheckoutScreen.routeName: (_) => const FoodCheckoutScreen(),
        OrderTrackingScreen.routeName: (_) => const OrderTrackingScreen(),

        // Marketplace
        ProductCategoriesScreen.routeName: (_) =>
            const ProductCategoriesScreen(),
        ProductListingScreen.routeName: (_) => const ProductListingScreen(),
        ProductDetailsScreen.routeName: (_) => _notFound('Product'),
        MarketplaceCartScreen.routeName: (_) => const MarketplaceCartScreen(),

        // Parcel — flow screens require a booking argument via onGenerateRoute
        ParcelTypeScreen.routeName: (_) => const ParcelTypeScreen(),
        PickupDetailsScreen.routeName: (_) => _notFound('Pickup details'),
        ReceiverDetailsScreen.routeName: (_) => _notFound('Receiver details'),
        PriceEstimateScreen.routeName: (_) => _notFound('Price estimate'),
        ParcelSummaryScreen.routeName: (_) => _notFound('Parcel summary'),
        ParcelTrackingScreen.routeName: (_) => const ParcelTrackingScreen(),
        ParcelHistoryScreen.routeName: (_) => const ParcelHistoryScreen(),

        // Hotel
        HotelListScreen.routeName: (_) => const HotelListScreen(),
        HotelDetailsScreen.routeName: (_) => const HotelDetailsScreen(),
        HotelBookingScreen.routeName: (_) => _notFound('Hotel booking'),
        HotelConfirmationScreen.routeName: (_) =>
            _notFound('Hotel confirmation'),
        HotelBookingsScreen.routeName: (_) => const HotelBookingsScreen(),

        // Rental
        RentalListScreen.routeName: (_) => const RentalListScreen(),
        RentalDetailsScreen.routeName: (_) => const RentalDetailsScreen(),
        RentalBookingScreen.routeName: (_) => _notFound('Rental booking'),
        RentalConfirmationScreen.routeName: (_) =>
            _notFound('Rental confirmation'),
        RentalHistoryScreen.routeName: (_) => const RentalHistoryScreen(),

        // SOS
        SosScreen.routeName: (_) => const SosScreen(),
        SosContactsScreen.routeName: (_) => const SosContactsScreen(),

        // Profile / wallet / loyalty
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        SavedAddressesScreen.routeName: (_) => const SavedAddressesScreen(),
        LanguageSelectionScreen.routeName: (_) =>
            const LanguageSelectionScreen(),
        WalletScreen.routeName: (_) => const WalletScreen(),
        PaymentMethodScreen.routeName: (_) => const PaymentMethodScreen(),
        RewardsCenterScreen.routeName: (_) => const RewardsCenterScreen(),
      };

  /// Handles routes that need constructor arguments.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RestaurantDetailsScreen.routeName:
        final restaurant = settings.arguments is RestaurantInfo
            ? settings.arguments as RestaurantInfo
            : null;
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailsScreen(restaurant: restaurant),
          settings: settings,
        );
      case FoodDetailsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const FoodDetailsScreen(),
          settings: settings,
        );
      case ProductDetailsScreen.routeName:
        if (settings.arguments is Product) {
          return MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(product: settings.arguments as Product),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Product'),
          settings: settings,
        );
      case HotelDetailsScreen.routeName:
        final hotel =
            settings.arguments is HotelInfo ? settings.arguments as HotelInfo : null;
        return MaterialPageRoute(
          builder: (_) => HotelDetailsScreen(hotel: hotel),
          settings: settings,
        );
      case HotelBookingScreen.routeName:
        if (settings.arguments is HotelBooking) {
          return MaterialPageRoute(
            builder: (_) => HotelBookingScreen(
                booking: settings.arguments as HotelBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Hotel booking'),
          settings: settings,
        );
      case HotelConfirmationScreen.routeName:
        if (settings.arguments is HotelBooking) {
          return MaterialPageRoute(
            builder: (_) => HotelConfirmationScreen(
                booking: settings.arguments as HotelBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Hotel confirmation'),
          settings: settings,
        );
      case RentalDetailsScreen.routeName:
        final vehicle = settings.arguments is RentalVehicle
            ? settings.arguments as RentalVehicle
            : null;
        return MaterialPageRoute(
          builder: (_) => RentalDetailsScreen(vehicle: vehicle),
          settings: settings,
        );
      case RentalBookingScreen.routeName:
        if (settings.arguments is RentalBooking) {
          return MaterialPageRoute(
            builder: (_) => RentalBookingScreen(
                booking: settings.arguments as RentalBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Rental booking'),
          settings: settings,
        );
      case RentalConfirmationScreen.routeName:
        if (settings.arguments is RentalBooking) {
          return MaterialPageRoute(
            builder: (_) => RentalConfirmationScreen(
                booking: settings.arguments as RentalBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Rental confirmation'),
          settings: settings,
        );
      case PickupDetailsScreen.routeName:
        if (settings.arguments is ParcelBooking) {
          return MaterialPageRoute(
            builder: (_) => PickupDetailsScreen(
                booking: settings.arguments as ParcelBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Pickup details'),
          settings: settings,
        );
      case ReceiverDetailsScreen.routeName:
        if (settings.arguments is ParcelBooking) {
          return MaterialPageRoute(
            builder: (_) => ReceiverDetailsScreen(
                booking: settings.arguments as ParcelBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Receiver details'),
          settings: settings,
        );
      case PriceEstimateScreen.routeName:
        if (settings.arguments is ParcelBooking) {
          return MaterialPageRoute(
            builder: (_) => PriceEstimateScreen(
                booking: settings.arguments as ParcelBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Price estimate'),
          settings: settings,
        );
      case ParcelSummaryScreen.routeName:
        if (settings.arguments is ParcelBooking) {
          return MaterialPageRoute(
            builder: (_) => ParcelSummaryScreen(
                booking: settings.arguments as ParcelBooking),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _notFound('Parcel summary'),
          settings: settings,
        );
      case SosScreen.routeName:
        final ctxLabel =
            settings.arguments is String ? settings.arguments as String : null;
        return MaterialPageRoute(
          builder: (_) => SosScreen(initialContext: ctxLabel),
          settings: settings,
        );
      case OtpVerificationScreen.routeName:
        final phone = settings.arguments is String
            ? settings.arguments as String
            : AuthService.pendingPhone ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(phoneNumber: phone),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
