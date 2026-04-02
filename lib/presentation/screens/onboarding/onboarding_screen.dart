import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

/// Call this in AuthWrapper before showing Login:
///   final seen = await OnboardingScreen.hasSeenOnboarding();
///   if (!seen) { /* show OnboardingScreen */ }
class OnboardingScreen extends StatefulWidget {
  /// Called when the user finishes or skips onboarding
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  static const String _prefKey = 'onboarding_complete';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _OnboardingPage {
  final String title;
  final String subtitle;
  final Color accent;
  final Widget illustration;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.illustration,
  });
}

// ─── State ────────────────────────────────────────────────────────────────────

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late final List<_OnboardingPage> _pages;

  // Per-page animation controllers
  late final List<AnimationController> _illustrationCtrls;
  late final List<Animation<double>> _illustrationAnims;

  @override
  void initState() {
    super.initState();

    _pages = [
      _OnboardingPage(
        title: 'Track Every\nPenny',
        subtitle:
            'Log income and expenses in seconds. Know exactly where your money goes every single day.',
        accent: const Color(0xFF6C63FF),
        illustration: const _IllustrationWallet(),
      ),
      _OnboardingPage(
        title: 'Smart\nInsights',
        subtitle:
            'Beautiful charts reveal your spending habits. Spot trends before they become problems.',
        accent: const Color(0xFF2DCE89),
        illustration: const _IllustrationChart(),
      ),
      _OnboardingPage(
        title: 'Reach Your\nGoals',
        subtitle:
            'Set savings goals, track progress, and celebrate every milestone on your path to financial freedom.',
        accent: const Color(0xFFFFBF00),
        illustration: const _IllustrationGoal(),
      ),
    ];

    _illustrationCtrls = List.generate(
      _pages.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      ),
    );

    _illustrationAnims = _illustrationCtrls.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.elasticOut);
    }).toList();

    // Animate first page in
    _illustrationCtrls[0].forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _illustrationCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _illustrationCtrls[index].forward(from: 0);
  }

  Future<void> _next() async {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingScreen.markSeen();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Animated background blob ──────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            top: -size.height * 0.12,
            right: _currentPage.isEven ? -60.0 : size.width * 0.1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accent.withValues(alpha: 0.09),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            bottom: -size.height * 0.08,
            left: _currentPage.isEven ? -40.0 : size.width * 0.15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accent.withValues(alpha: 0.06),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 12),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, i) {
                      return _PageContent(
                        page: _pages[i],
                        illustrationAnim: _illustrationAnims[i],
                      );
                    },
                  ),
                ),

                // Dots + Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                  child: Column(
                    children: [
                      _DotsIndicator(
                        count: _pages.length,
                        current: _currentPage,
                        activeColor: page.accent,
                      ),
                      const SizedBox(height: 28),
                      _NextButton(
                        isLast: isLast,
                        color: page.accent,
                        onTap: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page content ─────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  final Animation<double> illustrationAnim;

  const _PageContent({
    required this.page,
    required this.illustrationAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          ScaleTransition(
            scale: illustrationAnim,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: page.accent.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Center(child: page.illustration),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dots indicator ───────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : activeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Next button ──────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool isLast;
  final Color color;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLast,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              isLast ? 'Get Started 🚀' : 'Next',
              key: ValueKey(isLast),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Illustrations (CustomPainter) ────────────────────────────────────────────

/// Page 1 – Wallet with coins
class _IllustrationWallet extends StatelessWidget {
  const _IllustrationWallet();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: _WalletPainter());
  }
}

class _WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF6C63FF).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
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
    canvas.drawRRect(cardRect, whitePaint..color = Colors.white.withValues(alpha: 0.25));

    // Coin 1
    canvas.drawCircle(Offset(cx - 22, cy - 34), 14, whitePaint..color = const Color(0xFFFFBF00));
    canvas.drawCircle(Offset(cx - 22, cy - 34), 14, strokePaint..color = const Color(0xFFE6A800));
    // $ sign on coin
    final tp = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - 22 - tp.width / 2, cy - 34 - tp.height / 2));

    // Coin 2 (smaller, offset)
    canvas.drawCircle(Offset(cx + 30, cy - 42), 10,
        whitePaint..color = const Color(0xFFFFBF00).withValues(alpha: 0.7));

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

// ─── Page 2 – Bar chart with trend line ───────────────────────────────────────

class _IllustrationChart extends StatelessWidget {
  const _IllustrationChart();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: _ChartPainter());
  }
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
        Offset(cx - 44, cy + 34), Offset(cx + 44, cy + 34), axisPaint);
    canvas.drawLine(
        Offset(cx - 44, cy - 40), Offset(cx - 44, cy + 34), axisPaint);

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
      trendPoints.add(Offset(
        startX + i * 15.0 + barW / 2,
        cy + 34 - maxH * barData[i],
      ));
    }
    final path = Path()..moveTo(trendPoints.first.dx, trendPoints.first.dy);
    for (int i = 1; i < trendPoints.length; i++) {
      final prev = trendPoints[i - 1];
      final curr = trendPoints[i];
      path.cubicTo(
        prev.dx + 5, prev.dy,
        curr.dx - 5, curr.dy,
        curr.dx, curr.dy,
      );
    }
    canvas.drawPath(path, linePaint);

    // Dot on last point
    canvas.drawCircle(trendPoints.last, 5,
        Paint()..color = const Color(0xFFFFBF00));
    canvas.drawCircle(
        trendPoints.last, 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

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
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Page 3 – Goal / trophy ───────────────────────────────────────────────────

class _IllustrationGoal extends StatelessWidget {
  const _IllustrationGoal();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: _GoalPainter());
  }
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
    final purplePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokeW = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

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
          ..strokeCap = StrokeCap.round);

    final rightHandle = Path()
      ..moveTo(cx + 28, cy - 22)
      ..cubicTo(cx + 48, cy - 22, cx + 48, cy - 2, cx + 28, cy - 2);
    canvas.drawPath(
        rightHandle,
        Paint()
          ..color = yellowDarkPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);

    // Stem
    canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy + 30), width: 12, height: 14),
        yellowDarkPaint);

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + 40), width: 46, height: 10),
          const Radius.circular(5)),
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
            ..style = PaintingStyle.fill);
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