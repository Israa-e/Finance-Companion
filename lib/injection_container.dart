import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/logic/transaction/transaction_filter_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_action_cubit.dart';
import 'package:finance_companion/logic/transaction/transaction_form_cubit.dart';
import 'package:finance_companion/logic/goal/goal_cubit.dart';
import 'package:finance_companion/logic/insights/insights_cubit.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:finance_companion/data/repositories/goal_repository.dart';
import 'package:finance_companion/data/repositories/category_repository.dart';
import 'package:finance_companion/data/repositories/recurring_repository.dart';
import 'package:finance_companion/data/repositories/transaction_view_repository.dart';
import 'package:finance_companion/logic/locale/locale_cubit.dart';
import 'package:finance_companion/logic/theme/theme_cubit.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:finance_companion/data/services/recurring_processor_service.dart';

import 'package:finance_companion/data/repositories/notification_repository.dart';
import 'package:finance_companion/data/services/alert_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Features ──────────────────────────────────────────────────────────────
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<TransactionRepository>(() => TransactionRepository());
  sl.registerLazySingleton<GoalRepository>(() => GoalRepository());
  sl.registerFactory(() => TransactionFilterCubit(sl(), sl()));
  sl.registerFactory(() => TransactionActionCubit(sl(), sl()));
  sl.registerFactory(() => TransactionFormCubit());
  sl.registerFactory(() => GoalCubit(sl(), sl(), sl()));
  sl.registerFactory(() => InsightsCubit(sl()));
  sl.registerFactory(() => LocaleCubit(sl()));
  sl.registerFactory(() => ThemeCubit(sl()));
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepository());
  sl.registerLazySingleton<RecurringRepository>(() => RecurringRepository());
  sl.registerLazySingleton<TransactionViewRepository>(() => TransactionViewRepository());
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepository());

  // Services
  sl.registerLazySingleton<RecurringProcessorService>(
    () => RecurringProcessorService(sl(), sl()),
  );
  sl.registerLazySingleton<AlertService>(() => AlertService(sl()));

  // ── External ──────────────────────────────────────────────────────────────
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => DatabaseHelper.instance);
}
