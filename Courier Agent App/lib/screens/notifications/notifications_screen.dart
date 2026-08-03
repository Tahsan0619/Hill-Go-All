import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/profile_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}
class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; context.read<ProfileProvider>().loadNotifications(); }); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HillGoAppBar(
      title: 'Notifications', showBack: true, showBell: false,
      trailing: TextButton(onPressed: () => context.read<ProfileProvider>().markAllRead(), child: const Text('Mark all read')),
    ),
    body: Consumer<ProfileProvider>(builder: (context, profile, _) {
      if (profile.loading) return const LoadingView(message: 'Loading notifications...');
      if (profile.notifications.isEmpty) return const EmptyView(message: 'You are all caught up!', icon: Icons.notifications_off_outlined);
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          for (final note in profile.notifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                color: note.isRead ? null : const Color(0xFFF0F6FE),
                onTap: () => profile.markRead(note.id),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(backgroundColor: _color(note.type).withValues(alpha: .14), child: Icon(_icon(note.type), color: _color(note.type))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(note.title, style: AppTextStyles.h3),
                    const SizedBox(height: 3), Text(note.body, style: AppTextStyles.bodySecondary),
                    const SizedBox(height: 6), Text(DateFormat('MMM d, h:mm a').format(note.createdAt), style: AppTextStyles.caption),
                  ])),
                  if (!note.isRead) const Icon(Icons.circle, size: 9, color: AppColors.accent),
                ]),
              ),
            ),
          if (profile.hasMoreNotifications)
            PrimaryButton(
              label: 'Load More',
              loading: profile.loadingMoreNotifications,
              onPressed: profile.loadingMoreNotifications ? null : profile.loadMoreNotifications,
              icon: Icons.expand_more_rounded,
            ),
        ],
      );
    }),
  );
  Color _color(NotificationType type) => switch (type) { NotificationType.alert => AppColors.error, NotificationType.earnings => AppColors.success, NotificationType.delivery => AppColors.accent, _ => AppColors.primary };
  IconData _icon(NotificationType type) => switch (type) { NotificationType.alert => Icons.warning_amber_outlined, NotificationType.earnings => Icons.payments_outlined, NotificationType.delivery => Icons.local_shipping_outlined, _ => Icons.info_outline };
}
