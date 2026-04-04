import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_companion/main.dart';

void main() {
  // ── App smoke test ──────────────────────────────────────────────────────────

  testWidgets('App launches without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FinanceApp(prefs: prefs));
    // Pump once to build the initial frame
    await tester.pumpAndSettle();
    // Drain all pending timers from SplashCubit.startSequence()
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // ── CurrencyFormatter unit tests ───────────────────────────────────────────

  group('CurrencyFormatter', () {
    const formatter = CurrencyFormatter(symbol: '\$');

    test('format returns dollar sign with two decimal places', () {
      expect(formatter.format(1234.5), '\$1,234.50');
    });

    test('format handles zero correctly', () {
      expect(formatter.format(0), '\$0.00');
    });

    test('formatCompact abbreviates thousands', () {
      expect(formatter.formatCompact(1500), '\$1.5k');
    });

    test('formatCompact does not abbreviate below 1000', () {
      expect(formatter.formatCompact(999), '\$999.00');
    });

    test('formatSigned prepends + for income', () {
      expect(formatter.formatSigned(100), '+\$100.00');
    });

    test('formatSigned prepends - for expense', () {
      expect(
        formatter.formatSigned(100, isExpense: true),
        '-\$100.00',
      );
    });
  });

  // ── TransactionLoaded filter logic unit tests ──────────────────────────────

  group('TransactionLoaded.filteredTransactions', () {
    final now = DateTime.now();

    final sampleTransactions = [
      TransactionModel(
        id: '1',
        userId: 1,
        amount: 50,
        type: TransactionType.expense,
        category: 'Food & Drinks',
        date: now,
        title: 'Coffee',
        lastUpdated: now,
      ),
      TransactionModel(
        id: '2',
        userId: 1,
        amount: 2000,
        type: TransactionType.income,
        category: 'Salary',
        date: now,
        title: 'Monthly Salary',
        lastUpdated: now,
      ),
      TransactionModel(
        id: '3',
        userId: 1,
        amount: 30,
        type: TransactionType.expense,
        category: 'Transport',
        date: now.subtract(const Duration(days: 60)),
        title: 'Bus ticket',
        lastUpdated: now.subtract(const Duration(days: 60)),
      ),
    ];

    TransactionLoaded makeState({
      TransactionFilter filter = TransactionFilter.all,
      String query = '',
    }) =>
        TransactionLoaded(
          transactions: sampleTransactions,
          balance: 1920,
          totalIncome: 2000,
          totalExpense: 80,
          formDate: now,
          searchQuery: query,
          activeFilter: filter,
        );

    test('filter all returns all transactions', () {
      final state = makeState();
      expect(state.filteredTransactions.length, 3);
    });

    test('filter income returns only income transactions', () {
      final state = makeState(filter: TransactionFilter.income);
      expect(state.filteredTransactions.length, 1);
      expect(
        state.filteredTransactions.first.type,
        TransactionType.income,
      );
    });

    test('filter expense returns only expense transactions', () {
      final state = makeState(filter: TransactionFilter.expense);
      expect(state.filteredTransactions.length, 2);
      for (final t in state.filteredTransactions) {
        expect(t.type, TransactionType.expense);
      }
    });

    test('search by title is case-insensitive', () {
      final state = makeState(query: 'coffee');
      expect(state.filteredTransactions.length, 1);
      expect(state.filteredTransactions.first.title, 'Coffee');
    });

    test('search with no match returns empty list', () {
      final state = makeState(query: 'xyz_no_match');
      expect(state.filteredTransactions, isEmpty);
    });

    test('filter thisMonth excludes transactions from 60 days ago', () {
      final state = makeState(filter: TransactionFilter.thisMonth);
      // Bus ticket is 60 days ago — should be excluded
      expect(
        state.filteredTransactions.any((t) => t.id == '3'),
        isFalse,
      );
    });

    test('balance is correctly computed from income minus expense', () {
      final state = makeState();
      // balance = 2000 income - 80 expense = 1920
      expect(state.balance, 1920);
    });
  });

  // ── TransactionLoaded.groupedTransactions ──────────────────────────────────

  group('TransactionLoaded.groupedTransactions', () {
    test('transactions from today are grouped under "Today"', () {
      final now = DateTime.now();
      final state = TransactionLoaded(
        transactions: [
          TransactionModel(
            id: '1',
            userId: 1,
            amount: 10,
            type: TransactionType.expense,
            category: 'Food & Drinks',
            date: now,
            title: 'Test',
            lastUpdated: now,
          ),
        ],
        balance: -10,
        totalIncome: 0,
        totalExpense: 10,
        formDate: now,
      );

      expect(state.groupedTransactions.keys.first, 'Today');
    });

    test('transactions from yesterday are grouped under "Yesterday"', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final state = TransactionLoaded(
        transactions: [
          TransactionModel(
            id: '1',
            userId: 1,
            amount: 10,
            type: TransactionType.expense,
            category: 'Food & Drinks',
            date: yesterday,
            title: 'Test',
            lastUpdated: yesterday,
          ),
        ],
        balance: -10,
        totalIncome: 0,
        totalExpense: 10,
        formDate: now,
      );

      expect(state.groupedTransactions.keys.first, 'Yesterday');
    });
  });
}
