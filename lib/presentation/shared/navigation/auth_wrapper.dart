import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/auth/auth_state.dart';
import 'package:finance_companion/logic/onboarding/onboarding_cubit.dart';
import 'package:finance_companion/presentation/screens/auth/login_screen.dart';
import 'package:finance_companion/presentation/screens/onboarding/onboarding_screen.dart';
import 'app_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checkingOnboarding = true;
  bool _showOnboarding = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final seen = await OnboardingCubit.hasSeenOnboarding();
    if (!mounted) return;
    setState(() {
      _showOnboarding = !seen;
      _checkingOnboarding = false;
    });
    if (!_showOnboarding) {
      // Already seen onboarding — check auth session
      await context.read<AuthCubit>().checkAuth();
      if (mounted) {
        setState(() => _isCheckingAuth = false);
      }
    } else {
      setState(() => _isCheckingAuth = false);
    }
  }

  void _onOnboardingDone() async {
    setState(() {
      _showOnboarding = false;
      _isCheckingAuth = true;
    });
    await context.read<AuthCubit>().checkAuth();
    if (mounted) {
      setState(() => _isCheckingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingOnboarding || _isCheckingAuth) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_showOnboarding) {
      return OnboardingScreen(onDone: _onOnboardingDone);
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return AppNavigation(
            user: state.user,
          );
        }
        return const LoginScreen();
      },
    );
  }
}
