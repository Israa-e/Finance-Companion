import 'dart:math' as math;
import 'package:finance_companion/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standalone splash screen shown once on app cold start.
/// Call [SplashScreen] as the initial route in [main.dart],
/// then navigate to [AuthWrapper] after [onFinished] fires.
class SplashScreen extends StatefulWidget {
  /// Called when the animation finishes — navigate to the next screen here.
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

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
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
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
    )..repeat(reverse: true);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bgController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Hold for a longer moment so splash feels a bit longer
    await Future.delayed(const Duration(milliseconds: 1800));

    // Exit
    await _exitController.forward();
    widget.onFinished();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _exitController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _bgController,
        _logoController,
        _textController,
        _exitController,
      ]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _exitFade,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                _buildBlob(
                  size,
                  top: -size.height * 0.08,
                  left: -size.width * 0.15,
                  diameter: size.width * 0.8,
                  color: AppColors.primaryLight,
                  opacity: 0.18 * _bgScale.value,
                ),
                _buildBlob(
                  size,
                  bottom: -size.height * 0.18,
                  right: -size.width * 0.2,
                  diameter: size.width * 0.7,
                  color: AppColors.primary,
                  opacity: 0.23 * _bgScale.value,
                ),
                ..._buildParticles(size),

                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with expanding ring
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Transform.scale(
                              scale: 0.6 + 0.4 * _ringExpand.value,
                              child: Opacity(
                                opacity: _ringExpand.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Inner ring
                            Transform.scale(
                              scale: 0.7 + 0.3 * _ringExpand.value,
                              child: Opacity(
                                opacity: _ringExpand.value * 0.5,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                ),
                              ),
                            ),
                            // Logo icon
                            ScaleTransition(
                              scale: _logoScale,
                              child: FadeTransition(
                                opacity: _logoFade,
                                child: Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AppColors.primary,
                                    size: 42,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App name + tagline
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              const Text(
                                'Finance Companion',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Smart money, better life',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom loader dots
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const _LoadingDots(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlob(
    Size size, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double diameter,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    final items = [
      {
        'pos': [0.1, 0.2],
        'emoji': '💰',
        'size': 24.0,
        'delay': 0.0,
      },
      {
        'pos': [0.85, 0.15],
        'emoji': '✨',
        'size': 20.0,
        'delay': 0.2,
      },
      {
        'pos': [0.75, 0.75],
        'emoji': '💎',
        'size': 22.0,
        'delay': 0.4,
      },
      {
        'pos': [0.15, 0.8],
        'emoji': '🌿',
        'size': 18.0,
        'delay': 0.1,
      },
      {
        'pos': [0.5, 0.08],
        'emoji': '⭐',
        'size': 20.0,
        'delay': 0.3,
      },
      {
        'pos': [0.9, 0.6],
        'emoji': '📈',
        'size': 22.0,
        'delay': 0.5,
      },
      {
        'pos': [0.08, 0.5],
        'emoji': '💵',
        'size': 20.0,
        'delay': 0.2,
      },
      {
        'pos': [0.8, 0.9],
        'emoji': '🪙',
        'size': 18.0,
        'delay': 0.4,
      },
      {
        'pos': [0.2, 0.05],
        'emoji': '⚡',
        'size': 16.0,
        'delay': 0.1,
      },
      {
        'pos': [0.65, 0.12],
        'emoji': '📊',
        'size': 18.0,
        'delay': 0.3,
      },
      {
        'pos': [0.35, 0.92],
        'emoji': '💳',
        'size': 20.0,
        'delay': 0.6,
      },
      {
        'pos': [0.55, 0.82],
        'emoji': '🏦',
        'size': 22.0,
        'delay': 0.7,
      },
    ];

    return List.generate(items.length, (i) {
      final item = items[i];
      final pos = item['pos'] as List<double>;
      final delay = item['delay'] as double;

      return Positioned(
        left: pos[0] * size.width,
        top: pos[1] * size.height,
        child: FadeTransition(
          opacity: _bgScale,
          child: ScaleTransition(
            scale: _bgScale,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                // Individualized offset using sine wave with phase shift
                final offset =
                    math.sin(
                      (_floatController.value * 2 * math.pi) + (delay * 10),
                    ) *
                    8;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Text(
                    item['emoji'] as String,
                    style: TextStyle(fontSize: item['size'] as double),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (((_ctrl.value - delay) % 1.0 + 1.0) % 1.0);
            final opacity = math.sin(t * math.pi).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
