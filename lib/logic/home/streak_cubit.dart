import 'package:finance_companion/data/models/streak_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class StreakCubit extends Cubit<StreakState> {
  final TransactionRepository _repo;

  StreakCubit(this._repo) : super(StreakInitial());

  Future<void> loadStreak() async {
    emit(StreakLoading());
    try {
      final allTransactions = await _repo.getAll();

      // Collect all days that had at least one expense
      final spendDays = <DateTime>{};
      for (final t in allTransactions.where(
          (t) => t.type == TransactionType.expense)) {
        spendDays.add(
            DateTime(t.date.year, t.date.month, t.date.day));
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Build the last 30 days and find no-spend days
      final noSpendDays = <DateTime>[];
      for (int i = 0; i < 30; i++) {
        final day = today.subtract(Duration(days: i));
        if (!spendDays.contains(day)) {
          noSpendDays.add(day);
        }
      }

      // Calculate current streak: count consecutive no-spend days
      // going backwards from today (or yesterday if today has a spend)
      int currentStreak = 0;
      for (int i = 0; ; i++) {
        final day = today.subtract(Duration(days: i));
        if (spendDays.contains(day)) break;
        currentStreak++;
        // Safety: don't go further back than 365 days
        if (i >= 365) break;
      }

      // Calculate longest streak in last 365 days
      int longestStreak = 0;
      int runningStreak = 0;
      for (int i = 364; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        if (!spendDays.contains(day)) {
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
        ),
      ));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
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