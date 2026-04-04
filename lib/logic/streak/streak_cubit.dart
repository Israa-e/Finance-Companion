import 'package:finance_companion/data/models/streak_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class StreakCubit extends Cubit<StreakState> {
  final TransactionRepository _repo;
  static const _confirmedDaysKey = 'confirmed_no_spend_days';

  StreakCubit(this._repo) : super(StreakInitial());

  Future<void> loadStreak() async {
    emit(StreakLoading());
    try {
      final allTransactions = await _repo.getAll();
      final confirmedDays = await _loadConfirmedDays();

      // Build the set of days that had at least one expense
      final spendDays = <DateTime>{};
      for (final t in allTransactions.where(
        (t) => t.type == TransactionType.expense,
      )) {
        spendDays.add(DateTime(t.date.year, t.date.month, t.date.day));
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // A day is "no-spend" if:
      //   1. No expense was logged on that day, AND
      //   2. Either: it's in the future (impossible here), OR
      //      the user explicitly confirmed it, OR
      //      it has an expense that disqualifies it.
      // For past days with no expenses but also no confirmation, we only
      // count them IF they are within the last 7 days (reasonable assumption).
      // Days older than 7 days without confirmation are excluded to prevent
      // artificial streak inflation.
      final noSpendDays = <DateTime>[];
      for (int i = 0; i < 30; i++) {
        final day = today.subtract(Duration(days: i));
        if (spendDays.contains(day)) continue; // had an expense — not no-spend

        final isConfirmed = confirmedDays.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );
        final isWithinOneWeek = i <= 6; // last 7 days get benefit of the doubt

        if (isConfirmed || isWithinOneWeek) {
          noSpendDays.add(day);
        }
      }

      // Current streak: consecutive no-spend days going back from today
      int currentStreak = 0;
      for (int i = 0; ; i++) {
        final day = today.subtract(Duration(days: i));
        if (spendDays.contains(day)) break;
        final isConfirmed = confirmedDays.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );
        if (!isConfirmed && i > 6) break; // older unconfirmed days break streak
        currentStreak++;
        if (i >= 365) break;
      }

      // Longest streak in last 365 days
      int longestStreak = 0;
      int runningStreak = 0;
      for (int i = 364; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final hasExpense = spendDays.contains(day);
        final isConfirmed = confirmedDays.any(
          (d) => d.year == day.year && d.month == day.month && d.day == day.day,
        );
        final withinWeek = i <= 6;

        if (!hasExpense && (isConfirmed || withinWeek)) {
          runningStreak++;
          if (runningStreak > longestStreak) longestStreak = runningStreak;
        } else {
          runningStreak = 0;
        }
      }

      emit(StreakLoaded(
        streak: StreakModel(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastNoSpendDate: noSpendDays.isNotEmpty ? noSpendDays.first : null,
          noSpendDays: noSpendDays,
          confirmedDays: confirmedDays,
        ),
      ));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  /// Called when the user taps "Confirm No-Spend Day" for today.
  Future<void> confirmTodayNoSpend() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final confirmed = await _loadConfirmedDays();

    final alreadyConfirmed = confirmed.any(
      (d) => d.year == today.year && d.month == today.month && d.day == today.day,
    );
    if (alreadyConfirmed) return;

    confirmed.add(today);
    await _saveConfirmedDays(confirmed);
    await loadStreak();
  }

  Future<List<DateTime>> _loadConfirmedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_confirmedDaysKey) ?? [];
    return raw.map((s) => DateTime.parse(s)).toList();
  }

  Future<void> _saveConfirmedDays(List<DateTime> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _confirmedDaysKey,
      days.map((d) => d.toIso8601String()).toList(),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class StreakState {}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakLoaded extends StreakState {
  final StreakModel streak;
  StreakLoaded({required this.streak});
}

class StreakError extends StreakState {
  final String message;
  StreakError(this.message);
}