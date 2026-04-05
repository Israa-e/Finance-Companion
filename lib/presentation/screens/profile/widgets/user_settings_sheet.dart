import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../shared/widgets/custom_button.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
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
              Text(l10n.budgetAlerts, style: AppTextStyles.h2),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Gap(16),
          Text(
            l10n.budgetAlertsSubtitle,
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const Gap(24),

          // Warning Threshold
          _Label(
              title: l10n.warningThreshold,
              subtitle: l10n.warningThresholdSubtitle),
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
                      if (_warning >= _critical) {
                        _critical = (_warning + 0.05).clamp(0.5, 1.5);
                      }
                    });
                  },
                ),
              ),
              Text(
                '${(_warning * 100).toInt()}%',
                style:
                    AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Gap(16),

          // Critical Threshold
          _Label(
              title: l10n.criticalThreshold,
              subtitle: l10n.criticalThresholdSubtitle),
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
                      if (_critical <= _warning) {
                        _warning = (_critical - 0.05).clamp(0.1, 0.95);
                      }
                    });
                  },
                ),
              ),
              Text(
                '${(_critical * 100).toInt()}%',
                style:
                    AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Gap(32),

          CustomButton(
            label: l10n.save,
            onTap: () async {
              final authCubit = context.read<AuthCubit>();
              final currentState = authCubit.state;
              if (currentState is AuthAuthenticated) {
                await authCubit.saveProfile(
                  name: currentState.user.name,
                  initialBalance: currentState.user.initialBalance,
                  monthlyBudget: currentState.user.monthlyBudget,
                  currency: currentState.user.currency,
                  warningThreshold: _warning,
                  criticalThreshold: _critical,
                );
                if (context.mounted) Navigator.pop(context);
              }
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
        Text(title,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
