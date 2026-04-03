# 💰 Finance Companion

A modern, full-featured personal finance management app built with Flutter. Track your income, expenses, and savings goals — all with a beautiful, intuitive UI.

---

## ✨ Features

- **Dashboard Overview** — Animated balance card with income/expense summary and mini donut chart
- **Transaction Tracking** — Add, edit, delete, and search income/expense transactions with category filters
- **Savings Goals** — Set goals with emoji, track progress, and top up or withdraw savings
- **Smart Insights** — Pie chart breakdown by category, weekly bar chart, and month-over-month comparison
- **User Profiles** — Avatar, editable name, and starting balance support
- **Authentication** — Firebase Auth + local SQLite with session persistence
- **Onboarding** — Animated 3-page onboarding for first-time users
- **Splash Screen** — Polished animated launch screen
- **Dark / Light Theme** — Full theme support with toggle in profile
- **Offline Support** — SQLite caching so the app works without internet

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
│   ├── models/           # UserModel, TransactionModel, GoalModel
│   ├── repositories/     # Auth, Transaction, Goal repositories
│   └── services/         # SQLite DatabaseHelper
├── logic/
│   ├── auth/             # AuthCubit + AuthState
│   ├── goal/             # GoalCubit + GoalState
│   ├── insights/         # InsightsCubit + InsightsState
│   ├── theme/            # ThemeCubit
│   └── transaction/      # TransactionCubit + TransactionState
└── presentation/
    ├── screens/
    │   ├── auth/          # Login & Register screens
    │   ├── goals/         # Goals screen + GoalCard widget
    │   ├── home/          # Home screen + widgets (BalanceCard, WeeklyChart, etc.)
    │   ├── insights/      # Insights screen
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
# Clone the repository
git clone https://github.com/Israa-e/Finance-Companion.git
cd finance-companion

# Install dependencies
flutter pub get

# Run on device or emulator
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password) and **Firestore Database**
3. Run `flutterfire configure` to generate `firebase_options.dart`
4. Replace the existing `lib/firebase_options.dart` with your generated file

---

## 📱 App Icon

To update the app icon:

1. Add your icon file at `assets/images/app_icon.png` (1024×1024 px, no transparency for iOS)
2. Add `flutter_launcher_icons` to `dev_dependencies` in `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/images/app_icon.png"
   ```
3. Run:
   ```bash
   dart run flutter_launcher_icons
   ```

---

## 🐛 Known Issues & Fixes

| Issue | Fix Applied |
|---|---|
| `userId` not set on new transactions | `TransactionCubit.setUser()` called after login/register |
| Balance includes `initialBalance` correctly | `balance = initialBalance + income - expense` |
| Firestore offline fallback | SQLite cache synced on every remote fetch |
| `withOpacity` deprecation warnings | Replaced with `withValues(alpha:)` throughout |

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#7C6FFF` (purple) |
| Income | `#2ECC89` (green) |
| Expense | `#FF5063` (red) |
| Savings | `#F5A623` (amber) |
| Card BG (light) | `#FFFFFF` |
| Background (light) | `#F8F9FE` |
| Font | Poppins / DM Sans (Google Fonts) |
| Border Radius | 12–28px |

---

## 📄 License

This project is for educational and personal use. Feel free to fork and build on it!

---

Made with ❤️ and Flutter