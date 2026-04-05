import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_companion/injection_container.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/theme/theme_cubit.dart';
import 'package:finance_companion/logic/connectivity/connectivity_cubit.dart';
import 'package:finance_companion/logic/navigation/tab_navigation_cubit.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/presentation/screens/splash/splash_screen.dart';
import 'package:finance_companion/presentation/shared/navigation/auth_wrapper.dart';

class AppRouter {
  static void toAuthWrapper(
    BuildContext context, {
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthCubit>()),
            BlocProvider.value(value: context.read<ThemeCubit>()),
            BlocProvider.value(value: context.read<ConnectivityCubit>()),
            BlocProvider.value(value: context.read<TabNavigationCubit>()),
          ],
          child: const AuthWrapper(),
        ),
      ),
    );
  }

  static void toSplash(
    BuildContext context, {
    required GlobalKey<NavigatorState> navigatorKey,
    bool isTestMode = false,
  }) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (ctx, _, __) => SplashScreen(
          isTestMode: isTestMode,
          authRepo: sl<AuthRepository>(),
          onFinished: () => toAuthWrapper(
            ctx,
            navigatorKey: navigatorKey,
          ),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (_) => false,
    );
  }
}
