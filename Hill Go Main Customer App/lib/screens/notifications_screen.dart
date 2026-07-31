import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../services/api/api_client.dart';
import '../services/api/notifications_api.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_bar.dart';
import '../widgets/load_state_views.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  int _unread = 0;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final inbox = await NotificationsApi.inbox();
      if (!mounted) return;
      setState(() {
        _notifications = inbox.items;
        _unread = inbox.unread;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _loading = false;
      });
    }
  }

  void _showError(ApiException e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _markAllRead() async {
    try {
      await NotificationsApi.markAllRead();
      if (!mounted) return;
      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _unread = 0;
      });
    } on ApiException catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _markRead(AppNotification item) async {
    if (item.isRead) return;
    try {
      await NotificationsApi.markRead(item.id);
      if (!mounted) return;
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          _notifications[index] = item.copyWith(isRead: true);
        }
        _unread = _unread > 0 ? _unread - 1 : 0;
      });
    } on ApiException catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _delete(AppNotification item) async {
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
      if (!item.isRead && _unread > 0) _unread -= 1;
    });
    try {
      await NotificationsApi.delete(item.id);
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e);
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final notifications = _notifications;
    final unread = _unread;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackBar(
                title: 'Notifications',
                subtitle: unread > 0 ? '$unread unread' : 'All caught up',
                actions: [
                  if (unread > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const LoadingView()
                    : _loadError != null
                        ? LoadErrorView(message: _loadError!, onRetry: _load)
                        : notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_off_outlined,
                                      size: 56,
                                      color: AppColors.textMuted
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No notifications yet',
                                      style: textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.separated(
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: notifications.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = notifications[index];
                                    return Dismissible(
                                      key: ValueKey(item.id),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (_) => _delete(item),
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      child: _NotificationTile(
                                        notification: item,
                                        onTap: () => _markRead(item),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: notification.isRead
          ? AppColors.white
          : AppColors.accentBlueSoft.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.timeLabel,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
