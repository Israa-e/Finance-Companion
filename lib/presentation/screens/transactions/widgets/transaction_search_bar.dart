import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import 'package:iconsax/iconsax.dart';
import 'transaction_filter_sheet.dart';

class TransactionSearchBar extends StatelessWidget {
  const TransactionSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            onChanged: (value) =>
                context.read<TransactionCubit>().updateSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black45
                    : Colors.white60,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Iconsax.setting_4,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black45
                      : Colors.white60,
                  size: 20,
                ),
                onPressed: () {
                  final cubit = context.read<TransactionCubit>();
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const TransactionFilterSheet(),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
