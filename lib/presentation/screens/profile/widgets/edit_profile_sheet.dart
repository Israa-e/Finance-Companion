import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String? initialImage;

  const EditProfileSheet({
    super.key,
    required this.initialName,
    this.initialImage,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.updateSuccess) {
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

        // Fallback to user data if buffers are null
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
                    final hasImage = currentImage != null && File(currentImage).existsSync();
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
              CustomTextField(
                label: 'Name',
                controller: _nameController,
                hint: 'Enter your name',
                onChanged: (v) => cubit.updateEditName(v),
              ),
              const Gap(24),
              CustomButton(
                label: 'Save Changes',
                isLoading: state.isUpdating,
                onTap: () => cubit.submitProfileUpdate(),
              ),
            ],
          ),
        );
      },
    );
  }
}
