import 'package:finance_companion/logic/streak/streak_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/streak_model.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        if (state is StreakLoading || state is StreakInitial) {
          return const _StreakSkeleton();
        }

        if (state is! StreakLoaded) return const SizedBox.shrink();

        final StreakModel streak =
            state.streak; // FIX: explicit type annotation

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: streak.currentStreak >= 7
                  ? [const Color(0xFFFF9F0A), const Color(0xFFFF6B00)]
                  : streak.currentStreak >= 1
                      ? [AppColors.income, const Color(0xFF00B86B)]
                      : [
                          AppColors.primary.withValues(alpha: 0.8),
                          AppColors.primaryDark,
                        ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    streak.streakEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No-Spend Streak',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          streak.streakMessage,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Current streak badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${streak.currentStreak}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          streak.currentStreak == 1 ? 'day' : 'days',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // ── 7-day mini calendar ─────────────────────────────────
              _SevenDayDots(streak: streak),

              const Gap(14),

              // ── Confirm no-spend button (FIX: manual confirmation) ──
              if (!streak.todayConfirmed)
                GestureDetector(
                  onTap: () =>
                      context.read<StreakCubit>().confirmTodayNoSpend(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const Gap(8),
                        Text(
                          'Confirm no-spend today',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),
                      const Gap(6),
                      Text(
                        'Personal best: ${streak.longestStreak} day${streak.longestStreak == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

// ── Seven-day dot row (FIX: explicit StreakModel type) ────────────────────────

class _SevenDayDots extends StatelessWidget {
  final StreakModel streak; // FIX: was `final streak` (untyped)

  const _SevenDayDots({required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i));
        final isNoSpend = streak.noSpendDays.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );
        final isConfirmed = streak.confirmedDays.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );
        final isToday = i == 6;

        return Column(
          children: [
            Text(
              days[day.weekday - 1],
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNoSpend
                    ? Colors.white.withValues(alpha: isToday ? 1.0 : 0.85)
                    : Colors.white.withValues(alpha: 0.15),
                border:
                    isToday ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: Center(
                child: isNoSpend
                    ? Text(
                        isConfirmed ? '★' : '✓',
                        style: TextStyle(
                          fontSize: 11,
                          color: isConfirmed
                              ? const Color(0xFFFF9F0A)
                              : const Color(0xFF00B86B),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Text(
                        '•',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _StreakSkeleton extends StatefulWidget {
  const _StreakSkeleton();

  @override
  State<_StreakSkeleton> createState() => _StreakSkeletonState();
}

class _StreakSkeletonState extends State<_StreakSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.05 + 0.08 * _anim.value;
        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}
