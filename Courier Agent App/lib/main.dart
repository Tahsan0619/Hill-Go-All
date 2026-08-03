import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
import 'services/locale_controller.dart';
import 'theme/app_theme.dart';
import 'utils/app_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash reporting is opt-in: without a DSN the app runs exactly as before.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn.isEmpty) {
    AppLog.i('Sentry skipped — SENTRY_DSN not set', tag: 'Sentry');
    await _bootstrap();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
    },
    appRunner: _bootstrap,
  );
}

Future<void> _bootstrap() async {
  final prefs = await SharedPreferences.getInstance();

  final api = ApiClient(prefs);
  await api.loadToken();
  final authRepo = ApiAuthRepository(api, prefs);
  final parcelRepo = ApiParcelRepository(api);
  final earningsRepo = ApiEarningsRepository(api);
  final profileRepo = ApiProfileRepository(api);
  final notifRepo = ApiNotificationRepository(api);

  final authProvider = AuthProvider(authRepo, profileRepo);
  api.onUnauthorized = authProvider.handleSessionExpired;
  await authProvider.bootstrap();
  final appRouter = AppRouter(authProvider);

  // Seed the app locale from the courier's saved language preference so a
  // restart keeps their chosen language (`en`/`bn`) without a network call.
  final localeController = LocaleController()
    ..setFromLanguageCode(authProvider.user?.language);

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
        ChangeNotifierProvider.value(value: localeController),
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
    final localeController = context.watch<LocaleController>();
    return MaterialApp.router(
      title: 'Courier Agent App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeController.locale,
      supportedLocales: LocaleController.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router.router,
    );
  }
}
