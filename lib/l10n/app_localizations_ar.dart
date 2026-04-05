// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رفيق المال';

  @override
  String get home => 'الرئيسية';

  @override
  String get transactions => 'المعاملات';

  @override
  String get budget => 'الميزانية';

  @override
  String get profile => 'الحساب';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get income => 'الدخل';

  @override
  String get expense => 'المصروفات';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get editTransaction => 'تعديل المعاملة';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get category => 'الفئة';

  @override
  String get amount => 'المبلغ';

  @override
  String get date => 'التاريخ';

  @override
  String get title => 'العنوان';

  @override
  String get note => 'ملاحظة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get all => 'الكل';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String get recurringBills => 'الفواتير المتكررة';

  @override
  String get budgetAlerts => 'تنبيهات الميزانية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllRead => 'تمييز الكل كمقروء';

  @override
  String get clearAllNotifications => 'مسح جميع الإشعارات؟';

  @override
  String get clear => 'مسح';

  @override
  String get noNotificationsTitle => 'لا توجد إشعارات بعد';

  @override
  String get noNotificationsSubtitle =>
      'ستظهر هنا تنبيهات الإنفاق وتحديثات الأهداف';

  @override
  String get budgetAlertsSubtitle =>
      'حدد متى تريد تلقي الإشعارات المتعلقة بميزانيتك الشهرية.';

  @override
  String get warningThreshold => 'حد التحذير';

  @override
  String get warningThresholdSubtitle => 'تلقي تنبيه أصفر';

  @override
  String get criticalThreshold => 'الحد الحرج';

  @override
  String get criticalThresholdSubtitle => 'تلقي تنبيه أحمر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get exportData => 'تصدير البيانات (CSV)';

  @override
  String get biometricLock => 'القفل البيومتري';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get noTransactions => 'لم يتم العور على معاملات';

  @override
  String get availableToSpend => 'متاح للإنفاق';

  @override
  String get language => 'اللغة';

  @override
  String get goals => 'الأهداف';

  @override
  String get insights => 'التحليلات';

  @override
  String get editProfile => 'تعديل الحساب';

  @override
  String get locked => 'محجوز';

  @override
  String get available => 'متاح';

  @override
  String get delete => 'حذف';

  @override
  String deleteTransactionConfirm(String title) {
    return 'هل تريد إزالة \"$title\" نهائياً؟';
  }

  @override
  String get noRecurringBills => 'لا توجد فواتير متكررة';

  @override
  String get addRecurringBillsHint =>
      'أضف فواتير مثل الإيجار، أو نتفليكس، أو الراتب';

  @override
  String get deleteRecurringBill => 'حذف الفاتورة المتكررة؟';

  @override
  String get deleteRecurringBillConfirm =>
      'سيؤدي هذا إلى إيقاف المعاملات الآلية المستقبلية.';

  @override
  String get newRecurringBill => 'فاتورة متكررة جديدة';

  @override
  String get addRecurringBill => 'إضافة فاتورة متكررة';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get deleteCategory => 'حذف الفئة';

  @override
  String deleteCategoryConfirm(String name) {
    return 'هل أنت متأكد أنك تريد حذف \"$name\"؟';
  }

  @override
  String get createCategory => 'إنشاء فئة';

  @override
  String get selectIcon => 'اختر الرمز';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get noSpendStreak => 'أيام متتالية بدون إنفاق';

  @override
  String daysStrong(int days) {
    return 'قوي لمدة $days أيام!';
  }

  @override
  String get days => 'يوم';

  @override
  String personalBest(int days) {
    return 'أفضل رقم شخصي: $days أيام';
  }

  @override
  String get savingsGoals => 'أهداف التوفير';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String savedOfTotal(String saved, String total) {
    return 'تم جمع $saved من أصل $total';
  }

  @override
  String get recent => 'الأخيرة';

  @override
  String get yesterday => 'أمس';

  @override
  String daysLeft(int days) {
    return 'باقي $days أيام';
  }

  @override
  String achieved(String percent) {
    return 'تم تحقيق $percent%';
  }

  @override
  String remaining(String amount) {
    return 'المتبقي: $amount';
  }

  @override
  String get completed => 'مكتمل';

  @override
  String get year => 'سنة';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get last3Months => 'آخر 3 أشهر';

  @override
  String get topSpending => 'أعلى إنفاق';

  @override
  String get monthlyComparison => 'مقارنة شهرية';

  @override
  String moreThanLastMonth(String amount) {
    return 'أكثر من الشهر الماضي $amount';
  }

  @override
  String lessThanLastMonth(String amount) {
    return 'أقل من الشهر الماضي $amount';
  }

  @override
  String get mostFrequent => 'الأكثر تكراراً';

  @override
  String get spendingPatterns => 'أنماط الإنفاق';

  @override
  String get weeklySpending => 'الإنفاق الأسبوعي';

  @override
  String get confirmNoSpendToday => 'تأكيد عدم الإنفاق اليوم';

  @override
  String get myFinances => 'أموالي';

  @override
  String get mondayShort => 'ن';

  @override
  String get tuesdayShort => 'ث';

  @override
  String get wednesdayShort => 'ر';

  @override
  String get thursdayShort => 'خ';

  @override
  String get fridayShort => 'ج';

  @override
  String get saturdayShort => 'س';

  @override
  String get sundayShort => 'ح';

  @override
  String get skip => 'تخطي';

  @override
  String get onboarding1Title => 'تتبع كل\nقرش';

  @override
  String get onboarding1Subtitle =>
      'سجل الدخل والمصروفات في ثوانٍ. اعرف بالضبط أين تذهب أموالك كل يوم.';

  @override
  String get onboarding2Title => 'رؤى\nذكية';

  @override
  String get onboarding2Subtitle =>
      'تكشف الرسوم البيانية الجميلة عن عادات الإنفاق الخاصة بك. اكتشف الاتجاهات قبل أن تصبح مشاكل.';

  @override
  String get onboarding3Title => 'حقق\nأهدافك';

  @override
  String get onboarding3Subtitle =>
      'حدد أهداف الادخار، وتتبع التقدم، واحتفل بكل إنجاز في طريقك نحو الحرية المالية.';

  @override
  String get noTransactionsTitle => 'لا توجد معاملات بعد';

  @override
  String get noTransactionsSubtitle => 'أضف معاملتك الأولى للبدء';

  @override
  String get welcomeBack => 'مرحباً بعودتك 👋';

  @override
  String get loginSubtitle => 'قم بتسجيل الدخول لإدارة أموالك';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get register => 'سجل الآن';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get initialBalance => 'الرصيد الأولي';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinUs => 'انضم إلينا 🚀';

  @override
  String get registerSubtitle => 'ابدأ رحلتك نحو الحرية المالية';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength => '6 أحرف على الأقل';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get initialBalanceRequired => 'الرصيد الأولي مطلوب';

  @override
  String get monthlyBudgetRequired => 'الميزانية الشهرية مطلوبة';

  @override
  String get tapToAddPhoto => 'انقر لإضافة صورة (اختياري)';

  @override
  String get tapToChangePhoto => 'انقر لتغيير الصورة';

  @override
  String get invalidNumber => 'أدخل رقماً صالحاً';

  @override
  String get negativeBalance => 'لا يمكن أن يكون الرصيد سالباً';

  @override
  String get startingBalanceHint => 'رصيدك الحالي - يستخدم كنقطة بداية.';

  @override
  String get startingBalance => 'رصيد البداية';

  @override
  String get nameCannotBeEmpty => 'الاسم لا يمكن أن يكون فارغاً';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get invalidAmount => 'المبلغ غير صحيح';

  @override
  String onlyAvailable(String amount) {
    return 'متاح فقط $amount';
  }

  @override
  String get groceryShoppingHint => 'مثال: تسوق البقالة';

  @override
  String get enterTitle => 'أدخل العنوان';

  @override
  String get addDetailsHint => 'أضف بعض التفاصيل...';

  @override
  String get customCategories => 'فئات مخصصة';

  @override
  String get standardCategories => 'فئات قياسية';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get subscriptionsHint => 'مثال: اشتراكات';

  @override
  String get next => 'التالي';

  @override
  String get netflixHint => 'مثال: اشتراك نتفليكس';

  @override
  String get noGoalsTitle => 'لا توجد أهداف بعد';

  @override
  String get noGoalsSubtitle => 'حدد هدفاً للادخار لتتبع تقدمك';

  @override
  String get addGoal => 'إضافة هدف';

  @override
  String get tryDifferentSearch => 'جرب مصطلح بحث أو عرض مختلف';

  @override
  String get transactionsAppearHere => 'ستظهر معاملاتك هنا';

  @override
  String get couldNotLoadInsights => 'تعذر تحميل التحليلات';

  @override
  String get monthlyTrend => 'الاتجاه الشهري';

  @override
  String get monthlyTrendSubtitle => 'المصروفات خلال آخر 6 أشهر';

  @override
  String spendingPatternWeekendMore(String percent) {
    return 'تُنفق $percent% أكثر في عطلات نهاية الأسبوع مقارنة بأيام الأسبوع.';
  }

  @override
  String spendingPatternWeekendLess(String percent) {
    return 'رائع! تُنفق $percent% أقل في عطلات نهاية الأسبوع مقارنة بأيام الأسبوع.';
  }

  @override
  String transactionsCount(int count) {
    return '$count معاملات';
  }

  @override
  String get thisMonthLabel => 'هذا الشهر';

  @override
  String get lastMonthLabel => 'الشهر الماضي';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get spendingByCategory => 'الإنفاق حسب الفئة';

  @override
  String get noTransactionsInCategory => 'لا توجد معاملات في هذه الفئة.';

  @override
  String get predictiveInsights => 'رؤى تنبؤية';

  @override
  String get spendingSustainable => 'إنفاقك مستدام.';

  @override
  String get budgetBreachProjected => 'توقع تجاوز الميزانية!';

  @override
  String get currentBurnRate => 'معدل الإنفاق الحالي: ';

  @override
  String burnRatePerDay(String amount) {
    return '$amount/يوم';
  }

  @override
  String get estimate => 'تقدير';

  @override
  String get filters => 'التصنيفات';

  @override
  String get resetAll => 'إعادة تعيين الكل';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get applyFilters => 'تطبيق التصنيفات';

  @override
  String get categories => 'الفئات';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';

  @override
  String get goalAchieved => 'تم تحقيق الهدف';

  @override
  String get addSavingsHint => 'اضغط على أيقونة الزائد لإضافة مدخرات';

  @override
  String get deleteGoal => 'حذف الهدف؟';

  @override
  String deleteGoalConfirm(String title) {
    return 'سيؤدي هذا إلى حذف \"$title\" نهائياً. سيتم إرجاع أي مبلغ تم توفيره لهذا الهدف إلى رصيدك.';
  }

  @override
  String get addToSavings => 'إضافة إلى المدخرات';

  @override
  String get add => 'إضافة';

  @override
  String get deleteCustomView => 'حذف العرض المخصص';

  @override
  String deleteCustomViewConfirm(String name) {
    return 'هل أنت متأكد أنك تريد حذف \"$name\"؟';
  }

  @override
  String get saveCurrentView => 'حفظ العرض الحالي';

  @override
  String get viewNameHint => 'اسم العرض (مثلاً: عمل فقط)';

  @override
  String entriesCount(int count) {
    return '$count قيود';
  }

  @override
  String get newGoal => 'هدف جديد';

  @override
  String get goalTitle => 'عنوان الهدف';

  @override
  String get goalTitleHint => 'مثل: لابتوب جديد';

  @override
  String get targetAmount => 'المبلغ المستهدف';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get createGoal => 'إنشاء الهدف';

  @override
  String get pleaseEnterTitle => 'يرجى إدخال عنوان';

  @override
  String get pleaseEnterAmount => 'يرجى إدخال المبلغ المستهدف';

  @override
  String get amountGreaterThanZero => 'يجب أن يكون المبلغ أكبر من الصفر';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get confirm => 'تأكيد';

  @override
  String get daily => 'يومياً';

  @override
  String get weekly => 'أسبوعياً';

  @override
  String get monthly => 'شهرياً';

  @override
  String get currency => 'العملة';
}
