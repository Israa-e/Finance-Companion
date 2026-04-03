import 'dart:math' as math;
import 'package:flutter/material.dart';

class IllustrationWallet extends StatelessWidget {
  const IllustrationWallet({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: _WalletPainter());
  }
}

class IllustrationChart extends StatelessWidget {
  const IllustrationChart({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: _ChartPainter());
  }
}

class IllustrationGoal extends StatelessWidget {
  const IllustrationGoal({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: _GoalPainter());
  }
}

class _WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final mainPaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;
    final lightPaint = Paint()
      ..color = const Color(0xFF9B94FF)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Wallet body
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 86, height: 58),
      const Radius.circular(14),
    );
    canvas.drawRRect(walletRect, mainPaint);

    // Wallet flap
    final flapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 43, cy - 16, 86, 26),
      const Radius.circular(10),
    );
    canvas.drawRRect(flapRect, lightPaint);

    // Card slot
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 20, cy + 4), width: 30, height: 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      cardRect,
      whitePaint..color = Colors.white.withValues(alpha: 0.25),
    );

    // Coin 1
    canvas.drawCircle(
      Offset(cx - 22, cy - 34),
      14,
      whitePaint..color = const Color(0xFFFFBF00),
    );
    canvas.drawCircle(
      Offset(cx - 22, cy - 34),
      14,
      strokePaint..color = const Color(0xFFE6A800),
    );
    // $ sign on coin
    final tp = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - 22 - tp.width / 2, cy - 34 - tp.height / 2));

    // Coin 2 (smaller, offset)
    canvas.drawCircle(
      Offset(cx + 30, cy - 42),
      10,
      whitePaint..color = const Color(0xFFFFBF00).withValues(alpha: 0.7),
    );

    // Dots on wallet
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx - 18 + i * 12.0, cy + 10),
        2.5,
        whitePaint..color = Colors.white.withValues(alpha: 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final greenPaint = Paint()
      ..color = const Color(0xFF2DCE89)
      ..style = PaintingStyle.fill;
    final lightGreenPaint = Paint()
      ..color = const Color(0xFF2DCE89).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final purplePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFFFFBF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final axisPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Axes
    canvas.drawLine(
      Offset(cx - 44, cy + 34),
      Offset(cx + 44, cy + 34),
      axisPaint,
    );
    canvas.drawLine(
      Offset(cx - 44, cy - 40),
      Offset(cx - 44, cy + 34),
      axisPaint,
    );

    // Bars
    final barData = [0.4, 0.65, 0.5, 0.8, 0.55, 0.9];
    final barW = 10.0;
    final maxH = 60.0;
    final startX = cx - 38.0;

    for (int i = 0; i < barData.length; i++) {
      final h = maxH * barData[i];
      final x = startX + i * 15.0;
      final rect = Rect.fromLTWH(x, cy + 34 - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        i.isEven ? purplePaint : lightGreenPaint,
      );
    }

    // Trend line
    final trendPoints = <Offset>[];
    for (int i = 0; i < barData.length; i++) {
      trendPoints.add(
        Offset(startX + i * 15.0 + barW / 2, cy + 34 - maxH * barData[i]),
      );
    }
    final path = Path()..moveTo(trendPoints.first.dx, trendPoints.first.dy);
    for (int i = 1; i < trendPoints.length; i++) {
      final prev = trendPoints[i - 1];
      final curr = trendPoints[i];
      path.cubicTo(
        prev.dx + 5,
        prev.dy,
        curr.dx - 5,
        curr.dy,
        curr.dx,
        curr.dy,
      );
    }
    canvas.drawPath(path, linePaint);

    // Dot on last point
    canvas.drawCircle(
      trendPoints.last,
      5,
      Paint()..color = const Color(0xFFFFBF00),
    );
    canvas.drawCircle(
      trendPoints.last,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Up arrow badge
    final badgeCenter = Offset(cx + 28, cy - 44);
    canvas.drawCircle(badgeCenter, 14, greenPaint);
    final arrowPath = Path()
      ..moveTo(badgeCenter.dx, badgeCenter.dy + 6)
      ..lineTo(badgeCenter.dx, badgeCenter.dy - 6)
      ..moveTo(badgeCenter.dx - 5, badgeCenter.dy - 1)
      ..lineTo(badgeCenter.dx, badgeCenter.dy - 6)
      ..lineTo(badgeCenter.dx + 5, badgeCenter.dy - 1);
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFBF00)
      ..style = PaintingStyle.fill;
    final yellowDarkPaint = Paint()
      ..color = const Color(0xFFE6A800)
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Trophy cup body
    final cupPath = Path()
      ..moveTo(cx - 28, cy - 30)
      ..cubicTo(cx - 28, cy + 10, cx - 10, cy + 22, cx, cy + 22)
      ..cubicTo(cx + 10, cy + 22, cx + 28, cy + 10, cx + 28, cy - 30)
      ..close();
    canvas.drawPath(cupPath, yellowPaint);

    // Cup handles
    final leftHandle = Path()
      ..moveTo(cx - 28, cy - 22)
      ..cubicTo(cx - 48, cy - 22, cx - 48, cy - 2, cx - 28, cy - 2);
    canvas.drawPath(
      leftHandle,
      Paint()
        ..color = yellowDarkPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    final rightHandle = Path()
      ..moveTo(cx + 28, cy - 22)
      ..cubicTo(cx + 48, cy - 22, cx + 48, cy - 2, cx + 28, cy - 2);
    canvas.drawPath(
      rightHandle,
      Paint()
        ..color = yellowDarkPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Stem
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 30), width: 12, height: 14),
      yellowDarkPaint,
    );

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 40), width: 46, height: 10),
        const Radius.circular(5),
      ),
      yellowDarkPaint,
    );

    // Star on cup
    _drawStar(canvas, Offset(cx, cy - 4), 14, whitePaint);

    // Confetti dots
    final confettiColors = [
      const Color(0xFF6C63FF),
      const Color(0xFF2DCE89),
      const Color(0xFFFF5B5B),
    ];
    final confettiPositions = [
      Offset(cx - 44, cy - 38),
      Offset(cx + 40, cy - 44),
      Offset(cx - 36, cy - 10),
      Offset(cx + 44, cy - 16),
      Offset(cx - 50, cy + 4),
      Offset(cx + 36, cy + 8),
    ];
    for (int i = 0; i < confettiPositions.length; i++) {
      canvas.drawCircle(
        confettiPositions[i],
        5,
        Paint()
          ..color = confettiColors[i % confettiColors.length]
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = outerAngle + math.pi / 5;
      final outerPoint = Offset(
        center.dx + radius * math.cos(outerAngle),
        center.dy + radius * math.sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + radius * 0.4 * math.cos(innerAngle),
        center.dy + radius * 0.4 * math.sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
