// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'फाइनेंस कंपैनियन';

  @override
  String get home => 'होम';

  @override
  String get transactions => 'लेन-देन';

  @override
  String get budget => 'बजट';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get totalBalance => 'कुल शेष';

  @override
  String get income => 'आय';

  @override
  String get expense => 'खर्च';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get addTransaction => 'लेन-देन जोड़ें';

  @override
  String get editTransaction => 'लेन-देन संपादित करें';

  @override
  String get deleteTransaction => 'लेन-देन हटाएं';

  @override
  String get category => 'श्रेणी';

  @override
  String get amount => 'राशि';

  @override
  String get date => 'तारीख';

  @override
  String get title => 'शीर्षक';

  @override
  String get note => 'नोट';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get search => 'खोजें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get all => 'सभी';

  @override
  String get today => 'आज';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get lastMonth => 'पिछला महीना';

  @override
  String get manageCategories => 'श्रेणियां प्रबंधित करें';

  @override
  String get recurringBills => 'आवर्ती बिल';

  @override
  String get budgetAlerts => 'बजट अलर्ट';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get markAllRead => 'सभी को पढ़ा हुआ मानें';

  @override
  String get clearAllNotifications => 'सभी सूचनाएं हटाएं?';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get noNotificationsTitle => 'अभी कोई सूचना नहीं';

  @override
  String get noNotificationsSubtitle =>
      'खर्च के अलर्ट और लक्ष्यों के अपडेट\nयहाँ दिखाई देंगे';

  @override
  String get budgetAlertsSubtitle =>
      'निर्धारित करें कि आप अपने मासिक बजट के सापेक्ष कब सूचनाएं प्राप्त करना चाहते हैं।';

  @override
  String get warningThreshold => 'चेतावनी सीमा';

  @override
  String get warningThresholdSubtitle => 'एक पीला अलर्ट प्राप्त करें';

  @override
  String get criticalThreshold => 'गंभीर सीमा';

  @override
  String get criticalThresholdSubtitle => 'एक लाल अलर्ट प्राप्त करें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get exportData => 'डेटा निर्यात करें (CSV)';

  @override
  String get biometricLock => 'बायोमेट्रिक लॉक';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get noTransactions => 'कोई लेन-देन नहीं मिला';

  @override
  String get availableToSpend => 'खर्च के लिए उपलब्ध';

  @override
  String get language => 'भाषा';

  @override
  String get goals => 'लक्ष्य';

  @override
  String get insights => 'इनसाइट्स';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get locked => 'लॉक किया गया';

  @override
  String get available => 'उपलब्ध';

  @override
  String get delete => 'हटाएं';

  @override
  String deleteTransactionConfirm(String title) {
    return '\"$title\" को स्थायी रूप से हटाएं?';
  }

  @override
  String get noRecurringBills => 'कोई आवर्ती बिल सेट नहीं है';

  @override
  String get addRecurringBillsHint =>
      'किराया, नेटफ्लिक्स या वेतन जैसे बिल जोड़ें';

  @override
  String get deleteRecurringBill => 'आवर्ती बिल हटाएं?';

  @override
  String get deleteRecurringBillConfirm =>
      'यह भविष्य के स्वचालित लेन-देनों को रोक देगा।';

  @override
  String get newRecurringBill => 'नया आवर्ती बिल';

  @override
  String get addRecurringBill => 'आवर्ती बिल जोड़ें';

  @override
  String get addCategory => 'श्रेणी जोड़ें';

  @override
  String get deleteCategory => 'श्रेणी हटाएं';

  @override
  String deleteCategoryConfirm(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं?';
  }

  @override
  String get createCategory => 'श्रेणी बनाएं';

  @override
  String get selectIcon => 'आइकन चुनें';

  @override
  String get selectColor => 'रंग चुनें';

  @override
  String get goodMorning => 'शुभ प्रभात';

  @override
  String get goodAfternoon => 'नमस्कार';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get noSpendStreak => 'नो-स्पेंड स्ट्रीक';

  @override
  String daysStrong(int days) {
    return '$days दिनों से मज़बूत!';
  }

  @override
  String get days => 'दिन';

  @override
  String personalBest(int days) {
    return 'व्यक्तिगत सर्वश्रेष्ठ: $days दिन';
  }

  @override
  String get savingsGoals => 'बचत लक्ष्य';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String savedOfTotal(String saved, String total) {
    return '$total में से $saved बचाए गए';
  }

  @override
  String get recent => 'हाल ही के';

  @override
  String get yesterday => 'कल';

  @override
  String daysLeft(int days) {
    return '$days दिन शेष';
  }

  @override
  String achieved(String percent) {
    return '$percent% प्राप्त';
  }

  @override
  String remaining(String amount) {
    return 'शेष: $amount';
  }

  @override
  String get completed => 'पूरा हुआ';

  @override
  String get year => 'वर्ष';

  @override
  String get last6Months => 'पिछले 6 महीने';

  @override
  String get last3Months => 'पिछले 3 महीने';

  @override
  String get topSpending => 'सबसे अधिक खर्च';

  @override
  String get monthlyComparison => 'मासिक तुलना';

  @override
  String moreThanLastMonth(String amount) {
    return 'पिछले महीने से अधिक $amount';
  }

  @override
  String lessThanLastMonth(String amount) {
    return 'पिछले महीने से कम $amount';
  }

  @override
  String get mostFrequent => 'सबसे लगातार';

  @override
  String get spendingPatterns => 'खर्च के पैटर्न';

  @override
  String get weeklySpending => 'साप्ताहिक खर्च';

  @override
  String get confirmNoSpendToday => 'आज का खर्च न होना पुष्ट करें';

  @override
  String get myFinances => 'मेरे फाइनेंस';

  @override
  String get mondayShort => 'सोम';

  @override
  String get tuesdayShort => 'मंगल';

  @override
  String get wednesdayShort => 'बुध';

  @override
  String get thursdayShort => 'गुरु';

  @override
  String get fridayShort => 'शुक्र';

  @override
  String get saturdayShort => 'शनि';

  @override
  String get sundayShort => 'रवि';

  @override
  String get skip => 'छोड़ें';

  @override
  String get onboarding1Title => 'हर पैसे पर\nनज़र रखें';

  @override
  String get onboarding1Subtitle =>
      'आय और खर्च को सेकंडों में लॉग करें। जानें कि आपका पैसा हर दिन कहाँ जाता है।';

  @override
  String get onboarding2Title => 'स्मार्ट\nइनसाइट्स';

  @override
  String get onboarding2Subtitle =>
      'सुंदर चार्ट आपकी खर्च करने की आदतों को उजागर करते हैं। समस्या बनने से पहले रुझानों को पहचानें।';

  @override
  String get onboarding3Title => 'अपने लक्ष्य\nप्राप्त करें';

  @override
  String get onboarding3Subtitle =>
      'बचत लक्ष्य निर्धारित करें, प्रगति ट्रैक करें, और वित्तीय स्वतंत्रता की ओर हर मील के पत्थर का जश्न मनाएं।';

  @override
  String get noTransactionsTitle => 'अभी तक कोई लेन-देन नहीं';

  @override
  String get noTransactionsSubtitle =>
      'शुरू करने के लिए अपना पहला लेन-देन जोड़ें';

  @override
  String get welcomeBack => 'स्वागत है 👋';

  @override
  String get loginSubtitle => 'अपने फाइनेंस प्रबंधित करने के लिए लॉगिन करें';

  @override
  String get dontHaveAccount => 'खाता नहीं है? ';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get login => 'लॉगिन';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get initialBalance => 'प्रारंभिक शेष';

  @override
  String get monthlyBudget => 'मासिक बजट';

  @override
  String get alreadyHaveAccount => 'पहले से ही एक खाता है? ';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get joinUs => 'हमारे साथ जुड़ें 🚀';

  @override
  String get registerSubtitle => 'वित्तीय स्वतंत्रता की अपनी यात्रा शुरू करें';

  @override
  String get emailRequired => 'ईमेल आवश्यक है';

  @override
  String get invalidEmail => 'अमान्य ईमेल';

  @override
  String get passwordRequired => 'पासवर्ड आवश्यक है';

  @override
  String get passwordMinLength => 'कम से कम 6 अक्षर';

  @override
  String get fullNameRequired => 'पूरा नाम आवश्यक है';

  @override
  String get initialBalanceRequired => 'प्रारंभिक शेष आवश्यक है';

  @override
  String get monthlyBudgetRequired => 'मासिक बजट आवश्यक है';

  @override
  String get tapToAddPhoto =>
      'प्रोफ़ाइल फ़ोटो जोड़ने के लिए टैप करें (वैकल्पिक)';

  @override
  String get tapToChangePhoto => 'फ़ोटो बदलने के लिए टैप करें';

  @override
  String get invalidNumber => 'एक मान्य संख्या दर्ज करें';

  @override
  String get negativeBalance => 'शेष नकारात्मक नहीं हो सकता';

  @override
  String get startingBalanceHint =>
      'आपका वर्तमान खाता शेष — आपके शुरुआती बिंदु के रूप में उपयोग किया जाता है।';

  @override
  String get startingBalance => 'शुरुआती शेष';

  @override
  String get nameCannotBeEmpty => 'नाम खाली नहीं हो सकता';

  @override
  String get selectCurrency => 'मुद्रा चुनें';

  @override
  String get enterAmount => 'राशि दर्ज करें';

  @override
  String get invalidAmount => 'अमान्य राशि';

  @override
  String onlyAvailable(String amount) {
    return 'केवल $amount उपलब्ध है';
  }

  @override
  String get groceryShoppingHint => 'जैसे: किराने की खरीदारी';

  @override
  String get enterTitle => 'शीर्षक दर्ज करें';

  @override
  String get addDetailsHint => 'कुछ विवरण जोड़ें...';

  @override
  String get customCategories => 'कस्टम श्रेणियां';

  @override
  String get standardCategories => 'मानक श्रेणियां';

  @override
  String get categoryName => 'श्रेणी का नाम';

  @override
  String get subscriptionsHint => 'जैसे: सदस्यता';

  @override
  String get next => 'अगला';

  @override
  String get netflixHint => 'जैसे: नेटफ्लिक्स सदस्यता';

  @override
  String get noGoalsTitle => 'अभी कोई लक्ष्य नहीं';

  @override
  String get noGoalsSubtitle =>
      'अपनी प्रगति को ट्रैक करने के लिए एक बचत लक्ष्य निर्धारित करें';

  @override
  String get addGoal => 'लक्ष्य जोड़ें';

  @override
  String get tryDifferentSearch => 'कोई अलग खोज शब्द या दृश्य आज़माएं';

  @override
  String get transactionsAppearHere => 'आपके लेन-देन यहाँ दिखाई देंगे';

  @override
  String get couldNotLoadInsights => 'इनसाइट्स लोड नहीं हो सका';

  @override
  String get monthlyTrend => 'मासिक रुझान';

  @override
  String get monthlyTrendSubtitle => 'पिछले 6 महीनों में खर्च';

  @override
  String spendingPatternWeekendMore(String percent) {
    return 'आप कार्यदिवसों की तुलना में सप्ताहांत पर $percent% अधिक खर्च करते हैं।';
  }

  @override
  String spendingPatternWeekendLess(String percent) {
    return 'बहुत बढ़िया! आप कार्यदिवसों की तुलना में सप्ताहांत पर $percent% कम खर्च करते हैं।';
  }

  @override
  String transactionsCount(int count) {
    return '$count लेन-देन';
  }

  @override
  String get thisMonthLabel => 'इस महीने';

  @override
  String get lastMonthLabel => 'पिछले महीने';

  @override
  String get noData => 'डेटा उपलब्ध नहीं';

  @override
  String get spendingByCategory => 'श्रेणी के अनुसार खर्च';

  @override
  String get noTransactionsInCategory => 'इस श्रेणी में कोई लेन-देन नहीं है।';

  @override
  String get predictiveInsights => 'भविष्य कहनेवाला इनसाइट्स';

  @override
  String get spendingSustainable => 'आपका खर्च टिकाऊ है।';

  @override
  String get budgetBreachProjected => 'बजट उल्लंघन का अनुमान है!';

  @override
  String get currentBurnRate => 'वर्तमान बर्न रेट: ';

  @override
  String burnRatePerDay(String amount) {
    return '$amount/दिन';
  }

  @override
  String get estimate => 'अनुमान';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get resetAll => 'सभी रीसेट करें';

  @override
  String get dateRange => 'तारीख सीमा';

  @override
  String get startDate => 'आरंभ तिथि';

  @override
  String get endDate => 'अंतिम तिथि';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get selectCategory => 'श्रेणी चुनें';

  @override
  String get noCategoriesFound => 'कोई श्रेणी नहीं मिली';

  @override
  String get goalAchieved => 'लक्ष्य प्राप्त';

  @override
  String get addSavingsHint => 'बचत जोड़ने के लिए प्लस आइकन पर टैप करें';

  @override
  String get deleteGoal => 'लक्ष्य हटाएं?';

  @override
  String deleteGoalConfirm(String title) {
    return 'यह स्थायी रूप से \"$title\" को हटा देगा। इस लक्ष्य में बचाई गई कोई भी राशि आपके शेष राशि में वापस कर दी जाएगी।';
  }

  @override
  String get addToSavings => 'बचत में जोड़ें';

  @override
  String get add => 'जोड़ें';

  @override
  String get deleteCustomView => 'कस्टम दृश्य हटाएं';

  @override
  String deleteCustomViewConfirm(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं?';
  }

  @override
  String get saveCurrentView => 'वर्तमान दृश्य सहेजें';

  @override
  String get viewNameHint => 'दृश्य का नाम (जैसे, केवल व्यवसाय)';

  @override
  String entriesCount(int count) {
    return '$count प्रविष्टियां';
  }
}
