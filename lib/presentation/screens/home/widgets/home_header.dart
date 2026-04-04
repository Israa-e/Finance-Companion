import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../logic/notification/notification_cubit.dart';
import '../../notification/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  final void Function(int tabIndex) onTabSwitch;
  final void Function(int tabIndex)? onNotificationTap;

  const HomeHeader(
      {super.key, required this.onTabSwitch, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final imagePath = user?.imagePath;
        final name = user?.name.split(' ').first ?? '';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()} 👋',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(2),
                Text(
                  name.isNotEmpty ? name : 'My Finances',
                  style: AppTextStyles.h2,
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final notifCubit = context.read<NotificationCubit>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: notifCubit,
                          child: const NotificationsScreen(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Iconsax.notification,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        // FIX: read real unread count instead of hardcoded dot
                        BlocBuilder<NotificationCubit, NotificationState>(
                          builder: (context, notifState) {
                            if (notifState.unreadCount == 0)
                              return const SizedBox.shrink();
                            return Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.expense,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(10),
                // Avatar — taps to Profile tab
                GestureDetector(
                  onTap: () => onTabSwitch(4),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      image: imagePath != null && File(imagePath).existsSync()
                          ? DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (imagePath == null || !File(imagePath).existsSync())
                        ? const Icon(
                            Iconsax.user,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
