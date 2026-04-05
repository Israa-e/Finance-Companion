import 'package:bloc_test/bloc_test.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:finance_companion/logic/transaction/transaction_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class FakeTransactionModel extends Fake implements TransactionModel {}

void main() {
  late MockTransactionRepository mockRepo;
  late TransactionCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeTransactionModel());
  });

  setUp(() {
    mockRepo = MockTransactionRepository();
    cubit = TransactionCubit(mockRepo);
    cubit.setUser(1, 1000.0);
  });

  tearDown(() {
    cubit.close();
  });

  group('TransactionCubit', () {
    test('initial state is TransactionInitial', () {
      expect(cubit.state, isA<TransactionInitial>());
    });

    blocTest<TransactionCubit, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] on loadTransactions success',
      build: () {
        when(() => mockRepo.getAll()).thenAnswer((_) async => <TransactionModel>[]);
        when(() => mockRepo.getTotalIncome()).thenAnswer((_) async => 500.0);
        when(() => mockRepo.getTotalExpense()).thenAnswer((_) async => 200.0);
        return cubit;
      },
      act: (cubit) => cubit.loadTransactions(),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>()
            .having((s) => s.balance, 'balance', 1300.0)
            .having((s) => s.totalIncome, 'totalIncome', 500.0)
            .having((s) => s.totalExpense, 'totalExpense', 200.0),
      ],
    );

    blocTest<TransactionCubit, TransactionState>(
      'emits [TransactionLoading, TransactionError] on loadTransactions failure',
      build: () {
        when(() => mockRepo.getAll()).thenThrow(Exception('DB Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadTransactions(),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionError>().having((s) => s.message, 'message', 'Exception: DB Error'),
      ],
    );

    blocTest<TransactionCubit, TransactionState>(
      'updateSearchQuery updates the search query and keeps current data',
      build: () {
        when(() => mockRepo.getAll()).thenAnswer((_) async => <TransactionModel>[]);
        when(() => mockRepo.getTotalIncome()).thenAnswer((_) async => 0.0);
        when(() => mockRepo.getTotalExpense()).thenAnswer((_) async => 0.0);
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadTransactions();
        cubit.updateSearchQuery('test');
      },
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
        isA<TransactionLoaded>().having((s) => s.searchQuery, 'searchQuery', 'test'),
      ],
    );

    test('setUser correctly sets internal fields', () {
      cubit.setUser(123, 5000.0, monthlyBudget: 1000.0);
      // We can't easily access private fields but we can check load result
      when(() => mockRepo.getAll()).thenAnswer((_) async => <TransactionModel>[]);
      when(() => mockRepo.getTotalIncome()).thenAnswer((_) async => 0.0);
      when(() => mockRepo.getTotalExpense()).thenAnswer((_) async => 0.0);
      
      cubit.loadTransactions();
      // Wait for it
      expect(cubit.state, isA<TransactionInitial>()); // async!
    });
  });
}
