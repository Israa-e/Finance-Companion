import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../screens/auth/login_screen.dart';
import 'app_navigation.dart';

class AuthWrapper extends StatefulWidget {
  final TransactionRepository transactionRepo;
  final GoalRepository goalRepo;

  const AuthWrapper({
    super.key,
    required this.transactionRepo,
    required this.goalRepo,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return AppNavigation(
            transactionRepo: widget.transactionRepo,
            goalRepo: widget.goalRepo,
          );
        }
        return const LoginScreen();
      },
    );
  }
}