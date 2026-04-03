import 'dart:io';
import 'package:finance_companion/presentation/screens/profile/widgets/edit_profile_sheet.dart';
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
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/user_model.dart';
import '../../shared/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text(user.name, style: AppTextStyles.h3),
                  Text(user.email, style: AppTextStyles.bodySmall),
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
            _StatCard(
              label: 'Balance',
              amount: balance,
              color: AppColors.primary,
            ),
            const Gap(8),
            _StatCard(label: 'Income', amount: income, color: AppColors.income),
            const Gap(8),
            _StatCard(
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
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                value: mode == ThemeMode.dark,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Dark Mode',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                secondary: Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onChanged: (value) =>
                    context.read<ThemeCubit>().toggleTheme(value),
              ),
            );
          },
        ),
        _MenuItem(
          icon: Iconsax.edit,
          label: 'Edit Profile',
          onTap: () => _showEditProfile(context, user),
        ),
        _MenuItem(
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

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
            const Gap(4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        title: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onTap: onTap,
      ),
    );
  }
}
