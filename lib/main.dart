import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/presentation/shared/navigation/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/goal_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FinanceApp());
}

class FinanceApp extends StatelessWidget {
  final transactionRepo = TransactionRepository();
  final goalRepo = GoalRepository();

  FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRepository()),
      child: MaterialApp(
        title: 'Finance Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AuthWrapper(
          transactionRepo: TransactionRepository(),
          goalRepo: GoalRepository(),
        ),
      ),
    );
  }
}
