import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../screens/account/account_screen.dart';
import '../screens/account/account_vehicle_screen.dart';
import '../screens/account/edit_profile_screen.dart';
import '../screens/account/settings_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/earnings/payout_summary_screen.dart';
import '../screens/home/home_dashboard_screen.dart';
import '../screens/onboarding/personal_info_screen.dart';
import '../screens/onboarding/registration_step_screen.dart';
import '../screens/onboarding/upload_documents_screen.dart';
import '../screens/onboarding/vehicle_info_screen.dart';
import '../screens/onboarding/verification_status_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/trip/incoming_offer_screen.dart';
import '../screens/trip/trip_completed_screen.dart';
import '../screens/trip/trip_details_screen.dart';
import '../screens/trip/trip_navigation_screen.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AppRouter {
  AppRouter(this.auth);

  final AuthProvider auth;
  final _rootKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final onAuthFlow = loc == '/login' ||
          loc == '/register' ||
          loc == '/otp' ||
          loc == '/forgot-password';
      final onOnboarding = loc.startsWith('/onboarding');

      // Still restoring session — stay on splash only.
      if (auth.status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      // No session — leave splash and send everything else to login
      // (except active auth screens).
      if (auth.status == AuthStatus.unauthenticated) {
        if (isSplash) return '/login';
        if (onAuthFlow) return null;
        return '/login';
      }

      // Authenticated
      final needsOnboarding =
          auth.user != null && !auth.user!.onboardingComplete;

      if (needsOnboarding) {
        if (isSplash) return '/onboarding/registration';
        if (onOnboarding || onAuthFlow) return null;
        return '/onboarding/registration';
      }

      // Fully onboarded — never linger on splash/auth.
      if (isSplash || onAuthFlow) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpScreen(target: state.extra as String?),
      ),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/onboarding/registration',
        builder: (context, state) => const RegistrationStepScreen(),
      ),
      GoRoute(
        path: '/onboarding/personal',
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/onboarding/vehicle',
        builder: (context, state) => const VehicleInfoScreen(),
      ),
      GoRoute(
        path: '/onboarding/documents',
        builder: (context, state) => const UploadDocumentsScreen(),
      ),
      GoRoute(
        path: '/onboarding/status',
        builder: (context, state) => const VerificationStatusScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (context, state) => const HomeDashboardScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/earnings', builder: (context, state) => const EarningsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/activity', builder: (context, state) => const ActivityScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/account', builder: (context, state) => const AccountScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/earnings/payouts', builder: (context, state) => const PayoutSummaryScreen()),
      GoRoute(path: '/account/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/account/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/account/vehicle', builder: (context, state) => const AccountVehicleScreen()),
      GoRoute(path: '/trip/offer', builder: (context, state) => const IncomingOfferScreen()),
      GoRoute(path: '/trip/navigation', builder: (context, state) => const TripNavigationScreen()),
      GoRoute(
        path: '/trip/completed',
        builder: (context, state) => TripCompletedScreen(trip: state.extra as Trip?),
      ),
      GoRoute(
        path: '/trip/details/:id',
        builder: (context, state) => TripDetailsScreen(tripId: state.pathParameters['id']!),
      ),
    ],
  );
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.bootstrap();
      if (!mounted) return;

      // Explicit navigation as a fallback if redirect doesn't fire.
      if (auth.status == AuthStatus.unauthenticated) {
        context.go('/login');
      } else if (auth.user != null && !auth.user!.onboardingComplete) {
        context.go('/onboarding/registration');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.local_shipping_rounded, size: 36, color: AppColors.primaryDeep),
            ),
            const SizedBox(height: 20),
            Text(
              'Rider Driver App',
              style: AppTextStyles.headline.copyWith(color: Colors.white, fontSize: 28),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
