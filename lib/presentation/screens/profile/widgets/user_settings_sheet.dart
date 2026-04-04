import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../shared/widgets/custom_button.dart';

class UserSettingsSheet extends StatefulWidget {
  const UserSettingsSheet({super.key});

  @override
  State<UserSettingsSheet> createState() => _UserSettingsSheetState();
}

class _UserSettingsSheetState extends State<UserSettingsSheet> {
  late double _warning;
  late double _critical;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _warning = authState.user.warningThreshold;
      _critical = authState.user.criticalThreshold;
    } else {
      _warning = 0.8;
      _critical = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget Alerts', style: AppTextStyles.h2),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Gap(16),
          Text(
            'Define when you want to receive notifications relative to your monthly budget.',
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Gap(24),
          
          // Warning Threshold
          const _Label(title: 'Warning Threshold', subtitle: 'Receive a yellow alert'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _warning,
                  min: 0.1,
                  max: 0.95,
                  divisions: 17,
                  activeColor: AppColors.income,
                  onChanged: (val) {
                    setState(() {
                      _warning = val;
                      if (_warning >= _critical) _critical = (_warning + 0.05).clamp(0.0, 1.5);
                    });
                  },
                ),
              ),
              Text(
                '${(_warning * 100).toInt()}%',
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const Gap(16),
          
          // Critical Threshold
          const _Label(title: 'Critical Threshold', subtitle: 'Receive a red alert'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _critical,
                  min: 0.5,
                  max: 1.5,
                  divisions: 20,
                  activeColor: AppColors.expense,
                  onChanged: (val) {
                    setState(() {
                      _critical = val;
                      if (_critical <= _warning) _warning = (_critical - 0.05).clamp(0.0, 1.5);
                    });
                  },
                ),
              ),
              Text(
                '${(_critical * 100).toInt()}%',
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const Gap(32),
          
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isUpdating = state is AuthAuthenticated && state.isUpdating;
              return CustomButton(
                label: 'Save Changes',
                isLoading: isUpdating,
                onTap: () async {
                  final auth = context.read<AuthCubit>();
                  final navigator = Navigator.of(context);
                  final current = auth.state as AuthAuthenticated;
                  
                  await auth.saveProfile(
                    name: current.user.name,
                    initialBalance: current.user.initialBalance,
                    monthlyBudget: current.user.monthlyBudget,
                    currency: current.user.currency,
                    warningThreshold: _warning,
                    criticalThreshold: _critical,
                  );
                  
                  if (mounted) navigator.pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Label({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
