import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashLoadingDots extends StatefulWidget {
  final bool isTestMode;
  const SplashLoadingDots({super.key, this.isTestMode = false});

  @override
  State<SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (!widget.isTestMode) {
      _ctrl.repeat();
    }
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
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (((_ctrl.value - delay) % 1.0 + 1.0) % 1.0);
            final opacity = math.sin(t * math.pi).clamp(0.3, 1.0);
            return Transform.rotate(
              angle: 45 * math.pi / 180,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    if (opacity > 0.7)
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3 * opacity),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
