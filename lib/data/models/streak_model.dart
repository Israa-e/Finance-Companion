import 'package:equatable/equatable.dart';

class StreakModel extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastNoSpendDate;

  /// Days in the last 30 days confirmed as no-spend (either no expense logged
  /// OR the user tapped "Confirm No-Spend Day" for that date).
  final List<DateTime> noSpendDays;

  /// Days explicitly confirmed by the user via the manual confirmation gesture.
  final List<DateTime> confirmedDays;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastNoSpendDate,
    required this.noSpendDays,
    this.confirmedDays = const [],
  });

  bool get isOnStreak => currentStreak > 0;

  /// True if today has already been confirmed or has no logged expenses.
  bool get todayConfirmed {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    return noSpendDays.any(
      (d) => d.year == todayNorm.year && d.month == todayNorm.month && d.day == todayNorm.day,
    );
  }

  String get streakEmoji {
    if (currentStreak >= 14) return '🏆';
    if (currentStreak >= 7) return '🔥';
    if (currentStreak >= 3) return '⚡';
    if (currentStreak >= 1) return '✨';
    return '💤';
  }

  String get streakMessage {
    if (currentStreak == 0) return 'Start your no-spend streak today!';
    if (currentStreak == 1) return 'Great start! Keep going.';
    if (currentStreak < 7) return '$currentStreak days strong!';
    if (currentStreak < 14) return 'One week milestone reached!';
    return 'Incredible discipline! $currentStreak days!';
  }

  @override
  List<Object?> get props =>
      [currentStreak, longestStreak, lastNoSpendDate, noSpendDays, confirmedDays];
}