import 'package:finance_companion/core/utils/currency_formatter.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/logic/transaction/transaction_filter_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_companion/main.dart';
import 'package:finance_companion/injection_container.dart';
import 'package:finance_companion/data/repositories/category_repository.dart';
import 'package:finance_companion/data/repositories/goal_repository.dart';
import 'package:finance_companion/data/repositories/recurring_repository.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/data/repositories/notification_repository.dart';
import 'package:finance_companion/data/services/recurring_processor_service.dart';
import 'package:finance_companion/data/services/alert_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockTxRepo extends Mock implements TransactionRepository {}
class MockGoalRepo extends Mock implements GoalRepository {}
class MockCategoryRepo extends Mock implements CategoryRepository {}
class MockRecurringRepo extends Mock implements RecurringRepository {}
class MockAuthRepo extends Mock implements AuthRepository {}
class MockNotifRepo extends Mock implements NotificationRepository {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  setUpAll(() {
    registerFallbackValue(TransactionModel(
      id: 'fake',
      userId: 1,
      amount: 0,
      type: TransactionType.income,
      category: 'fake',
      date: DateTime.now(),
      title: 'fake',
      lastUpdated: DateTime.now(),
    ));
  });

  setUp(() {
    const channel = MethodChannel('be.tramckas.workmanager/foreground_setup_channel');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  testWidgets('App launches without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    await sl.reset();
    
    final mockTx = MockTxRepo();
    final mockGoal = MockGoalRepo();
    final mockCategory = MockCategoryRepo();
    final mockRecurring = MockRecurringRepo();
    final mockAuth = MockAuthRepo();
    final mockNotifRepo = MockNotifRepo();
    final mockConnectivity = MockConnectivity();

    sl.registerSingleton<SharedPreferences>(prefs);
    sl.registerSingleton<TransactionRepository>(mockTx);
    sl.registerSingleton<GoalRepository>(mockGoal);
    sl.registerSingleton<CategoryRepository>(mockCategory);
    sl.registerSingleton<RecurringRepository>(mockRecurring);
    sl.registerSingleton<AuthRepository>(mockAuth);
    sl.registerSingleton<NotificationRepository>(mockNotifRepo);
    sl.registerSingleton<Connectivity>(mockConnectivity);
    
    sl.registerSingleton<RecurringProcessorService>(
      RecurringProcessorService(mockRecurring, mockTx),
    );
    sl.registerSingleton<AlertService>(AlertService(mockNotifRepo));

    when(() => mockTx.getAll()).thenAnswer((_) async => []);
    when(() => mockGoal.getAll(any())).thenAnswer((_) async => []);
    when(() => mockCategory.getAll(any())).thenAnswer((_) async => []);
    when(() => mockRecurring.getAll(any())).thenAnswer((_) async => []);
    when(() => mockAuth.getLoggedInUser()).thenAnswer((_) async => null);
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

    await tester.pumpWidget(const FinanceApp(isTestMode: true));
    await tester.pump(const Duration(seconds: 5));
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  group('CurrencyFormatter', () {
    const formatter = CurrencyFormatter(symbol: '\$');
    test('format returns dollar sign with two decimal places', () => expect(formatter.format(1234.5), '\$1,234.50'));
    test('format handles zero correctly', () => expect(formatter.format(0), '\$0.00'));
    test('formatCompact abbreviates thousands', () => expect(formatter.formatCompact(1500), '\$1.5k'));
    test('formatCompact does not abbreviate below 1000', () => expect(formatter.formatCompact(999), '\$999.00'));
    test('formatSigned prepends + for income', () => expect(formatter.formatSigned(100), '+\$100.00'));
    test('formatSigned prepends - for expense', () => expect(formatter.formatSigned(100, isExpense: true), '-\$100.00'));
  });

  group('TransactionFilterState.filteredTransactions', () {
    final now = DateTime.now();
    final sampleTransactions = [
      TransactionModel(id: '1', userId: 1, amount: 50, type: TransactionType.expense, category: 'Food & Drinks', date: now, title: 'Coffee', lastUpdated: now),
      TransactionModel(id: '2', userId: 1, amount: 2000, type: TransactionType.income, category: 'Salary', date: now, title: 'Monthly Salary', lastUpdated: now),
      TransactionModel(id: '3', userId: 1, amount: 30, type: TransactionType.expense, category: 'Transport', date: now.subtract(const Duration(days: 60)), title: 'Bus ticket', lastUpdated: now.subtract(const Duration(days: 60))),
    ];

    TransactionFilterState makeState({
      TransactionFilter filter = TransactionFilter.all,
      String query = '',
    }) =>
        TransactionFilterState(
          transactions: sampleTransactions,
          balance: 1920,
          totalIncome: 2000,
          totalExpense: 80,
          searchQuery: query,
          activeFilter: filter,
        );

    test('filter all returns all transactions', () => expect(makeState().filteredTransactions.length, 3));
    test('filter income returns only income', () {
      final state = makeState(filter: TransactionFilter.income);
      expect(state.filteredTransactions.length, 1);
      expect(state.filteredTransactions.first.type, TransactionType.income);
    });
    test('filter expense returns only expense', () {
      final state = makeState(filter: TransactionFilter.expense);
      expect(state.filteredTransactions.length, 2);
    });
    test('search by title is case-insensitive', () {
      final state = makeState(query: 'coffee');
      expect(state.filteredTransactions.length, 1);
      expect(state.filteredTransactions.first.title, 'Coffee');
    });
    test('filter thisMonth excludes old transactions', () {
      final state = makeState(filter: TransactionFilter.thisMonth);
      expect(state.filteredTransactions.any((t) => t.id == '3'), isFalse);
    });
  });

  group('TransactionFilterState.groupedTransactions', () {
    final now = DateTime.now();
    test('today grouping', () {
      final state = TransactionFilterState(
        transactions: [TransactionModel(id: '1', userId: 1, amount: 10, type: TransactionType.expense, category: 'Food', date: now, title: 'T', lastUpdated: now)],
        balance: -10, totalIncome: 0, totalExpense: 10,
      );
      expect(state.groupedTransactions.containsKey('Today'), isTrue);
    });
    test('yesterday grouping', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final state = TransactionFilterState(
        transactions: [TransactionModel(id: '1', userId: 1, amount: 10, type: TransactionType.expense, category: 'Food', date: yesterday, title: 'T', lastUpdated: yesterday)],
        balance: -10, totalIncome: 0, totalExpense: 10,
      );
      expect(state.groupedTransactions.containsKey('Yesterday'), isTrue);
    });
  });
}
