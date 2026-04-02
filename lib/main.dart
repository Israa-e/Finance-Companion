import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/theme/theme_cubit.dart';
import 'package:finance_companion/presentation/shared/navigation/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(FinanceApp(prefs: prefs));
}

class FinanceApp extends StatelessWidget {
  final SharedPreferences prefs;
  final transactionRepo = TransactionRepository();
  final goalRepo = GoalRepository();

  FinanceApp({required this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider(create: (_) => ThemeCubit(prefs)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Finance Companion',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: AuthWrapper(
              transactionRepo: TransactionRepository(),
              goalRepo: GoalRepository(),
            ),
          );
        },
      ),
    );
  }
}
