import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_step1_screen.dart';
import '../screens/auth/register_step2_screen.dart';
import '../screens/auth/register_step3_screen.dart';
import '../screens/auth/register_step4_screen.dart';
import '../screens/auth/login_otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/biometrics_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/earnings/payout_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/vehicle_info_screen.dart';
import '../screens/profile/documents_screen.dart';
import '../screens/profile/notification_prefs_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/delivery/parcel_details_screen.dart';
import '../screens/delivery/otp_confirmation_screen.dart';
import '../screens/delivery/route_navigation_screen.dart';
import '../screens/delivery/delivery_success_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/support/help_screen.dart';
import '../screens/earnings/incentives_screen.dart';
import '../screens/earnings/withdraw_sheet.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  AppRouter(this.auth);

  final AuthProvider auth;
  final _rootKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/dashboard',
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.status;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' ||
          loc.startsWith('/register') ||
          loc.startsWith('/forgot-password') ||
          loc == '/login-otp' ||
          loc == '/biometrics';

      if (status == AuthStatus.unknown) return null;
      if (status == AuthStatus.unauthenticated && !isAuthRoute) return '/login';
      if (status == AuthStatus.authenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/login-otp', builder: (_, __) => const LoginOtpScreen()),
      GoRoute(path: '/biometrics', builder: (_, __) => const BiometricsScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterStep1Screen()),
      GoRoute(path: '/register/documents', builder: (_, __) => const RegisterStep2Screen()),
      GoRoute(path: '/register/verification', builder: (_, __) => const RegisterStep3Screen()),
      GoRoute(path: '/register/review', builder: (_, __) => const RegisterStep4Screen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/earnings', builder: (_, __) => const EarningsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/parcel/:id',
        builder: (_, state) => ParcelDetailsScreen(parcelId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/parcel/:id/pickup-otp',
        builder: (_, state) => OtpConfirmationScreen(
          parcelId: state.pathParameters['id']!,
          mode: OtpMode.pickup,
        ),
      ),
      GoRoute(
        path: '/parcel/:id/navigate',
        builder: (_, state) => RouteNavigationScreen(parcelId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/parcel/:id/delivery-otp',
        builder: (_, state) => OtpConfirmationScreen(
          parcelId: state.pathParameters['id']!,
          mode: OtpMode.delivery,
        ),
      ),
      GoRoute(
        path: '/parcel/:id/success',
        builder: (_, state) => DeliverySuccessScreen(parcelId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/payout', builder: (_, __) => const PayoutScreen()),
      GoRoute(path: '/withdraw', builder: (_, __) => const WithdrawScreen()),
      GoRoute(path: '/incentives', builder: (_, __) => const IncentivesScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/profile/vehicle', builder: (_, __) => const VehicleInfoScreen()),
      GoRoute(path: '/profile/documents', builder: (_, __) => const DocumentsScreen()),
      GoRoute(path: '/profile/notifications', builder: (_, __) => const NotificationPrefsScreen()),
      GoRoute(path: '/profile/language', builder: (_, __) => const LanguageScreen()),
    ],
  );
}
