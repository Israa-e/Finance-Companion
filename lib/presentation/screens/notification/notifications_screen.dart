import 'package:finance_companion/core/theme/app_colors.dart';
import 'package:finance_companion/core/theme/app_text_styles.dart';
import 'package:finance_companion/data/models/notification_model.dart';
import 'package:finance_companion/logic/notification/notification_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.h3),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllRead(),
            child: Text(
              'Mark all read',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, size: 20),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear all notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Clear',
                        style: TextStyle(color: AppColors.expense),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<NotificationCubit>().clearAll();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.notification,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(16),
                  Text('No notifications yet', style: AppTextStyles.h3),
                  const Gap(8),
                  Text(
                    'Spending alerts and goal updates\nwill appear here',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, i) {
              final n = state.notifications[i];
              return _NotificationTile(
                notification: n,
                onTap: () => context.read<NotificationCubit>().markRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(notification.type);
    final icon = _iconForType(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).colorScheme.surface
              : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    notification.body,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                      fontSize: 10,
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

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.spendingAlert:
        return AppColors.expense;
      case NotificationType.goalDeadline:
        return AppColors.savings;
      case NotificationType.goalCompleted:
        return AppColors.income;
      case NotificationType.streakMilestone:
        return const Color(0xFFFF6B00);
      case NotificationType.monthlyBudgetWarning:
        return AppColors.expense;
    }
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.spendingAlert:
        return Iconsax.warning_2;
      case NotificationType.goalDeadline:
        return Iconsax.calendar;
      case NotificationType.goalCompleted:
        return Iconsax.tick_circle;
      case NotificationType.streakMilestone:
        return Iconsax.flash;
      case NotificationType.monthlyBudgetWarning:
        return Iconsax.chart_fail;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
