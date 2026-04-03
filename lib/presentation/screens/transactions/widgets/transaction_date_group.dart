import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/transaction_model.dart';
import 'transaction_list_item.dart';
import 'package:gap/gap.dart';

class TransactionDateGroup extends StatelessWidget {
  final String label;
  final List<TransactionModel> transactions;
  final void Function(TransactionModel) onEdit;
  final void Function(TransactionModel) onDelete;

  const TransactionDateGroup({
    super.key,
    required this.label,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Row(
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.textSecondary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
        ...transactions.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionListItem(
              transaction: t,
              onEdit: () => onEdit(t),
              onDelete: () => onDelete(t),
            ),
          ),
        ),
      ],
    );
  }
}
