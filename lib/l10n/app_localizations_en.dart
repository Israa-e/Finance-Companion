// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Companion';

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Transactions';

  @override
  String get budget => 'Budget';

  @override
  String get profile => 'Profile';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get title => 'Title';

  @override
  String get note => 'Note';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get recurringBills => 'Recurring Bills';

  @override
  String get budgetAlerts => 'Budget Alerts';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get clearAllNotifications => 'Clear all notifications?';

  @override
  String get clear => 'Clear';

  @override
  String get noNotificationsTitle => 'No notifications yet';

  @override
  String get noNotificationsSubtitle =>
      'Spending alerts and goal updates\nwill appear here';

  @override
  String get budgetAlertsSubtitle =>
      'Define when you want to receive notifications relative to your monthly budget.';

  @override
  String get warningThreshold => 'Warning Threshold';

  @override
  String get warningThresholdSubtitle => 'Receive a yellow alert';

  @override
  String get criticalThreshold => 'Critical Threshold';

  @override
  String get criticalThresholdSubtitle => 'Receive a red alert';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get exportData => 'Export Data (CSV)';

  @override
  String get biometricLock => 'Biometric Lock';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get noTransactions => 'No transactions found';

  @override
  String get availableToSpend => 'Available to spend';

  @override
  String get language => 'Language';

  @override
  String get goals => 'Goals';

  @override
  String get insights => 'Insights';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get locked => 'Locked';

  @override
  String get available => 'Available';

  @override
  String get delete => 'Delete';

  @override
  String deleteTransactionConfirm(String title) {
    return 'Remove \"$title\" permanently?';
  }

  @override
  String get noRecurringBills => 'No recurring bills set up';

  @override
  String get addRecurringBillsHint => 'Add bills like Rent, Netflix, or Salary';

  @override
  String get deleteRecurringBill => 'Delete Recurring Bill?';

  @override
  String get deleteRecurringBillConfirm =>
      'This will stop future automated transactions.';

  @override
  String get newRecurringBill => 'New Recurring Bill';

  @override
  String get addRecurringBill => 'Add Recurring Bill';

  @override
  String get addCategory => 'Add Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get createCategory => 'Create Category';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get noSpendStreak => 'No-Spend Streak';

  @override
  String daysStrong(int days) {
    return '$days days strong!';
  }

  @override
  String get days => 'days';

  @override
  String personalBest(int days) {
    return 'Personal best: $days days';
  }

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get seeAll => 'See all';

  @override
  String savedOfTotal(String saved, String total) {
    return 'saved of $saved total $total';
  }

  @override
  String get recent => 'Recent';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String achieved(String percent) {
    return 'achieved $percent%';
  }

  @override
  String remaining(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get completed => 'Completed';

  @override
  String get year => 'Year';

  @override
  String get last6Months => 'Last 6 Months';

  @override
  String get last3Months => 'Last 3 Months';

  @override
  String get topSpending => 'Top Spending';

  @override
  String get monthlyComparison => 'Monthly Comparison';

  @override
  String moreThanLastMonth(String amount) {
    return 'More than last month $amount';
  }

  @override
  String lessThanLastMonth(String amount) {
    return 'Less than last month $amount';
  }

  @override
  String get mostFrequent => 'Most Frequent';

  @override
  String get spendingPatterns => 'Spending Patterns';

  @override
  String get weeklySpending => 'Weekly Spending';

  @override
  String get confirmNoSpendToday => 'Confirm no-spend today';

  @override
  String get myFinances => 'My Finances';

  @override
  String get mondayShort => 'M';

  @override
  String get tuesdayShort => 'T';

  @override
  String get wednesdayShort => 'W';

  @override
  String get thursdayShort => 'T';

  @override
  String get fridayShort => 'F';

  @override
  String get saturdayShort => 'S';

  @override
  String get sundayShort => 'S';

  @override
  String get skip => 'Skip';

  @override
  String get onboarding1Title => 'Track Every\nPenny';

  @override
  String get onboarding1Subtitle =>
      'Log income and expenses in seconds. Know exactly where your money goes every single day.';

  @override
  String get onboarding2Title => 'Smart\nInsights';

  @override
  String get onboarding2Subtitle =>
      'Beautiful charts reveal your spending habits. Spot trends before they become problems.';

  @override
  String get onboarding3Title => 'Reach Your\nGoals';

  @override
  String get onboarding3Subtitle =>
      'Set savings goals, track progress, and celebrate every milestone on your path to financial freedom.';

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get noTransactionsSubtitle =>
      'Add your first transaction to get started';

  @override
  String get welcomeBack => 'Welcome Back 👋';

  @override
  String get loginSubtitle => 'Login to manage your finances';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get fullName => 'Full Name';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUs => 'Join Us 🚀';

  @override
  String get registerSubtitle => 'Start your journey to financial freedom';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Min 6 characters';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get initialBalanceRequired => 'Initial balance is required';

  @override
  String get monthlyBudgetRequired => 'Monthly budget is required';

  @override
  String get tapToAddPhoto => 'Tap to add a profile photo (optional)';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get negativeBalance => 'Balance cannot be negative';

  @override
  String get startingBalanceHint =>
      'Your current account balance — used as your starting point.';

  @override
  String get startingBalance => 'Starting Balance';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String onlyAvailable(String amount) {
    return 'Only $amount available';
  }

  @override
  String get groceryShoppingHint => 'e.g. Grocery Shopping';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get addDetailsHint => 'Add some details...';

  @override
  String get customCategories => 'Custom Categories';

  @override
  String get standardCategories => 'Standard Categories';

  @override
  String get categoryName => 'Category Name';

  @override
  String get subscriptionsHint => 'e.g. Subscriptions';

  @override
  String get next => 'Next';

  @override
  String get netflixHint => 'e.g. Netflix Subscription';

  @override
  String get noGoalsTitle => 'No goals yet';

  @override
  String get noGoalsSubtitle => 'Set a savings goal to track your progress';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get tryDifferentSearch => 'Try a different search term or view';

  @override
  String get transactionsAppearHere => 'Your transactions will appear here';

  @override
  String get couldNotLoadInsights => 'Could not load insights';

  @override
  String get monthlyTrend => 'Monthly Trend';

  @override
  String get monthlyTrendSubtitle => 'Expenses over the last 6 months';

  @override
  String spendingPatternWeekendMore(String percent) {
    return 'You spend $percent% more on weekends than weekdays.';
  }

  @override
  String spendingPatternWeekendLess(String percent) {
    return 'Great! You spend $percent% less on weekends than weekdays.';
  }

  @override
  String transactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get thisMonthLabel => 'This Month';

  @override
  String get lastMonthLabel => 'Last Month';

  @override
  String get noData => 'No data';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get noTransactionsInCategory => 'No transactions in this category.';

  @override
  String get predictiveInsights => 'Predictive Insights';

  @override
  String get spendingSustainable => 'Your spending is sustainable.';

  @override
  String get budgetBreachProjected => 'Budget breach projected!';

  @override
  String get currentBurnRate => 'Current burn rate: ';

  @override
  String burnRatePerDay(String amount) {
    return '$amount/day';
  }

  @override
  String get estimate => 'Estimate';

  @override
  String get filters => 'Filters';

  @override
  String get resetAll => 'Reset All';

  @override
  String get dateRange => 'Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get categories => 'Categories';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get goalAchieved => 'Goal achieved';

  @override
  String get addSavingsHint => 'Tap the plus icon to add savings';

  @override
  String get deleteGoal => 'Delete goal?';

  @override
  String deleteGoalConfirm(String title) {
    return 'This will permanently remove \"$title\". Any amount saved to this goal will be returned to your balance.';
  }

  @override
  String get addToSavings => 'Add to Savings';

  @override
  String get add => 'Add';

  @override
  String get deleteCustomView => 'Delete Custom View';

  @override
  String deleteCustomViewConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get saveCurrentView => 'Save Current View';

  @override
  String get viewNameHint => 'View Name (e.g., Business Only)';

  @override
  String entriesCount(int count) {
    return '$count entries';
  }
}
