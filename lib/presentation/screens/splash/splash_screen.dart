import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/splash/splash_cubit.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'widgets/splash_bg_blobs.dart';
import 'widgets/splash_branding.dart';
import 'widgets/splash_loading_dots.dart';
import 'widgets/splash_particles_layer.dart';

import 'package:finance_companion/logic/splash/splash_state.dart';

class SplashScreen extends StatefulWidget {
  /// Called when the animation finishes — navigate to the next screen here.
  final VoidCallback onFinished;

  final bool isTestMode;
  final AuthRepository authRepo;

  const SplashScreen({
    super.key,
    required this.onFinished,
    required this.authRepo,
    this.isTestMode = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashCubit _cubit;
  bool _isSequenceStarted = false;

  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _exitController;
  late final AnimationController _floatController;

  late final Animation<double> _bgScale;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _exitFade;
  late final Animation<double> _ringExpand;

  @override
  void initState() {
    super.initState();
    _cubit = SplashCubit(widget.authRepo);

    // Start sequence after first frame to ensure listener is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.startSequence();
    });

    // Status bar icon brightness will be handled in build based on theme

    // Background blob pulse
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgScale = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeOutCubic,
    );

    // Logo pop-in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

    // Ring expand
    _ringExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Text slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Exit fade
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    // Floating animation for particles
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (!widget.isTestMode) {
      _floatController.repeat(reverse: true);
    }
  }

  void _updateStatusBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  void _runUiSequence() {
    if (_isSequenceStarted) return;
    _isSequenceStarted = true;

    _bgController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });
  }

  Future<void> _exitSequence() async {
    await _exitController.forward();
    widget.onFinished();
  }

  @override
  void dispose() {
    _cubit.close();
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _exitController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateStatusBar(context);
    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.animating) {
            _runUiSequence();
          } else if (state.status == SplashStatus.completed) {
            _exitSequence();
          }
        },
        builder: (context, state) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              _bgController,
              _logoController,
              _textController,
              _exitController,
              _floatController,
            ]),
            builder: (context, _) {
              return FadeTransition(
                opacity: _exitFade,
                child: Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  body: Stack(
                    children: [
                      // ── Background Blobs ──────────────────────────────────────────
                      SplashBgBlobs(size: size, bgAnimation: _bgScale),

                      // ── Floating Particles ────────────────────────────────────────
                      SplashParticlesLayer(
                        size: size,
                        bgScale: _bgScale,
                        floatController: _floatController,
                      ),

                      // ── Logo + App Branding ───────────────────────────────────────
                      Center(
                        child: SplashBranding(
                          logoScale: _logoScale,
                          logoFade: _logoFade,
                          ringExpand: _ringExpand,
                          textFade: _textFade,
                          textSlide: _textSlide,
                        ),
                      ),

                      // ── Bottom Loading Dots ───────────────────────────────────────
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: SplashLoadingDots(isTestMode: widget.isTestMode),
                        ),
                      ),
                    ],
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
