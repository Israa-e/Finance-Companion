import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../logic/auth/auth_cubit.dart';
import '../../../../logic/auth/auth_state.dart';
import '../../../../logic/transaction/transaction_cubit.dart';
import '../../../../logic/transaction/transaction_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, txState) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final balance = txState is TransactionLoaded
                ? txState.balance
                : 0.0;
            final isLoading = txState is TransactionLoading;
            final userName = authState is AuthAuthenticated
                ? authState.user.name.split(' ').first
                : '';
            final income = txState is TransactionLoaded
                ? txState.totalIncome
                : 0.0;
            final expense = txState is TransactionLoaded
                ? txState.totalExpense
                : 0.0;

            return _AnimatedBalanceCard(
              shimmerController: _shimmerController,
              balance: balance,
              income: income,
              expense: expense,
              userName: userName,
              isLoading: isLoading,
            );
          },
        );
      },
    );
  }
}

class _AnimatedBalanceCard extends StatelessWidget {
  final AnimationController shimmerController;
  final double balance;
  final double income;
  final double expense;
  final String userName;
  final bool isLoading;

  const _AnimatedBalanceCard({
    required this.shimmerController,
    required this.balance,
    required this.income,
    required this.expense,
    required this.userName,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
                AppColors.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles (like the reference image)
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 50,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Moving shimmer line
              Positioned.fill(
                child: CustomPaint(
                  painter: _ShimmerPainter(shimmerController.value),
                ),
              ),
              // Card dots pattern (top right area)
              // Positioned(top: 16, right: 16, child: _CardChip()),
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    // Balance label
                    Text(
                      'Total Balance',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const Gap(12),
                    // Balance amount
                    isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          )
                        : TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: balance),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (_, val, _) => Text(
                              CurrencyFormatter.format(val),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                          ),
                    const Gap(24),
                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),
                    // Income / Expense row
                    Row(
                      children: [
                        Expanded(
                          child: _StatPill(
                            icon: Icons.arrow_downward_rounded,
                            label: 'Income',
                            value: CurrencyFormatter.formatCompact(income),
                            color: const Color(0xFF81F5AE),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _StatPill(
                            icon: Icons.arrow_upward_rounded,
                            label: 'Expenses',
                            value: CurrencyFormatter.formatCompact(expense),
                            color: const Color(0xFFFFB3B3),
                          ),
                        ),
                        const Gap(12),
                        // Mini donut chart
                        _MiniDonut(income: income, expense: expense),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  _ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final x = -size.width + (size.width * 2.5) * progress;
    canvas.save();
    canvas.translate(x, 0);
    canvas.skew(-0.3, 0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _MiniDonut extends StatelessWidget {
  final double income;
  final double expense;

  const _MiniDonut({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _DonutPainter(income: income, expense: expense),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double income;
  final double expense;

  _DonutPainter({required this.income, required this.expense});

  @override
  void paint(Canvas canvas, Size size) {
    final total = income + expense;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final incomePaint = Paint()
      ..color = const Color.fromARGB(255, 91, 82, 206)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final expensePaint = Paint()
      ..color = const Color.fromARGB(255, 233, 154, 154)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    if (total > 0) {
      final incomeSweep = (income / total) * 2 * math.pi;
      canvas.drawArc(rect, -math.pi / 2, incomeSweep, false, incomePaint);
      canvas.drawArc(
        rect,
        -math.pi / 2 + incomeSweep,
        2 * math.pi - incomeSweep,
        false,
        expensePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.income != income || old.expense != expense;
}
