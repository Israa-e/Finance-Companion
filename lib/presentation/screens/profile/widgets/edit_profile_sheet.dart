import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../logic/transaction/transaction_filter_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

import 'package:finance_companion/l10n/app_localizations.dart';

class EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String? initialImage;
  final double initialBalance;
  final double initialMonthlyBudget;
  final String initialCurrency;

  const EditProfileSheet({
    super.key,
    required this.initialName,
    this.initialImage,
    required this.initialBalance,
    required this.initialMonthlyBudget,
    required this.initialCurrency,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _budgetController;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _balanceController = TextEditingController(
      text: widget.initialBalance.toStringAsFixed(2),
    );
    _budgetController = TextEditingController(
      text: widget.initialMonthlyBudget.toStringAsFixed(2),
    );
    _selectedCurrency = widget.initialCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, AuthAuthenticated state) {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nameCannotBeEmpty)),
      );
      return;
    }

    final newBalance =
        double.tryParse(_balanceController.text) ?? widget.initialBalance;
    final newBudget =
        double.tryParse(_budgetController.text) ?? widget.initialMonthlyBudget;

    context.read<AuthCubit>().saveProfile(
          name: name,
          imagePath: state.editImagePath ?? state.user.imagePath,
          initialBalance: newBalance,
          monthlyBudget: newBudget,
          currency: _selectedCurrency,
        );
  }

  void _showCurrencyPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Text(l10n.selectCurrency, style: AppTextStyles.h3),
            const Gap(16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: AppConstants.supportedCurrencies.keys.map((code) {
                  final symbol = AppConstants.supportedCurrencies[code];
                  final isSelected = code == _selectedCurrency;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedCurrency = code);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            symbol ?? '',
                            style: AppTextStyles.h3.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Text(
                              code,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.updateSuccess) {
          // Refresh transaction fitlers to reflect changes (balance, currency)
          context.read<TransactionFilterCubit>().load();
          Navigator.pop(context);
        }
        if (state is AuthAuthenticated && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final cubit = context.read<AuthCubit>();
        final l10n = AppLocalizations.of(context)!;
        final currentImage = state.editImagePath ?? state.user.imagePath;

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(16),
                Text(l10n.editProfile, style: AppTextStyles.h3),
                const Gap(20),

                // Avatar picker
                GestureDetector(
                  onTap: () => cubit.pickEditImage(),
                  child: Builder(
                    builder: (context) {
                      final hasImage = currentImage != null &&
                          File(currentImage).existsSync();
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          image: hasImage
                              ? DecorationImage(
                                  image: FileImage(File(currentImage)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasImage
                            ? const Icon(
                                Iconsax.camera,
                                color: AppColors.primary,
                                size: 28,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const Gap(20),

                // Name field
                CustomTextField(
                  label: l10n.fullName,
                  controller: _nameController,
                  hint: l10n.tapToChangePhoto,
                  onChanged: (v) => cubit.updateEditName(v),
                ),
                const Gap(16),

                // Starting balance
                CustomTextField(
                  label: l10n.startingBalance,
                  controller: _balanceController,
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon: const Icon(Iconsax.dollar_circle, size: 18),
                ),
                const Gap(16),

                // Monthly budget
                CustomTextField(
                  label: l10n.monthlyBudget,
                  controller: _budgetController,
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon: const Icon(Iconsax.chart, size: 18),
                ),
                const Gap(16),

                // Currency Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        l10n.language, // Reusing 'language' or should I use 'currency'?
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ),
                    CustomButton(
                      label:
                          '$_selectedCurrency (${AppConstants.supportedCurrencies[_selectedCurrency]})',
                      isField: true,
                      icon: Iconsax.global,
                      onTap: () => _showCurrencyPicker(context),
                    ),
                  ],
                ),
                const Gap(24),

                CustomButton(
                  label: l10n.saveChanges,
                  isLoading: state.isUpdating,
                  onTap: () => _submit(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
