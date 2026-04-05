import 'dart:io';
import 'package:finance_companion/presentation/screens/profile/category_management_screen.dart';
import 'package:finance_companion/presentation/screens/profile/recurring_bills_screen.dart';
import 'package:finance_companion/presentation/screens/profile/widgets/edit_profile_sheet.dart';
import 'package:finance_companion/presentation/screens/profile/widgets/menu_item.dart';
import 'package:finance_companion/presentation/screens/profile/widgets/stat_card.dart';
import 'package:finance_companion/presentation/screens/profile/widgets/user_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:finance_companion/l10n/app_localizations.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/theme/theme_cubit.dart';
import '../../../logic/locale/locale_cubit.dart';
import '../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:finance_companion/data/services/csv_export_service.dart';
import 'package:finance_companion/logic/category/category_cubit.dart';
import 'package:finance_companion/logic/recurring/recurring_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
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
                  Text(l10n.profile, style: AppTextStyles.h2),
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
                  _buildStatsRow(context, l10n),
                  const Gap(24),
                  _buildMenuItems(context, user, l10n),
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

  Widget _buildStatsRow(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<TransactionFilterCubit, TransactionFilterState>(
      builder: (context, state) {
        return Row(
          children: [
            StatCard(
                label: l10n.totalBalance,
                amount: state.balance,
                color: AppColors.primary),
            const Gap(8),
            StatCard(
                label: l10n.income,
                amount: state.totalIncome,
                color: AppColors.income),
            const Gap(8),
            StatCard(
                label: l10n.expense,
                amount: state.totalExpense,
                color: AppColors.expense),
          ],
        );
      },
    );
  }

  Widget _buildMenuItems(
      BuildContext context, UserModel user, AppLocalizations l10n) {
    return Column(
      children: [
        // Dark / Light toggle
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            final isDark = mode == ThemeMode.dark;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                value: isDark,
                activeColor: AppColors.primary,
                title: Text(
                  isDark ? l10n.darkMode : l10n.lightMode,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? AppColors.primary : AppColors.savings,
                ),
                onChanged: (value) =>
                    context.read<ThemeCubit>().toggleTheme(value),
              ),
            );
          },
        ),

        // Language selection
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                onTap: () => _showLanguagePicker(context),
                leading: const Icon(Iconsax.global, color: AppColors.primary),
                title: Text(
                  l10n.language,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.languageCode == 'ar'
                          ? 'العربية'
                          : locale.languageCode == 'hi'
                              ? 'हिन्दी'
                              : 'English',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(8),
                    if (locale.languageCode == 'ar')
                      const RotatedBox(
                        quarterTurns: 2,
                        child: Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                      )
                    else
                      const Icon(
                        Iconsax.arrow_right_3,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Biometric toggle
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            value: user.biometricEnabled,
            activeColor: AppColors.primary,
            title: Text(
              l10n.biometricLock,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            secondary: Icon(
              Iconsax.finger_scan,
              color: AppColors.primary,
            ),
            onChanged: (value) async {
              final authCubit = context.read<AuthCubit>();
              await authCubit.saveProfile(
                name: user.name,
                initialBalance: user.initialBalance,
                monthlyBudget: user.monthlyBudget,
                biometricEnabled: value,
              );
            },
          ),
        ),

        MenuItem(
          icon: Iconsax.refresh,
          label: l10n.syncNow,
          onTap: () async {
            context.read<TransactionFilterCubit>().load();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.syncNow}...')),
            );
          },
        ),

        MenuItem(
          icon: Iconsax.edit,
          label: l10n.editProfile,
          onTap: () => _showEditProfile(context, user),
        ),
        MenuItem(
          icon: Iconsax.category,
          label: l10n.manageCategories,
          onTap: () => _showCategoryManagement(context),
        ),
        MenuItem(
          icon: Iconsax.repeat,
          label: l10n.recurringBills,
          onTap: () => _showRecurringBills(context),
        ),
        MenuItem(
          icon: Iconsax.notification_status,
          label: l10n.budgetAlerts,
          onTap: () => _showBudgetSettings(context),
        ),
        MenuItem(
          icon: Iconsax.document_download,
          label: l10n.exportData,
          onTap: () async {
            final filterState = context.read<TransactionFilterCubit>().state;
            await CSVExportService.exportTransactions(
                filterState.filteredTransactions);
          },
        ),

        MenuItem(
          icon: Iconsax.logout,
          label: l10n.logout,
          color: AppColors.expense,
          onTap: () => _confirmLogout(context, l10n),
        ),
      ],
    );
  }

  void _showCategoryManagement(BuildContext context) {
    final categoryCubit = context.read<CategoryCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: categoryCubit,
          child: const CategoryManagementScreen(),
        ),
      ),
    );
  }

  void _showRecurringBills(BuildContext context) {
    final recurringCubit = context.read<RecurringCubit>();
    final categoryCubit = context.read<CategoryCubit>();
    final authCubit = context.read<AuthCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: recurringCubit),
            BlocProvider.value(value: categoryCubit),
            BlocProvider.value(value: authCubit),
          ],
          child: const RecurringBillsScreen(),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, UserModel user) {
    final authCubit = context.read<AuthCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: EditProfileSheet(
          initialName: user.name,
          initialImage: user.imagePath,
          initialBalance: user.initialBalance,
          initialMonthlyBudget: user.monthlyBudget,
          initialCurrency: user.currency,
        ),
      ),
    );
  }

  void _showBudgetSettings(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: const UserSettingsSheet(),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),
              Text(
                'Select Language',
                style: AppTextStyles.h3,
              ),
              const Gap(24),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                trailing: context.read<LocaleCubit>().state.languageCode == 'en'
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().setLocale('en');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                title: const Text('العربية'),
                trailing: context.read<LocaleCubit>().state.languageCode == 'ar'
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().setLocale('ar');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                title: const Text('हिन्दी'),
                trailing: context.read<LocaleCubit>().state.languageCode == 'hi'
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<LocaleCubit>().setLocale('hi');
                  Navigator.pop(ctx);
                },
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    final authCubit = context.read<AuthCubit>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logout, style: AppTextStyles.h3),
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
                    l10n.cancel,
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
                  label: l10n.logout,
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
