import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashParticlesLayer extends StatelessWidget {
  final Size size;
  final Animation<double> bgScale;
  final AnimationController floatController;

  const SplashParticlesLayer({
    super.key,
    required this.size,
    required this.bgScale,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'pos': [0.1, 0.2], 'emoji': '💰', 'size': 24.0, 'delay': 0.0},
      {'pos': [0.85, 0.15], 'emoji': '✨', 'size': 20.0, 'delay': 0.2},
      {'pos': [0.75, 0.75], 'emoji': '💎', 'size': 22.0, 'delay': 0.4},
      {'pos': [0.15, 0.8], 'emoji': '🌿', 'size': 18.0, 'delay': 0.1},
      {'pos': [0.5, 0.08], 'emoji': '⭐', 'size': 20.0, 'delay': 0.3},
      {'pos': [0.9, 0.6], 'emoji': '📈', 'size': 22.0, 'delay': 0.5},
      {'pos': [0.08, 0.5], 'emoji': '💵', 'size': 20.0, 'delay': 0.2},
      {'pos': [0.8, 0.9], 'emoji': '🪙', 'size': 18.0, 'delay': 0.4},
      {'pos': [0.2, 0.05], 'emoji': '⚡', 'size': 16.0, 'delay': 0.1},
      {'pos': [0.65, 0.12], 'emoji': '📊', 'size': 18.0, 'delay': 0.3},
      {'pos': [0.35, 0.92], 'emoji': '💳', 'size': 20.0, 'delay': 0.6},
      {'pos': [0.55, 0.82], 'emoji': '🏦', 'size': 22.0, 'delay': 0.7},
    ];

    return Stack(
      children: List.generate(items.length, (i) {
        final item = items[i];
        final pos = item['pos'] as List<double>;
        final delay = item['delay'] as double;

        return Positioned(
          left: pos[0] * size.width,
          top: pos[1] * size.height,
          child: FadeTransition(
            opacity: bgScale,
            child: ScaleTransition(
              scale: bgScale,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (context, child) {
                  final offset = math.sin(
                        (floatController.value * 2 * math.pi) + (delay * 10),
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
      }),
    );
  }
}
