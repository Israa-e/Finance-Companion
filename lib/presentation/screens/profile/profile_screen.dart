import 'dart:io';
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
import '../../shared/widgets/custom_text_field.dart';

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
              if (state is! AuthAuthenticated) return const SizedBox.shrink();
              final user = state.user;

              return Column(
                children: [
                  const Gap(16),
                  Text('Profile', style: AppTextStyles.h2),
                  const Gap(28),
                  _buildAvatar(user.imagePath),
                  const Gap(12),
                  Text(user.name, style: AppTextStyles.h3),
                  Text(user.email, style: AppTextStyles.bodySmall),
                  const Gap(24),
                  _buildStatsRow(context),
                  const Gap(24),
                  _buildMenuItems(context, user),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imagePath) {
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
        image: imagePath != null
            ? DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imagePath == null
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

  Widget _buildMenuItems(BuildContext context, user) {
    return Column(
      children: [
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
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
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme(value);
                },
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

  void _showEditProfile(BuildContext context, user) {
    final nameController = TextEditingController(text: user.name);
    String? newImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: StatefulBuilder(
          builder: (ctx, setState) => Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Profile', style: AppTextStyles.h3),
                const Gap(20),
                GestureDetector(
                  onTap: () async {
                    final path = await context.read<AuthCubit>().pickImage();
                    if (path != null) setState(() => newImagePath = path);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      image: (newImagePath ?? user.imagePath) != null
                          ? DecorationImage(
                              image: FileImage(
                                File(newImagePath ?? user.imagePath!),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (newImagePath ?? user.imagePath) == null
                        ? const Icon(
                            Iconsax.camera,
                            color: AppColors.primary,
                            size: 28,
                          )
                        : null,
                  ),
                ),
                const Gap(16),
                CustomTextField(
                  label: 'Name',
                  controller: nameController,
                  hint: 'Enter your name',
                ),
                const Gap(20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthCubit>().updateProfile(
                      name: nameController.text,
                      imagePath: newImagePath,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
            child: const Text('Logout'),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
            const Gap(2),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
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
