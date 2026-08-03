import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/document_provider.dart';
import 'providers/driver_provider.dart';
import 'router/app_router.dart';
import 'services/api/api_auth_repository.dart';
import 'services/api/api_client.dart';
import 'services/api/api_document_repository.dart';
import 'services/api/api_trip_repository.dart';
import 'theme/app_theme.dart';
import 'utils/app_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

/// Wires repositories/providers and runs the app. Shared by both the
/// Sentry-enabled and Sentry-skipped startup paths so behavior is identical
/// either way.
Future<void> _bootstrap() async {
  final apiClient = ApiClient();
  await apiClient.loadToken();
  final authRepo = ApiAuthRepository(apiClient);
  final tripRepo = ApiTripRepository(apiClient);
  final docRepo = ApiDocumentRepository(apiClient);

  final authProvider = AuthProvider(authRepo);
  final driverProvider = DriverProvider(tripRepo);
  final documentProvider = DocumentProvider(docRepo);

  final router = AppRouter(authProvider).router;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: driverProvider),
        ChangeNotifierProvider.value(value: documentProvider),
      ],
      child: HillGoRiderApp(router: router),
    ),
  );
}

class HillGoRiderApp extends StatelessWidget {
  const HillGoRiderApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rider Driver App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
