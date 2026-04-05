import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_companion/l10n/app_localizations.dart';

import 'package:finance_companion/injection_container.dart' as di;
import 'package:finance_companion/injection_container.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/theme/theme_cubit.dart';
import 'package:finance_companion/logic/connectivity/connectivity_cubit.dart';
import 'package:finance_companion/logic/locale/locale_cubit.dart';
import 'package:finance_companion/logic/navigation/tab_navigation_cubit.dart';
import 'package:finance_companion/data/services/notification_service.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/core/navigation/app_router.dart';
import 'package:finance_companion/core/theme/app_theme.dart';
import 'package:finance_companion/presentation/screens/splash/splash_screen.dart';
import 'package:finance_companion/core/services/background_worker.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (DefaultFirebaseOptions.android.apiKey != 'REPLACE_ME') {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } else {
      debugPrint('Firebase: Running in Local Mode (Config uninitialized)');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e. Running in Local Mode.');
  }

  // Initialize Service Locator
  await di.init();
  
  // Initialize Background Worker
  await BackgroundWorker.initialize();

  // Initialize notifications — handles its own "No Firebase" logic
  await NotificationService.instance.initialize();
  
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  final bool isTestMode;

  const FinanceApp({
    this.isTestMode = false,
    super.key,
  });

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
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
        BlocProvider(create: (_) => AuthCubit(sl<AuthRepository>())),
        BlocProvider(create: (_) => ThemeCubit(sl<SharedPreferences>())),
        BlocProvider(create: (_) => LocaleCubit(sl<SharedPreferences>())),
        BlocProvider(create: (_) => ConnectivityCubit(connectivity: sl())),
        BlocProvider.value(value: _tabCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                navigatorKey: _navigatorKey,
                title: 'Finance Companion',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                  Locale('hi'),
                ],
                home: SplashScreen(
                  isTestMode: widget.isTestMode,
                  authRepo: sl<AuthRepository>(),
                  onFinished: () => AppRouter.toAuthWrapper(
                    context,
                    navigatorKey: _navigatorKey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
