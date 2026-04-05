import 'package:finance_companion/data/models/recurring_transaction_model.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/data/repositories/recurring_repository.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class RecurringProcessorService {
  final RecurringRepository _recurringRepo;
  final TransactionRepository _txRepo;

  RecurringProcessorService(this._recurringRepo, this._txRepo);

  /// Checks for due recurring transactions and inserts them.
  /// Should be called on app startup or periodically.
  Future<int> processDue(int userId) async {
    final templates = await _recurringRepo.getAll(userId);
    final now = DateTime.now();
    int processedCount = 0;

    for (final template in templates) {
      if (!template.isActive) continue;

      DateTime checkDate = template.nextDate;
      
      // Process all occurrences between nextDate and now (catch up if app was closed)
      while (checkDate.isBefore(now) || isSameDay(checkDate, now)) {
        // Create the transaction
        final newTx = TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          amount: template.amount,
          type: template.type == 'income' ? TransactionType.income : TransactionType.expense,
          category: template.category,
          date: checkDate,
          title: template.title,
          note: template.note != null ? '${template.note} (Auto-recurring)' : '(Auto-recurring)',
          lastUpdated: DateTime.now(),
          isSynced: false, // Will be picked up by sync logic
        );

        await _txRepo.add(newTx);
        processedCount++;

        // Calculate next occurrence
        checkDate = _calculateNextDate(checkDate, template.frequency);
      }

      // Update the template with the new nextDate
      if (processedCount > 0) {
        final updatedTemplate = template.copyWith(
          nextDate: checkDate,
          lastApplied: now,
        );
        await _recurringRepo.update(updatedTemplate);
      }
    }

    return processedCount;
  }

  DateTime _calculateNextDate(DateTime current, RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return current.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        // Simple monthly addition (handles month end correctly)
        int year = current.year;
        int month = current.month + 1;
        if (month > 12) {
          month = 1;
          year++;
        }
        return DateTime(year, month, current.day);
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
