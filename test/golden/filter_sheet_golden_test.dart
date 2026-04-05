import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_companion/logic/transaction/transaction_filter_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:finance_companion/presentation/screens/transactions/widgets/transaction_filter_sheet.dart';
import '../helpers/font_test_helper.dart';

class MockTransactionFilterCubit extends Mock implements TransactionFilterCubit {}

void main() {
  FontTestHelper.initialize();
  late MockTransactionFilterCubit mockCubit;

  setUp(() {
    mockCubit = MockTransactionFilterCubit();
  });

  Widget createWidget() {
    when(() => mockCubit.state).thenReturn(
      const TransactionFilterState(
        transactions: [],
        balance: 0.0,
        totalIncome: 0.0,
        totalExpense: 0.0,
        searchQuery: '',
        activeFilter: TransactionFilter.all,
        selectedCategories: ['Food', 'Health'], // Initial selection
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: BlocProvider<TransactionFilterCubit>.value(
          value: mockCubit,
          child: const Center(
            child: SizedBox(
              width: 400,
              height: 600,
              child: TransactionFilterSheet(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('TransactionFilterSheet Golden Test', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump(const Duration(milliseconds: 100)); // Static frame
    await expectLater(
      find.byType(TransactionFilterSheet),
      matchesGoldenFile('goldens/filter_sheet_default.png'),
    );
  });
}
