import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/document_provider.dart';
import 'providers/driver_provider.dart';
import 'router/app_router.dart';
import 'services/mock/mock_auth_repository.dart';
import 'services/mock/mock_document_repository.dart';
import 'services/mock/mock_trip_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final authRepo = MockAuthRepository(prefs);
  final tripRepo = MockTripRepository();
  final docRepo = MockDocumentRepository();

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
