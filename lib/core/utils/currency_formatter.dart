import 'package:intl/intl.dart';

class CurrencyFormatter {
  final String symbol;

  const CurrencyFormatter({this.symbol = '\$'});

  /// Instance method — preferred, testable
  String format(double amount) => _format(symbol, amount);

  String formatCompact(double amount) => _formatCompact(symbol, amount);

  String formatSigned(double amount, {bool isExpense = false}) {
    final f = _format(symbol, amount.abs());
    return isExpense ? '-$f' : '+$f';
  }

  static String _format(String sym, double amount) {
    final formatter = NumberFormat.currency(symbol: sym, decimalDigits: 2);
    return formatter.format(amount);
  }

  static String _formatCompact(String sym, double amount) {
    if (amount >= 1000) {
      return '$sym${(amount / 1000).toStringAsFixed(1)}k';
    }
    return _format(sym, amount);
  }
}