import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/parcel_provider.dart';
import 'providers/earnings_provider.dart';
import 'providers/profile_provider.dart';
import 'router/app_router.dart';
import 'services/mock/mock_auth_repository.dart';
import 'services/mock/mock_parcel_repository.dart';
import 'services/mock/mock_earnings_repository.dart';
import 'services/mock/mock_profile_repository.dart';
import 'services/mock/mock_notification_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final authRepo = MockAuthRepository(prefs);
  final parcelRepo = MockParcelRepository();
  final earningsRepo = MockEarningsRepository();
  final profileRepo = MockProfileRepository();
  final notifRepo = MockNotificationRepository();

  final authProvider = AuthProvider(authRepo);
  await authProvider.bootstrap();
  final appRouter = AppRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ParcelProvider(parcelRepo, earningsRepo)),
        ChangeNotifierProvider(create: (_) => EarningsProvider(earningsRepo)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(profileRepo, notifRepo)),
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
