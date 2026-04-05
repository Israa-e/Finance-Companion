import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance Companion'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @recurringBills.
  ///
  /// In en, this message translates to:
  /// **'Recurring Bills'**
  String get recurringBills;

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget Alerts'**
  String get budgetAlerts;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get clearAllNotifications;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spending alerts and goal updates\nwill appear here'**
  String get noNotificationsSubtitle;

  /// No description provided for @budgetAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define when you want to receive notifications relative to your monthly budget.'**
  String get budgetAlertsSubtitle;

  /// No description provided for @warningThreshold.
  ///
  /// In en, this message translates to:
  /// **'Warning Threshold'**
  String get warningThreshold;

  /// No description provided for @warningThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a yellow alert'**
  String get warningThresholdSubtitle;

  /// No description provided for @criticalThreshold.
  ///
  /// In en, this message translates to:
  /// **'Critical Threshold'**
  String get criticalThreshold;

  /// No description provided for @criticalThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a red alert'**
  String get criticalThresholdSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data (CSV)'**
  String get exportData;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock'**
  String get biometricLock;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactions;

  /// No description provided for @availableToSpend.
  ///
  /// In en, this message translates to:
  /// **'Available to spend'**
  String get availableToSpend;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" permanently?'**
  String deleteTransactionConfirm(String title);

  /// No description provided for @noRecurringBills.
  ///
  /// In en, this message translates to:
  /// **'No recurring bills set up'**
  String get noRecurringBills;

  /// No description provided for @addRecurringBillsHint.
  ///
  /// In en, this message translates to:
  /// **'Add bills like Rent, Netflix, or Salary'**
  String get addRecurringBillsHint;

  /// No description provided for @deleteRecurringBill.
  ///
  /// In en, this message translates to:
  /// **'Delete Recurring Bill?'**
  String get deleteRecurringBill;

  /// No description provided for @deleteRecurringBillConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will stop future automated transactions.'**
  String get deleteRecurringBillConfirm;

  /// No description provided for @newRecurringBill.
  ///
  /// In en, this message translates to:
  /// **'New Recurring Bill'**
  String get newRecurringBill;

  /// No description provided for @addRecurringBill.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring Bill'**
  String get addRecurringBill;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @noSpendStreak.
  ///
  /// In en, this message translates to:
  /// **'No-Spend Streak'**
  String get noSpendStreak;

  /// No description provided for @daysStrong.
  ///
  /// In en, this message translates to:
  /// **'{days} days strong!'**
  String daysStrong(int days);

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @personalBest.
  ///
  /// In en, this message translates to:
  /// **'Personal best: {days} days'**
  String personalBest(int days);

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @savedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'saved of {saved} total {total}'**
  String savedOfTotal(String saved, String total);

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'achieved {percent}%'**
  String achieved(String percent);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String remaining(String amount);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get last6Months;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// No description provided for @topSpending.
  ///
  /// In en, this message translates to:
  /// **'Top Spending'**
  String get topSpending;

  /// No description provided for @monthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// No description provided for @moreThanLastMonth.
  ///
  /// In en, this message translates to:
  /// **'More than last month {amount}'**
  String moreThanLastMonth(String amount);

  /// No description provided for @lessThanLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Less than last month {amount}'**
  String lessThanLastMonth(String amount);

  /// No description provided for @mostFrequent.
  ///
  /// In en, this message translates to:
  /// **'Most Frequent'**
  String get mostFrequent;

  /// No description provided for @spendingPatterns.
  ///
  /// In en, this message translates to:
  /// **'Spending Patterns'**
  String get spendingPatterns;

  /// No description provided for @weeklySpending.
  ///
  /// In en, this message translates to:
  /// **'Weekly Spending'**
  String get weeklySpending;

  /// No description provided for @confirmNoSpendToday.
  ///
  /// In en, this message translates to:
  /// **'Confirm no-spend today'**
  String get confirmNoSpendToday;

  /// No description provided for @myFinances.
  ///
  /// In en, this message translates to:
  /// **'My Finances'**
  String get myFinances;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayShort;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Track Every\nPenny'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Log income and expenses in seconds. Know exactly where your money goes every single day.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Smart\nInsights'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful charts reveal your spending habits. Spot trends before they become problems.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Reach Your\nGoals'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set savings goals, track progress, and celebrate every milestone on your path to financial freedom.'**
  String get onboarding3Subtitle;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction to get started'**
  String get noTransactionsSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to manage your finances'**
  String get loginSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinUs.
  ///
  /// In en, this message translates to:
  /// **'Join Us 🚀'**
  String get joinUs;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to financial freedom'**
  String get registerSubtitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordMinLength;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @initialBalanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Initial balance is required'**
  String get initialBalanceRequired;

  /// No description provided for @monthlyBudgetRequired.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget is required'**
  String get monthlyBudgetRequired;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a profile photo (optional)'**
  String get tapToAddPhoto;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @negativeBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance cannot be negative'**
  String get negativeBalance;

  /// No description provided for @startingBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Your current account balance — used as your starting point.'**
  String get startingBalanceHint;

  /// No description provided for @startingBalance.
  ///
  /// In en, this message translates to:
  /// **'Starting Balance'**
  String get startingBalance;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @onlyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Only {amount} available'**
  String onlyAvailable(String amount);

  /// No description provided for @groceryShoppingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grocery Shopping'**
  String get groceryShoppingHint;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @addDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add some details...'**
  String get addDetailsHint;

  /// No description provided for @customCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom Categories'**
  String get customCategories;

  /// No description provided for @standardCategories.
  ///
  /// In en, this message translates to:
  /// **'Standard Categories'**
  String get standardCategories;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @subscriptionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Subscriptions'**
  String get subscriptionsHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @netflixHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix Subscription'**
  String get netflixHint;

  /// No description provided for @noGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoalsTitle;

  /// No description provided for @noGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a savings goal to track your progress'**
  String get noGoalsSubtitle;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or view'**
  String get tryDifferentSearch;

  /// No description provided for @transactionsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionsAppearHere;

  /// No description provided for @couldNotLoadInsights.
  ///
  /// In en, this message translates to:
  /// **'Could not load insights'**
  String get couldNotLoadInsights;

  /// No description provided for @monthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trend'**
  String get monthlyTrend;

  /// No description provided for @monthlyTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses over the last 6 months'**
  String get monthlyTrendSubtitle;

  /// No description provided for @spendingPatternWeekendMore.
  ///
  /// In en, this message translates to:
  /// **'You spend {percent}% more on weekends than weekdays.'**
  String spendingPatternWeekendMore(String percent);

  /// No description provided for @spendingPatternWeekendLess.
  ///
  /// In en, this message translates to:
  /// **'Great! You spend {percent}% less on weekends than weekdays.'**
  String spendingPatternWeekendLess(String percent);

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(int count);

  /// No description provided for @thisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthLabel;

  /// No description provided for @lastMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonthLabel;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @noTransactionsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this category.'**
  String get noTransactionsInCategory;

  /// No description provided for @predictiveInsights.
  ///
  /// In en, this message translates to:
  /// **'Predictive Insights'**
  String get predictiveInsights;

  /// No description provided for @spendingSustainable.
  ///
  /// In en, this message translates to:
  /// **'Your spending is sustainable.'**
  String get spendingSustainable;

  /// No description provided for @budgetBreachProjected.
  ///
  /// In en, this message translates to:
  /// **'Budget breach projected!'**
  String get budgetBreachProjected;

  /// No description provided for @currentBurnRate.
  ///
  /// In en, this message translates to:
  /// **'Current burn rate: '**
  String get currentBurnRate;

  /// No description provided for @burnRatePerDay.
  ///
  /// In en, this message translates to:
  /// **'{amount}/day'**
  String burnRatePerDay(String amount);

  /// No description provided for @estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get estimate;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved'**
  String get goalAchieved;

  /// No description provided for @addSavingsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the plus icon to add savings'**
  String get addSavingsHint;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove \"{title}\". Any amount saved to this goal will be returned to your balance.'**
  String deleteGoalConfirm(String title);

  /// No description provided for @addToSavings.
  ///
  /// In en, this message translates to:
  /// **'Add to Savings'**
  String get addToSavings;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteCustomView.
  ///
  /// In en, this message translates to:
  /// **'Delete Custom View'**
  String get deleteCustomView;

  /// No description provided for @deleteCustomViewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteCustomViewConfirm(String name);

  /// No description provided for @saveCurrentView.
  ///
  /// In en, this message translates to:
  /// **'Save Current View'**
  String get saveCurrentView;

  /// No description provided for @viewNameHint.
  ///
  /// In en, this message translates to:
  /// **'View Name (e.g., Business Only)'**
  String get viewNameHint;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entriesCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
