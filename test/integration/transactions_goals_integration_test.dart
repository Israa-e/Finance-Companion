import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finance_companion/logic/transaction/transaction_cubit.dart';
import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:finance_companion/data/repositories/goal_repository.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:finance_companion/logic/goal/goal_state.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  late TransactionCubit transactionCubit;
  late GoalCubit goalCubit;
  late MockTransactionRepository mockTransactionRepo;
  late MockGoalRepository mockGoalRepo;

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockGoalRepo = MockGoalRepository();
    
    transactionCubit = TransactionCubit(mockTransactionRepo);
    goalCubit = GoalCubit(mockGoalRepo, mockTransactionRepo);

    registerFallbackValue(TransactionModel(
      id: 'dummy',
      userId: 0,
      amount: 0,
      type: TransactionType.income,
      category: 'Other',
      date: DateTime.now(),
      title: 'Dummy',
      lastUpdated: DateTime.now(),
    ));
  });

  test('Adding an expense correctly impacts available balance for goals', () async {
    // 1. Arrange: Initial state with 1000 balance
    final initialTx = TransactionModel(
      id: '1',
      userId: 0,
      amount: 1000,
      type: TransactionType.income,
      category: 'Salary',
      date: DateTime.now(),
      title: 'Initial',
      lastUpdated: DateTime.now(),
    );

    when(() => mockTransactionRepo.getAll()).thenAnswer((_) async => [initialTx]);
    when(() => mockTransactionRepo.getTotalIncome()).thenAnswer((_) async => 1000.0);
    when(() => mockTransactionRepo.getTotalExpense()).thenAnswer((_) async => 0.0);
    when(() => mockGoalRepo.getAll(any())).thenAnswer((_) async => []);
    when(() => mockGoalRepo.getActive(any())).thenAnswer((_) async => []);

    await transactionCubit.loadTransactions();
    await goalCubit.loadGoals();

    expect((transactionCubit.state as TransactionLoaded).balance, 1000.0);

    // 2. Act: Add an expense of 400
    final expense = TransactionModel(
      id: '2',
      userId: 1,
      amount: 400,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now(),
      title: 'Lunch',
      lastUpdated: DateTime.now(),
    );

    when(() => mockTransactionRepo.add(any())).thenAnswer((_) async {});
    // Re-mock getAll to return both
    when(() => mockTransactionRepo.getAll()).thenAnswer((_) async => [initialTx, expense]);
    when(() => mockTransactionRepo.getTotalExpense()).thenAnswer((_) async => 400.0);

    await transactionCubit.addTransaction(
      amount: 400,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now(),
      title: 'Lunch',
    );

    // 3. Assert: Transaction balance is 600
    expect((transactionCubit.state as TransactionLoaded).balance, 600.0);

    // 4. Act: Check goal available balance
    // In our UI logic, availableBalance = totalBalance - sum(savedAmount)
    final txState = transactionCubit.state as TransactionLoaded;
    final totalBalance = txState.balance;
    
    final goalState = goalCubit.state as GoalLoaded;
    final lockedAmount = goalState.goals.fold(0.0, (sum, g) => sum + g.savedAmount);
    
    final available = totalBalance - lockedAmount;
    
    expect(available, 600.0);
    expect(available, isNot(1000.0));
  });

  test('Over-spending: Available balance becomes negative if expenses exceed income - locked', () async {
    // 1. Arrange: 500 income
    final income = TransactionModel(
      id: '1', userId: 0, amount: 500, type: TransactionType.income,
      category: 'Salary', date: DateTime.now(), title: 'Pay', lastUpdated: DateTime.now(),
    );
    when(() => mockTransactionRepo.getAll()).thenAnswer((_) async => [income]);
    when(() => mockTransactionRepo.getTotalIncome()).thenAnswer((_) async => 500.0);
    when(() => mockTransactionRepo.getTotalExpense()).thenAnswer((_) async => 0.0);
    when(() => mockGoalRepo.getAll(any())).thenAnswer((_) async => []);
    when(() => mockGoalRepo.getActive(any())).thenAnswer((_) async => []);

    await transactionCubit.loadTransactions();
    await goalCubit.loadGoals();

    // 2. Act: Add heavy expense of 600
    final expense = TransactionModel(
      id: '2', userId: 1, amount: 600, type: TransactionType.expense,
      category: 'Rent', date: DateTime.now(), title: 'Rent', lastUpdated: DateTime.now(),
    );
    when(() => mockTransactionRepo.getAll()).thenAnswer((_) async => [income, expense]);
    when(() => mockTransactionRepo.getTotalExpense()).thenAnswer((_) async => 600.0);

    await transactionCubit.addTransaction(
      amount: 600, type: TransactionType.expense, category: 'Rent',
      date: DateTime.now(), title: 'Rent',
    );

    // 3. Assert: Available balance is negative 100
    final totalBalance = (transactionCubit.state as TransactionLoaded).balance;
    final lockedAmount = (goalCubit.state as GoalLoaded).goals.fold(0.0, (sum, g) => sum + g.savedAmount);
    
    expect(totalBalance, -100.0);
    expect(totalBalance - lockedAmount, -100.0);
  });
}
