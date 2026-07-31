import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: const HillGoAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Store Orders', style: AppTextStyles.h1),
                Text(
                  'Manage your real-time restaurant activity.',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'New (${orders.newOrders.length})'),
              Tab(text: 'Preparing (${orders.preparingOrders.length})'),
              Tab(text: 'Ready (${orders.readyOrders.length})'),
              Tab(text: 'History (${orders.deliveredOrders.length})'),
            ],
          ),
          Expanded(
            child: orders.isLoading && orders.orders.isEmpty
                ? const LoadingView()
                : orders.error != null && orders.orders.isEmpty
                    ? ErrorView(
                        message: orders.error!,
                        onRetry: () => context.read<OrdersProvider>().load(),
                      )
                    : TabBarView(
                        controller: _tabs,
                        children: const [
                          _NewOrdersTab(),
                          _PreparingTab(),
                          _ReadyTab(),
                          _HistoryTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _NewOrdersTab extends StatelessWidget {
  const _NewOrdersTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final list = provider.newOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Incoming requests ready for action',
                  style: AppTextStyles.subtitle,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${list.length} Pending',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        FilterChipBar(
          items: const ['All New', 'Priority', 'Express'],
          selected: provider.newFilter,
          activeColor: AppColors.accent,
          onSelected: provider.setNewFilter,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? const EmptyView(message: 'No new orders right now.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _NewOrderCard(order: list[i]),
                ),
        ),
      ],
    );
  }
}

class _NewOrderCard extends StatelessWidget {
  const _NewOrderCard({required this.order});

  final OrderModel order;

  Color get _badgeColor {
    switch (order.priority) {
      case OrderPriority.priority:
        return AppColors.errorSoft;
      case OrderPriority.express:
        return AppColors.warningSoft;
      case OrderPriority.scheduled:
        return const Color(0xFFE8F5E9);
      case OrderPriority.standard:
        return const Color(0xFFF0F0F0);
    }
  }

  Color get _badgeText {
    switch (order.priority) {
      case OrderPriority.priority:
        return AppColors.error;
      case OrderPriority.express:
        return AppColors.warning;
      case OrderPriority.scheduled:
        return AppColors.success;
      case OrderPriority.standard:
        return AppColors.textSecondary;
    }
  }

  String get _priorityLabel => order.priority.name.toUpperCase();

  String _timeLabel() {
    if (order.scheduledFor != null) {
      return DateFormat('HH:mm').format(order.scheduledFor!);
    }
    final m = order.age.inMinutes;
    if (m < 60) return '${m}m ago';
    return '${order.age.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final item = order.items.isNotEmpty ? order.items.first : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.push('/orders/${order.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _priorityLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: _badgeText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      Text(order.displayId, style: AppTextStyles.bodyBold),
                ),
                Icon(Icons.schedule, size: 14, color: _badgeText),
                const SizedBox(width: 4),
                Text(
                  _timeLabel(),
                  style: AppTextStyles.caption.copyWith(color: _badgeText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item != null) ...[
                        Text(
                          '${item.quantity}x ${item.name}'
                          '${order.items.length > 1 ? ' +${order.items.length - 1} more' : ''}',
                          style: AppTextStyles.bodyBold,
                        ),
                        if (item.notes.isNotEmpty)
                          Text(item.notes, style: AppTextStyles.caption),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '৳${order.total.toStringAsFixed(2)}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Customer: ${order.customerName}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Accept',
                    icon: Icons.check,
                    loading: provider.isActing,
                    onPressed: () async {
                      final ok = await provider.accept(order.id);
                      if (context.mounted && ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Order ${order.displayId} accepted'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isActing
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Reject order?'),
                                content: Text(
                                  'Reject order ${order.displayId}? This cannot be undone.',
                                ),
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
                            if (confirm == true) {
                              await provider.reject(order.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Order ${order.displayId} rejected'),
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.close, color: AppColors.error),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparingTab extends StatelessWidget {
  const _PreparingTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final list = provider.preparingOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            hint: 'Search by order or customer...',
            onChanged: provider.setSearch,
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyView(message: 'No orders being prepared.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      _KitchenCard(order: list[i], readyMode: false),
                ),
        ),
      ],
    );
  }
}

class _ReadyTab extends StatelessWidget {
  const _ReadyTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final list = provider.readyOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            hint: 'Search by order or customer...',
            onChanged: provider.setSearch,
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyView(message: 'No orders ready for pickup.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      _KitchenCard(order: list[i], readyMode: true),
                ),
        ),
      ],
    );
  }
}

class _KitchenCard extends StatelessWidget {
  const _KitchenCard({required this.order, required this.readyMode});

  final OrderModel order;
  final bool readyMode;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.push('/orders/${order.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ORDER ${order.displayId}',
                  style: AppTextStyles.caption.copyWith(letterSpacing: 0.6),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${order.age.inMinutes}m',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(order.customerName, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        style: AppTextStyles.body,
                      ),
                    ),
                    Text(
                      '৳${item.lineTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyBold,
                    ),
                  ],
                ),
              ),
            ),
            if (order.customerNote != null) ...[
              const SizedBox(height: 8),
              Text(
                order.customerNote!,
                style: AppTextStyles.serifQuote.copyWith(
                  color: const Color(0xFFA0522D),
                  fontSize: 13,
                ),
              ),
            ],
            const Divider(height: 24),
            PrimaryButton(
              label: readyMode ? 'Mark as Picked Up' : 'Mark as Ready',
              loading: provider.isActing,
              onPressed: () async {
                final ok = readyMode
                    ? await provider.markDelivered(order.id)
                    : await provider.markReady(order.id);
                if (context.mounted && ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        readyMode
                            ? 'Order ${order.displayId} delivered'
                            : 'Order ${order.displayId} moved to Ready',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final visible = provider.visibleHistory;
    final all = provider.deliveredOrders;
    final rated = all.where((o) => o.rating != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.fold<double>(0, (s, o) => s + o.rating!) / rated.length;
    final totalEarned = all.fold<double>(0, (s, o) => s + o.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Order History', style: AppTextStyles.h2),
        Text(
          'Review your successfully delivered shipments and customer feedback.',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 12),
        SearchField(
          hint: 'Search by Order ID...',
          onChanged: provider.setSearch,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (range != null) {
              provider.setHistoryDateRange(range.start, range.end);
            }
          },
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            provider.historyFrom == null
                ? 'Filter by Date'
                : '${DateFormat.MMMd().format(provider.historyFrom!)} – ${DateFormat.MMMd().format(provider.historyTo!)}',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.info,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              _StatCol(value: '${all.length}', label: 'DELIVERED'),
              _StatCol(
                value: avgRating != null ? avgRating.toStringAsFixed(1) : '—',
                label: 'AVG RATING',
              ),
              _StatCol(
                value: '৳${NumberFormat.compact().format(totalEarned)}',
                label: 'EARNED',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          const EmptyView(message: 'No delivered orders found.')
        else
          ...visible.map((o) => _HistoryCard(order: o)),
        if (visible.length < all.length) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: provider.loadMoreHistory,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.cardBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: const Text('Load Older Orders'),
          ),
        ],
      ],
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final item = order.items.isNotEmpty ? order.items.first : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ID: ${order.displayId}',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                if (order.rating != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: AppColors.rating),
                        const SizedBox(width: 4),
                        Text(
                          order.rating!.toStringAsFixed(1),
                          style: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (item != null) Text(item.name, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivered to: ${order.customerName}',
                        style: AppTextStyles.body,
                      ),
                      Text(
                        order.deliveredAt != null
                            ? DateFormat('MMM d, yyyy • hh:mm a')
                                .format(order.deliveredAt!)
                            : '',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Text(
                  '৳${order.total.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyBold,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  'SUCCESSFULLY DELIVERED',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/orders/${order.id}'),
                  child: Text(
                    'View Details',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
