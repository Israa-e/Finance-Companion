import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'build_avatar_picker.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _obscurePassword = true;
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await context.read<AuthCubit>().pickImage();
    if (path != null) setState(() => _imagePath = path);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      initialBalance: double.parse(_balanceController.text),
      imagePath: _imagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(8),
              // ── Avatar picker (optional) ──────────────────────
              BuildAvatarPicker(
                imagePath: _imagePath,
                pickImage: _pickImage,
              ),
              const Gap(6),
              Center(
                child: Text(
                  _imagePath == null
                      ? 'Tap to add a profile photo (optional)'
                      : 'Tap to change photo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Gap(28),
              // ── Fields ────────────────────────────────────────
              CustomTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                prefixIcon: const Icon(Iconsax.user, size: 18),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const Gap(16),
              CustomTextField(
                label: 'Email',
                hint: 'your@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Iconsax.sms, size: 18),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const Gap(16),
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Iconsax.lock, size: 18),
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  child: Icon(
                    _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Password is required';
                  }
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
              const Gap(16),
              CustomTextField(
                label: 'Starting Balance',
                hint: '0.00',
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'),
                  ),
                ],
                prefixIcon: const Icon(Iconsax.dollar_circle, size: 18),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Starting balance is required';
                  }
                  final parsed = double.tryParse(v);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed < 0) return 'Balance cannot be negative';
                  return null;
                },
              ),
              const Gap(6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Your current account balance — used as your starting point.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Gap(32),
              CustomButton(
                label: 'Create Account',
                isLoading: state is AuthLoading,
                onTap: _submit,
                icon: Iconsax.user_add,
              ),
            ],
          ),
        );
      },
    );
  }
}
