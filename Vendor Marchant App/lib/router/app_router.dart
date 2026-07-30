import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/orders/order_details_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/products/categories_screen.dart';
import '../screens/products/product_form_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/store_info_screen.dart';
import '../screens/promotions/branding_screen.dart';
import '../screens/revenue/revenue_screens.dart';
import '../screens/reviews/reviews_screens.dart';
import '../screens/store/store_hub_screen.dart';
import '../widgets/main_shell.dart';

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.status;
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login';
      final onboarding = loc == '/onboarding';

      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated) {
        return loggingIn ? null : '/login';
      }

      final user = auth.user;
      if (user != null && !user.onboardingComplete) {
        return onboarding ? null : '/onboarding';
      }

      if (loggingIn || onboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (_, __) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    name: 'orderDetails',
                    builder: (_, state) => OrderDetailsScreen(
                      orderId: state.pathParameters['orderId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                builder: (_, __) => const ProductsScreen(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: 'categories',
                    builder: (_, __) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'new',
                    name: 'productNew',
                    builder: (_, __) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ':productId',
                    name: 'productEdit',
                    builder: (_, state) => ProductFormScreen(
                      productId: state.pathParameters['productId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/store',
                name: 'store',
                builder: (_, __) => const StoreHubScreen(),
                routes: [
                  GoRoute(
                    path: 'info',
                    name: 'storeInfo',
                    builder: (_, __) => const StoreInfoScreen(),
                  ),
                  GoRoute(
                    path: 'branding',
                    name: 'branding',
                    builder: (_, __) => const BrandingScreen(),
                  ),
                  GoRoute(
                    path: 'revenue',
                    name: 'revenue',
                    builder: (_, __) => const RevenueScreen(),
                  ),
                  GoRoute(
                    path: 'payouts',
                    name: 'payouts',
                    builder: (_, __) => const PayoutHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'reviews',
                    name: 'reviews',
                    builder: (_, __) => const ReviewsScreen(),
                    routes: [
                      GoRoute(
                        path: ':reviewId/reply',
                        name: 'replyReview',
                        builder: (_, state) => ReplyReviewScreen(
                          reviewId: state.pathParameters['reviewId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (_, __) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
