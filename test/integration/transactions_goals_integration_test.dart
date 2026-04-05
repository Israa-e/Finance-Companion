import 'package:finance_companion/data/repositories/transaction_view_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finance_companion/logic/transaction/transaction_action_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_filter_cubit.dart';
import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:finance_companion/data/repositories/goal_repository.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/logic/goal/goal_state.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockGoalRepository extends Mock implements GoalRepository {}
class MockTransactionViewRepository extends Mock implements TransactionViewRepository {}

void main() {
  late TransactionActionCubit actionCubit;
  late TransactionFilterCubit filterCubit;
  late GoalCubit goalCubit;
  late MockTransactionRepository mockTransactionRepo;
  late MockGoalRepository mockGoalRepo;
  late MockTransactionViewRepository mockViewRepo;

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockGoalRepo = MockGoalRepository();
    mockViewRepo = MockTransactionViewRepository();
    
    actionCubit = TransactionActionCubit(mockTransactionRepo);
    filterCubit = TransactionFilterCubit(mockTransactionRepo, mockViewRepo);
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
    final initialTx = TransactionModel(
      id: '1', userId: 0, amount: 1000, type: TransactionType.income,
      category: 'Salary', date: DateTime.now(), title: 'Initial', lastUpdated: DateTime.now(),
    );

    when(() => mockTransactionRepo.getAll()).thenAnswer((_) async => [initialTx]);
    when(() => mockViewRepo.getAll(any())).thenAnswer((_) async => []);
    when(() => mockGoalRepo.getAll(any())).thenAnswer((_) async => []);
    when(() => mockGoalRepo.getActive(any())).thenAnswer((_) async => []);

    await filterCubit.load();
    await goalCubit.loadGoals();

    expect(filterCubit.state.balance, 1000.0);
    expect(goalCubit.state, isA<GoalLoaded>());

    final expense = TransactionModel(
      id: '2', userId: 1, amount: 400, type: TransactionType.expense,
      category: 'Food', date: DateTime.now(), title: 'Lunch', lastUpdated: DateTime.now(),
    );

    when(() => mockTransactionRepo.add(any())).thenAnswer((_) async {});
    when(() => mockTransactionRepo.getAll()).thenAnswer((_) async => [initialTx, expense]);

    await actionCubit.addTransaction(expense);
    await filterCubit.load(); // Refresh filter after action

    expect(filterCubit.state.balance, 600.0);

    final totalBalance = filterCubit.state.balance;
    final goalState = goalCubit.state as GoalLoaded;
    final lockedAmount = goalState.goals.fold(0.0, (sum, g) => sum + g.savedAmount);
    
    expect(totalBalance - lockedAmount, 600.0);
  });
}
