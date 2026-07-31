import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/food_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/map_placeholder.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  static const String routeName = '/food/tracking';

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Order of the customer-facing statuses from the backend.
  static const _statusSteps = [
    ('placed', 'Order Placed'),
    ('preparing', 'Preparing'),
    ('on_the_way', 'On the way'),
    ('delivered', 'Delivered'),
  ];

  FoodOrder? _order;
  Timer? _pollTimer;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is FoodOrder) {
      _order = args;
      if (args.status != 'delivered' && args.status != 'cancelled') {
        _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
      }
    }
  }

  Future<void> _poll() async {
    final order = _order;
    if (order == null) return;
    try {
      final fresh = await FoodApi.order(order.id);
      if (!mounted) return;
      setState(() => _order = fresh);
      if (fresh.status == 'delivered' || fresh.status == 'cancelled') {
        _pollTimer?.cancel();
      }
    } on ApiException {
      // Ignore transient polling failures; retried on the next tick.
    }
  }

  int get _currentStep {
    final status = _order?.status;
    final index = _statusSteps.indexWhere((step) => step.$1 == status);
    return index == -1 ? 0 : index;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final order = _order;

    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text('Track your order', style: textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.textPrimary)),
        ),
        body: Center(child: Text('Order not found.', style: textTheme.bodyLarge)),
      );
    }

    final isCancelled = order.status == 'cancelled';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Track your order', style: textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MapPlaceholder(height: 220, showRoute: true),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCancelled ? 'Order cancelled' : _statusSteps[_currentStep].$2,
                          style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.code} • ${order.restaurant}',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                        if (!isCancelled) ...[
                          const SizedBox(height: 20),
                          for (var i = 0; i < _statusSteps.length; i++)
                            _TimelineStep(
                              label: _statusSteps[i].$2,
                              isDone: i <= _currentStep,
                              isLast: i == _statusSteps.length - 1,
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        for (final item in order.items)
                          FareRow(
                            label: '${item.name} ×${item.qty}',
                            value: '৳${(item.price * item.qty).toStringAsFixed(0)}',
                          ),
                        FareRow(label: 'Delivery fee', value: '৳${order.deliveryFee.toStringAsFixed(0)}'),
                        if (order.discount > 0)
                          FareRow(
                            label: 'Discount',
                            value: '-৳${order.discount.toStringAsFixed(0)}',
                            valueColor: AppColors.brandLime,
                          ),
                        const Divider(color: AppColors.inputBorder, height: 24),
                        FareRow(label: 'Total', value: '৳${order.total.toStringAsFixed(0)}', isTotal: true),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.primaryNavy, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.deliveryAddress,
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.label, required this.isDone, required this.isLast});

  final String label;
  final bool isDone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.primaryNavy : AppColors.inputBorder;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: color,
                size: 20,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: color),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
