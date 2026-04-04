import 'package:equatable/equatable.dart';

class StreakModel extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastNoSpendDate;

  /// The list of expense-free dates in the last 30 days.
  final List<DateTime> noSpendDays;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastNoSpendDate,
    required this.noSpendDays,
  });

  bool get isOnStreak => currentStreak > 0;

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
      [currentStreak, longestStreak, lastNoSpendDate, noSpendDays];
}