import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/store_provider.dart';
import 'router/app_router.dart';
import 'services/api/api_auth_repository.dart';
import 'services/api/api_client.dart';
import 'services/api/api_order_repository.dart';
import 'services/api/api_product_repository.dart';
import 'services/api/api_store_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final api = ApiClient();
  await api.loadToken();
  final authRepo = ApiAuthRepository(api);
  final orderRepo = ApiOrderRepository(api);
  final productRepo = ApiProductRepository(api);
  final storeRepo = ApiStoreRepository(api);

  final authProvider = AuthProvider(authRepo);
  await authProvider.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => OrdersProvider(orderRepo)),
        ChangeNotifierProvider(create: (_) => ProductsProvider(productRepo)),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(storeRepo, prefs),
        ),
      ],
      child: HillGoVendorApp(authProvider: authProvider),
    ),
  );
}

class HillGoVendorApp extends StatefulWidget {
  const HillGoVendorApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  State<HillGoVendorApp> createState() => _HillGoVendorAppState();
}

class _HillGoVendorAppState extends State<HillGoVendorApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(widget.authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vendor Marchant App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
