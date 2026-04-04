class AppConstants {
  static const String transactionsBox = 'transactions';
  static const String goalsBox = 'goals';

  static const List<String> expenseCategories = [
    'Food & Drinks',
    'Shopping',
    'Transport',
    'Housing',
    'Entertainment',
    'Health',
    'Travel',
    'Education',
    'Other',
  ];

  // ── Income Categories ────────────────────────────────────────────────────
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  // ── Currency ─────────────────────────────────────────────────────────────
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  static const Map<String, String> supportedCurrencies = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'EGP': 'E£',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'INR': '₹',
  };
}
