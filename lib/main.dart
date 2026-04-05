import 'dart:async';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/auth/auth_state.dart';
import 'package:finance_companion/logic/theme/theme_cubit.dart';
import 'package:finance_companion/presentation/screens/splash/splash_screen.dart';
import 'package:finance_companion/presentation/shared/navigation/auth_wrapper.dart';
import 'package:finance_companion/logic/connectivity/connectivity_cubit.dart';
import 'package:finance_companion/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:finance_companion/logic/navigation/tab_navigation_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
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
  late final StreamSubscription<String> _notificationSubscription;
  final _tabCubit = TabNavigationCubit();

  @override
  void initState() {
    super.initState();
    _notificationSubscription = NotificationService.instance.selectNotificationStream.listen((payload) {
      _tabCubit.navigateByPayload(payload);
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider(create: (_) => ThemeCubit(widget.prefs)),
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider.value(value: _tabCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        // Navigate back to a fresh SplashScreen whenever the user logs out.
        // This ensures the splash animation replays and biometric re-prompts on
        // the next login — instead of dumping the user directly to LoginScreen.
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            _navigatorKey.currentState?.pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => SplashScreen(
                  onFinished: () {
                    _navigatorKey.currentState?.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<AuthCubit>()),
                            BlocProvider.value(value: context.read<ThemeCubit>()),
                            BlocProvider.value(value: context.read<ConnectivityCubit>()),
                            BlocProvider.value(value: _tabCubit),
                          ],
                          child: AuthWrapper(
                            transactionRepo: _transactionRepo,
                            goalRepo: _goalRepo,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
              (_) => false, // remove all previous routes
            );
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'Finance Companion',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
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
                            BlocProvider.value(
                              value: context.read<ConnectivityCubit>(),
                            ),
                            BlocProvider.value(
                              value: _tabCubit,
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
      ),
    );
  }
}
