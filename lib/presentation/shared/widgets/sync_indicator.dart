import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/connectivity/connectivity_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isOnline = state.status != ConnectivityStatus.offline;
        final isSyncing = state.status == ConnectivityStatus.syncing;
        final statusLabel = isSyncing 
            ? 'Synchronizing data with cloud' 
            : (isOnline ? 'Online and synced' : 'Offline: using local data');

        return Semantics(
          label: 'Connection status: $statusLabel',
          container: true,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.easeInOutSine,
            builder: (context, opacity, child) {
              // Only animate opacity when syncing
              final effectiveOpacity = isSyncing ? opacity : 1.0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isSyncing 
                      ? AppColors.primary 
                      : isOnline 
                          ? AppColors.income 
                          : AppColors.expense).withValues(alpha: 0.1 * effectiveOpacity),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isSyncing 
                        ? AppColors.primary 
                        : isOnline 
                            ? AppColors.income 
                            : AppColors.expense).withValues(alpha: 0.2 * effectiveOpacity),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSyncing)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    else
                      Icon(
                        isOnline ? Iconsax.cloud_sunny : Iconsax.cloud_notif,
                        size: 14,
                        color: isOnline ? AppColors.income : AppColors.expense,
                      ),
                    const Gap(6),
                    Text(
                      isSyncing ? 'Syncing...' : (isOnline ? 'Live' : 'Offline'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSyncing 
                            ? AppColors.primary 
                            : isOnline 
                                ? AppColors.income 
                                : AppColors.expense,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
            // Loop the animation if syncing
            onEnd: () {}, 
          ),
        );
      },
    );
  }
}
