import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _fetchingSingle = false;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureOrderLoaded());
  }

  /// Loads the order list if empty, then — if the requested order still
  /// isn't present (e.g. a deep link or cold app start straight into order
  /// details, where the order may be on a page not yet fetched) — fetches
  /// it directly via [OrdersProvider.fetchOrder] instead of relying solely
  /// on the in-memory list.
  Future<void> _ensureOrderLoaded() async {
    final p = context.read<OrdersProvider>();
    if (p.orders.isEmpty) {
      await p.load();
    }
    if (!mounted) return;
    if (p.findById(widget.orderId) != null) return;

    setState(() => _fetchingSingle = true);
    final order = await p.fetchOrder(widget.orderId);
    if (!mounted) return;
    setState(() {
      _fetchingSingle = false;
      _fetchError = order == null ? (p.error ?? 'Order not found') : null;
    });
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.newOrder:
        return 'New Order';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final order = provider.findById(widget.orderId);

    if ((provider.isLoading || _fetchingSingle) && order == null) {
      return const Scaffold(body: LoadingView());
    }
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: ErrorView(
          message: _fetchError ?? 'Order not found',
          onRetry: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Order ${order.displayId}', style: AppTextStyles.brand),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.info,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName, style: AppTextStyles.h3),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(order.customerPhone, style: AppTextStyles.caption),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppColors.rating),
                          const SizedBox(width: 4),
                          Text(
                            '${order.customerRating} Rating • ${order.customerOrderCount} Orders',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STATUS',
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(_statusLabel(order.status), style: AppTextStyles.h3),
                  ],
                ),
                Text(
                  'Received ${order.age.inMinutes}m ago',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Order Items', style: AppTextStyles.h3),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${order.itemCount} items',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: AppTextStyles.bodyBold),
                              if (item.notes.isNotEmpty)
                                Text(item.notes, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Text('x${item.quantity}', style: AppTextStyles.caption),
                        const SizedBox(width: 8),
                        Text(
                          '৳${item.lineTotal.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyBold,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                _PriceRow(label: 'Subtotal', value: order.subtotal),
                _PriceRow(label: 'Service Fee (HillGo)', value: order.serviceFee),
                _PriceRow(label: 'Tax', value: order.tax),
                if (order.deliveryFee > 0)
                  _PriceRow(label: 'Delivery Fee', value: order.deliveryFee),
                if (order.discount > 0)
                  _PriceRow(label: 'Discount', value: -order.discount),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Order Total', style: AppTextStyles.h3),
                    const Spacer(),
                    Text(
                      '৳${order.total.toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (order.customerNote != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E6),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('CUSTOMER NOTE', style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.customerNote!,
                    style: AppTextStyles.serifQuote,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: order.status == OrderStatus.newOrder
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isActing
                            ? null
                            : () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Reject order?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await provider.reject(order.id);
                                  if (context.mounted) context.pop();
                                }
                              },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Start Preparing',
                        icon: Icons.soup_kitchen_outlined,
                        loading: provider.isActing,
                        onPressed: () async {
                          final ok = await provider.startPreparing(order.id);
                          if (context.mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order moved to Preparing'),
                              ),
                            );
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.caption),
          const Spacer(),
          Text(
            '${value < 0 ? '-' : ''}৳${value.abs().toStringAsFixed(2)}',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
