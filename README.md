# 💰 Finance Companion

A modern, full-featured personal finance management app built with Flutter.

---

## ✨ Features

- **Dashboard Overview** — Animated balance card with income/expense summary
- **Transaction Tracking** — Add, edit, delete, search, and filter transactions
- **Savings Goals** — Set goals, track progress, top up and withdraw savings
- **Smart Insights** — Pie chart, weekly bar chart, month-over-month comparison, **with time-period filter**
- **No-Spend Streak** — Track consecutive no-expense days with **manual day confirmation**
- **Notifications** — Real spending alerts, goal deadline reminders, streak milestones
- **User Profiles** — Avatar, editable name and starting balance
- **Authentication** — Firebase Auth + local SQLite with session persistence
- **Onboarding** — Animated 3-page onboarding for first-time users
- **Dark / Light Theme** — Full theme support with toggle in profile
- **Offline Support** — SQLite caching with safe per-record sync

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3) |
| State Management | `flutter_bloc` (Cubit pattern) |
| Local Database | `sqflite` |
| Cloud Database | Firebase Firestore |
| Authentication | Firebase Auth |
| Charts | `fl_chart` |
| UI Extras | `iconsax`, `google_fonts`, `gap` |
| Utilities | `uuid`, `intl`, `equatable`, `crypto`, `image_picker` |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants (categories, currency)
│   ├── theme/            # Colors, text styles, light/dark themes
│   └── utils/            # Currency & date formatters
├── data/
│   ├── models/           # UserModel, TransactionModel, GoalModel,
│   │                     # NotificationModel, StreakModel
│   ├── repositories/     # Auth, Transaction, Goal, Notification repositories
│   └── services/         # SQLite DatabaseHelper (v2 schema)
├── logic/
│   ├── auth/             # AuthCubit + AuthState
│   ├── goal/             # GoalCubit + GoalState
│   ├── home/             # StreakCubit (with manual confirmation)
│   ├── insights/         # InsightsCubit + InsightsState (period filter)
│   ├── notifications/    # NotificationCubit + NotificationState
│   ├── theme/            # ThemeCubit
│   └── transaction/      # TransactionCubit + TransactionState
└── presentation/
    ├── screens/
    │   ├── auth/          # Login & Register screens
    │   ├── goals/         # Goals screen + GoalCard widget
    │   ├── home/          # Home screen + widgets
    │   ├── insights/      # Insights screen (with period selector)
    │   ├── notifications/ # Notifications screen (NEW)
    │   ├── onboarding/    # 3-page onboarding
    │   ├── profile/       # Profile screen
    │   ├── splash/        # Animated splash screen
    │   └── transactions/  # Transactions list + Add/Edit screen
    └── shared/
        ├── navigation/    # AuthWrapper + AppNavigation
        └── widgets/       # Reusable: CustomButton, CustomTextField, EmptyState
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.10.7`
- Dart SDK `^3.0`
- Firebase project (see setup below)

### Installation

```bash
git clone https://github.com/Israa-e/Finance-Companion.git
cd finance-companion
flutter pub get
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password) and **Firestore Database**
3. Run `flutterfire configure` to generate `firebase_options.dart`
4. Replace `lib/firebase_options.dart` with your generated file

---

## 🐛 Bug Fixes Applied (v1.1.0)

| # | Issue | Fix |
|---|---|---|
| 1 | Notification bell navigated to Insights (broken UX) | Replaced with real `NotificationsScreen` — spending alerts, goal deadlines, streak milestones |
| 2 | Streak counted all no-transaction days (false positives) | Added manual "Confirm no-spend today" button; days older than 7 days require explicit confirmation |
| 3 | `_SevenDayDots` used untyped `var streak` | Changed to `final StreakModel streak` (explicit type) |
| 4 | `updatedUser` in `EditProfileSheet` was built but never used | Removed dead variable; `updateProfileWithBalance` called directly |
| 5 | `GoalRepository` and `TransactionRepository` used destructive `db.delete()` before syncing | Replaced with safe per-record upsert (`ConflictAlgorithm.replace`) with explicit delete of removed remote records |
| 6 | `AuthRepository._ensureLocalUser` silently swallowed exceptions | Each failure path now throws a descriptive exception; offline fallback is explicit and logged |
| 7 | Insights had no time-period selector | Added `InsightsPeriod` enum (This Month / Last 3 Months / Last 6 Months / All Time) with chip row UI |
| 8 | No meaningful tests | Added 14 unit/widget tests covering formatters, filter logic, grouping, and balance calculation |
| 9 | `DatabaseHelper` had no migration path | Bumped to version 2 with `onUpgrade` handler; adds `notifications` table on existing installs |

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#7C6FFF` (purple) |
| Income | `#2ECC89` (green) |
| Expense | `#FF5063` (red) |
| Savings | `#F5A623` (amber) |
| Font | Poppins (Google Fonts) |
| Border Radius | 12–28px |

---

## 🧪 Running Tests

```bash
flutter test
```

Tests cover:
- App launch smoke test
- `CurrencyFormatter` (6 cases)
- `TransactionLoaded` filter logic (7 cases)
- `groupedTransactions` date grouping (2 cases)

---

## 📄 Assumptions

- The monthly budget for spending alerts defaults to `0` (disabled) until a user-defined budget feature is added. The `NotificationRepository.generateAlertsFromTransactions` method accepts a `monthlyBudget` parameter ready for this.
- The streak "benefit of the doubt" window is 7 days — days within the last week with no logged expenses are counted as no-spend without requiring confirmation. Days older than 7 days require explicit confirmation via the card button.
- Firestore is the source of truth when online. SQLite is the fallback when offline. On reconnection, the next data fetch will re-sync.

---

Made with ❤️ and Flutter