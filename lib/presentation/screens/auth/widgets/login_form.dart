import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
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
              CustomTextField(
                label: 'Email',
                hint: 'your@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Iconsax.sms,
                  size: 18,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Email is required';
                  }
                  if (!v.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const Gap(16),
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                prefixIcon: const Icon(
                  Iconsax.lock,
                  size: 18,
                ),
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
                  if (v.length < 6) {
                    return 'Min 6 characters';
                  }
                  return null;
                },
              ),
              const Gap(28),
              CustomButton(
                label: 'Login',
                isLoading: state is AuthLoading,
                onTap: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
