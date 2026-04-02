import 'package:finance_companion/presentation/screens/auth/widgets/build_avatar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _obscurePassword = true;
  String? _imagePath;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _balanceController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account', style: AppTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: AppColors.expense,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
          }
        },
        builder: (context, state) {
          return ClipRect(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(8),
                      BuildAvatarPicker(
                        imagePath: _imagePath,
                        pickImage: _pickImage,
                      ),
                      if (_imagePath == null) ...[
                        const Gap(6),
                        Center(
                          child: Text(
                            'Tap to add a profile photo',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                      const Gap(28),
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
                          if (v.length < 6) {
                            return 'Min 6 characters';
                          }
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
                            return 'Balance is required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                      const Gap(6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Your current account balance — used as your starting point.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const Gap(32),
                      CustomButton(
                        label: 'Create Account',
                        isLoading: state is AuthLoading,
                        onTap: _submit,
                        icon: Iconsax.user_add,
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final path = await context.read<AuthCubit>().pickImage();
    if (path != null) setState(() => _imagePath = path);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_imagePath == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.photo_camera_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Please add a profile photo'),
              ],
            ),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      initialBalance: double.parse(_balanceController.text),
      imagePath: _imagePath,
    );
  }
}
