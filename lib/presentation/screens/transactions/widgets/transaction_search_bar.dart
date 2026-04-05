import 'package:finance_companion/core/theme/app_colors.dart';
import 'package:finance_companion/l10n/app_localizations.dart';
import 'package:finance_companion/logic/transaction/transaction_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'transaction_filter_sheet.dart';

class TransactionSearchBar extends StatefulWidget {
  const TransactionSearchBar({super.key});

  @override
  State<TransactionSearchBar> createState() => _TransactionSearchBarState();
}

class _TransactionSearchBarState extends State<TransactionSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<TransactionFilterCubit>().state.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<TransactionFilterCubit>().updateSearchQuery(query);
  }

  void _onFilter() {
    final filterCubit = context.read<TransactionFilterCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: filterCubit,
        child: const TransactionFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final hintColor = AppColors.textHint;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: '${l10n.search}...',
                      hintStyle: AppTextStyles.body.copyWith(color: hintColor),
                      prefixIcon: Icon(Iconsax.search_normal,
                          color: hintColor, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _onFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.transparent, // expand tap area
                    child: Icon(Iconsax.setting_4,
                        color: AppColors.textSecondary, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
