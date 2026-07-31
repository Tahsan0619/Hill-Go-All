import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/parcel_provider.dart';
import 'providers/earnings_provider.dart';
import 'providers/profile_provider.dart';
import 'router/app_router.dart';
import 'services/api/api_client.dart';
import 'services/api/api_auth_repository.dart';
import 'services/api/api_parcel_repository.dart';
import 'services/api/api_earnings_repository.dart';
import 'services/api/api_profile_repository.dart';
import 'services/api/api_notification_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final api = ApiClient(prefs);
  final authRepo = ApiAuthRepository(api, prefs);
  final parcelRepo = ApiParcelRepository(api);
  final earningsRepo = ApiEarningsRepository(api);
  final profileRepo = ApiProfileRepository(api);
  final notifRepo = ApiNotificationRepository(api);

  final authProvider = AuthProvider(authRepo, profileRepo);
  api.onUnauthorized = authProvider.handleSessionExpired;
  await authProvider.bootstrap();
  final appRouter = AppRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => ParcelProvider(parcelRepo, earningsRepo, profileRepo),
        ),
        ChangeNotifierProvider(create: (_) => EarningsProvider(earningsRepo)),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileRepo, notifRepo, earningsRepo),
        ),
      ],
      child: HillGoApp(router: appRouter),
    ),
  );
}

class HillGoApp extends StatelessWidget {
  const HillGoApp({super.key, required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Courier Agent App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router.router,
    );
  }
}
