import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    final newBalance =
        double.tryParse(_balanceController.text) ?? widget.initialBalance;
    final newBudget =
        double.tryParse(_budgetController.text) ?? widget.initialMonthlyBudget;

    // FIX: removed the dead `updatedUser` variable that was built but never
    // used. We call updateProfileWithBalance directly with the correct values.
    context.read<AuthCubit>().saveProfile(
          name: name,
          imagePath: state.editImagePath ?? state.user.imagePath,
          initialBalance: newBalance,
          monthlyBudget: newBudget,
          currency: _selectedCurrency,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.updateSuccess) {
          // Refresh transaction balance to reflect the new starting balance
          context
              .read<TransactionCubit>()
              .setInitialBalance(state.user.initialBalance);
          context.read<TransactionCubit>().loadTransactions();
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                Text('Edit Profile', style: AppTextStyles.h3),
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
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Enter your name',
                  onChanged: (v) => cubit.updateEditName(v),
                ),
                const Gap(16),

                // Starting balance
                CustomTextField(
                  label: 'Starting Balance',
                  controller: _balanceController,
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon:
                      const Icon(Iconsax.dollar_circle, size: 18),
                ),
                const Gap(16),

                // Monthly budget
                CustomTextField(
                  label: 'Monthly Budget',
                  controller: _budgetController,
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon:
                      const Icon(Iconsax.chart, size: 18),
                ),
                const Gap(16),

                // Currency Dropdown
                DropdownButtonFormField<String>(
                  value: AppConstants.supportedCurrencies.containsKey(_selectedCurrency) 
                      ? _selectedCurrency 
                      : AppConstants.supportedCurrencies.keys.first,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                    prefixIcon: const Icon(Iconsax.global, size: 18, color: AppColors.textHint),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items: AppConstants.supportedCurrencies.keys.map((code) {
                    final symbol = AppConstants.supportedCurrencies[code];
                    return DropdownMenuItem(
                      value: code,
                      child: Text('$code ($symbol)', style: AppTextStyles.body),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCurrency = val);
                  },
                ),
                const Gap(24),

                CustomButton(
                  label: 'Save Changes',
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