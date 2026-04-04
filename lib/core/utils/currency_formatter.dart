import 'package:finance_companion/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String activeSymbol = AppConstants.currencySymbol;

  static String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: activeSymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000) {
      return '$activeSymbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount);
  }        

  static String formatSigned(double amount, {bool isExpense = false}) {
    final formatted = format(amount.abs());
    return isExpense ? '-$formatted' : '+$formatted';
  }                   
}
