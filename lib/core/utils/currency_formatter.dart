import 'package:finance_companion/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
 if (amount >= 1000) {
      return '${AppConstants.currencySymbol}${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount);
  }        
    static String formatSigned(double amount, {bool isExpense = false}) {
    final formatted = format(amount.abs());
    return isExpense ? '-$formatted' : '+$formatted';
  }                   
}
