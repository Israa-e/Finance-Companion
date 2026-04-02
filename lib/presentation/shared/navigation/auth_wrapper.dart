import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
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
  bool _checkingOnboarding = true;
  bool _showOnboarding = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final seen = await OnboardingScreen.hasSeenOnboarding();
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
    // Still loading prefs or checking initial auth
    if (_checkingOnboarding || _isCheckingAuth) {
      return const _SplashScreen();
    }

    // Show onboarding first
    if (_showOnboarding) {
      return OnboardingScreen(onDone: _onOnboardingDone);
    }

    // Normal auth flow
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return AppNavigation(
            transactionRepo: widget.transactionRepo,
            goalRepo: widget.goalRepo,
            user: state.user,
          );
        }
        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Finance Companion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
