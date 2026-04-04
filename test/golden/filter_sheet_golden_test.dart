import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_companion/logic/transaction/transaction_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:finance_companion/presentation/screens/transactions/widgets/transaction_filter_sheet.dart';
import '../helpers/font_test_helper.dart';

class MockTransactionCubit extends Mock implements TransactionCubit {}

void main() {
  FontTestHelper.initialize();
  late MockTransactionCubit mockCubit;

  setUp(() {
    mockCubit = MockTransactionCubit();
  });

  Widget createWidget() {
    when(() => mockCubit.state).thenReturn(
      TransactionLoaded(
        transactions: const [],
        balance: 0.0,
        totalIncome: 0.0,
        totalExpense: 0.0,
        searchQuery: '',
        activeFilter: TransactionFilter.all,
        selectedCategories: const ['Food', 'Health'], // Initial selection
        formDate: DateTime.now(),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: BlocProvider<TransactionCubit>.value(
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
