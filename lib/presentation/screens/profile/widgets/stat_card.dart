import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';

class StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final authState = context.watch<AuthCubit>().state;
                final formatter = authState is AuthAuthenticated
                    ? authState.formatter
                    : const CurrencyFormatter();
                return Text(
                  formatter.formatCompact(amount),
                  style: AppTextStyles.amountSmall.copyWith(color: color),
                );
              },
            ),
            const Gap(4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}