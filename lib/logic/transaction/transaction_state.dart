import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/transaction_model.dart';

enum TransactionFilter {
  all,
  income,
  expense,
  today,
  thisWeek,
  thisMonth,
  lastMonth,
}

enum DateRangeFilter { today, thisWeek, thisMonth, lastMonth, all }

extension DateRangeFilterExt on DateRangeFilter {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case DateRangeFilter.today:
        return l10n.today;
      case DateRangeFilter.thisWeek:
        return l10n.thisWeek;
      case DateRangeFilter.thisMonth:
        return l10n.thisMonth;
      case DateRangeFilter.lastMonth:
        return l10n.lastMonth;
      case DateRangeFilter.all:
        return l10n.all;
    }
  }

  CustomDateRange? resolve() {
    final now = DateTime.now();
    switch (this) {
      case DateRangeFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        return CustomDateRange(start, start.add(const Duration(days: 1)));
      case DateRangeFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final s = DateTime(start.year, start.month, start.day);
        return CustomDateRange(s, now);
      case DateRangeFilter.thisMonth:
        return CustomDateRange(DateTime(now.year, now.month, 1), now);
      case DateRangeFilter.lastMonth:
        final first = DateTime(now.year, now.month - 1, 1);
        final last = DateTime(now.year, now.month, 1)
            .subtract(const Duration(milliseconds: 1));
        return CustomDateRange(first, last);
      case DateRangeFilter.all:
        return null;
    }
  }
}

class CustomDateRange extends Equatable {
  final DateTime start;
  final DateTime end;
  const CustomDateRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

extension FilterExt on TransactionFilter {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case TransactionFilter.all:
        return l10n.all;
      case TransactionFilter.income:
        return l10n.income;
      case TransactionFilter.expense:
        return l10n.expense;
      case TransactionFilter.today:
        return l10n.today;
      case TransactionFilter.thisWeek:
        return l10n.thisWeek;
      case TransactionFilter.thisMonth:
        return l10n.thisMonth;
      case TransactionFilter.lastMonth:
        return l10n.lastMonth;
    }
  }

  TransactionType? get type {
    if (this == TransactionFilter.income) return TransactionType.income;
    if (this == TransactionFilter.expense) return TransactionType.expense;
    return null;
  }

  DateRangeFilter? get dateRange {
    switch (this) {
      case TransactionFilter.today:
        return DateRangeFilter.today;
      case TransactionFilter.thisWeek:
        return DateRangeFilter.thisWeek;
      case TransactionFilter.thisMonth:
        return DateRangeFilter.thisMonth;
      case TransactionFilter.lastMonth:
        return DateRangeFilter.lastMonth;
      default:
        return null;
    }
  }
}
