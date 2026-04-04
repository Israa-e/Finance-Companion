import 'dart:io';
import 'package:finance_companion/presentation/screens/profile/widgets/edit_profile_sheet.dart';
import 'package:finance_companion/presentation/screens/profile/widgets/menu_item.dart';
import 'package:finance_companion/presentation/screens/profile/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/theme/theme_cubit.dart';
import '../../../logic/transaction/transaction_cubit.dart';
import '../../../logic/transaction/transaction_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use theme background — not hardcoded
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated) {
                return const SizedBox.shrink();
              }
              final user = state.user;

              return Column(
                children: [
                  const Gap(16),
                  Text('Profile', style: AppTextStyles.h2),
                  const Gap(32),
                  _buildAvatar(user.imagePath),
                  const Gap(16),
                  Text(
                    user.name,
                    style: AppTextStyles.h3.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Gap(24),
                  _buildStatsRow(context),
                  const Gap(24),
                  _buildMenuItems(context, user),
                  const Gap(24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imagePath) {
    final hasImage = imagePath != null && File(imagePath).existsSync();
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        image: hasImage
            ? DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasImage
          ? const Icon(Iconsax.user, size: 40, color: AppColors.primary)
          : null,
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final income = state is TransactionLoaded ? state.totalIncome : 0.0;
        final expense = state is TransactionLoaded ? state.totalExpense : 0.0;
        final balance = state is TransactionLoaded ? state.balance : 0.0;

        return Row(
          children: [
            StatCard(
              label: 'Balance',
              amount: balance,
              color: AppColors.primary,
            ),
            const Gap(8),
            StatCard(label: 'Income', amount: income, color: AppColors.income),
            const Gap(8),
            StatCard(
              label: 'Expense',
              amount: expense,
              color: AppColors.expense,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context, UserModel user) {
    return Column(
      children: [
        // ── Dark / Light toggle ─────────────────────────────────────────────
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            final isDark = mode == ThemeMode.dark;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                // Use theme surface so it respects light/dark
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                value: isDark,
                activeColor: AppColors.primary,
                title: Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? AppColors.primary : AppColors.savings,
                ),
                onChanged: (value) {
                  // This reads the SAME ThemeCubit provided in main.dart
                  // so the entire MaterialApp rebuilds immediately
                  context.read<ThemeCubit>().toggleTheme(value);
                },
              ),
            );
          },
        ),

        MenuItem(
          icon: Iconsax.edit,
          label: 'Edit Profile',
          onTap: () => _showEditProfile(context, user),
        ),
        MenuItem(
          icon: Iconsax.logout,
          label: 'Logout',
          color: AppColors.expense,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  void _showEditProfile(BuildContext context, UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: EditProfileSheet(
          initialName: user.name,
          initialImage: user.imagePath,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.body,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: CustomButton(
                  label: 'Logout',
                  color: AppColors.expense,
                  onTap: () {
                    Navigator.pop(ctx);
                    authCubit.logout();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
