import 'package:finance_companion/data/models/user_model.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/auth/auth_state.dart';
import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/logic/goal/goal_state.dart';
import 'package:finance_companion/logic/transaction/transaction_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_state.dart';
import 'package:finance_companion/presentation/screens/home/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockAuthCubit extends Mock implements AuthCubit {}
class MockGoalCubit extends Mock implements GoalCubit {}
class MockTransactionCubit extends Mock implements TransactionCubit {}

void main() {
  late MockAuthCubit mockAuth;
  late MockGoalCubit mockGoal;
  late MockTransactionCubit mockTx;

  setUp(() {
    mockAuth = MockAuthCubit();
    mockGoal = MockGoalCubit();
    mockTx = MockTransactionCubit();

    when(() => mockAuth.state).thenReturn(AuthAuthenticated(
      user: UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        passwordHash: 'hash',
        initialBalance: 1000.0,
        createdAt: DateTime.now(),
      ),
    ));

    when(() => mockGoal.state).thenReturn(const GoalLoaded(
      goals: [],
      activeGoals: [],
    ));

    when(() => mockTx.state).thenReturn(TransactionLoaded(
      transactions: const [],
      balance: 1000.0,
      totalIncome: 1200.0,
      totalExpense: 200.0,
      initialBalance: 1000.0,
      formDate: DateTime.now(),
    ));
  });

  testWidgets('BalanceCard Golden Test', (tester) async {
    // Provide a consistent surface size for the golden test
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: mockAuth),
              BlocProvider<GoalCubit>.value(value: mockGoal),
              BlocProvider<TransactionCubit>.value(value: mockTx),
            ],
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: BalanceCard(),
              ),
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    
    // Pump some time for animations to settle at a specific frame if needed,
    // but typically for goldens we want a static state.
    // Since BalanceCard used TweenAnimationBuilder, we settle it.
    await tester.pumpAndSettle();

    // Verify visual appearance
    await expectLater(
      find.byType(BalanceCard),
      matchesGoldenFile('goldens/balance_card.png'),
    );
    
    // Reset view settings
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
