import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/theme/theme_cubit.dart';
import 'package:finance_companion/presentation/screens/splash/splash_screen.dart';
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

class FinanceApp extends StatefulWidget {
  final SharedPreferences prefs;

  const FinanceApp({required this.prefs, super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _transactionRepo = TransactionRepository();
  final _goalRepo = GoalRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider(create: (_) => ThemeCubit(widget.prefs)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Finance Companion',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: SplashScreen(
              onFinished: () {
                final nav = _navigatorKey.currentState;
                if (nav != null) {
                  nav.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                            value: context.read<AuthCubit>(),
                          ),
                          BlocProvider.value(
                            value: context.read<ThemeCubit>(),
                          ),
                        ],
                        child: AuthWrapper(
                          transactionRepo: _transactionRepo,
                          goalRepo: _goalRepo,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
