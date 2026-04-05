import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finance_companion/firebase_options.dart';
import 'package:finance_companion/data/services/database_helper.dart';
import 'package:finance_companion/data/services/recurring_processor_service.dart';
import 'package:finance_companion/data/repositories/recurring_repository.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';

const String recurringTaskName = "com.finance.recurring_task";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // 1. Initialize Firebase for the background isolate (required for AuthRepository)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      // Already initialized or fails (Local Mode)
    }
    switch (taskName) {
      case recurringTaskName:
        try {
          // Initialize DB
          await DatabaseHelper.instance.database;
          
          final authRepo = AuthRepository();
          
          // 2. Identify the user
          final user = await authRepo.getLoggedInUser();
          if (user == null || user.id == null) return true;

          // 3. Process due recurring transactions
          final recurringRepo = RecurringRepository();
          final txRepo = TransactionRepository();
          final processor = RecurringProcessorService(recurringRepo, txRepo);
          
          final processedCount = await processor.processDue(user.id!);
          
          // Log completion (background mode)
          if (kDebugMode) {
            print("Background Task: Processed $processedCount recurring transactions.");
          }
          
          return true;
        } catch (e) {
          if (kDebugMode) {
            print("Background Task Error: $e");
          }
          return false;
        }
    }
    return true;
  });
}

class BackgroundWorker {
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      // Register the task after initialization
      await registerPeriodicTask();
    } catch (e) {
      // In a test environment or if initialize was already called, 
      // catching this prevents the 'channel-error' PlatformException.
      if (kDebugMode) {
        print("Workmanager: Skipping or failed to initialize ($e)");
      }
    }
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "1", // Unique ID
      recurringTaskName,
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
