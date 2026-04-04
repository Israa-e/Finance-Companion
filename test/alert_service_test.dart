import 'package:finance_companion/data/models/notification_model.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/data/repositories/notification_repository.dart';
import 'package:finance_companion/data/services/alert_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late AlertService alertService;
  late MockNotificationRepository mockRepo;

  setUp(() {
    mockRepo = MockNotificationRepository();
    alertService = AlertService(mockRepo);
  });

  group('AlertService - Budget Thresholds', () {
    final transactions = [
      TransactionModel(
        id: '1',
        userId: 1,
        amount: 85.0,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime.now(),
        title: 'Lunch',
        lastUpdated: DateTime.now(),
      ),
    ];

    test('should NOT trigger alert if below warning threshold', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);
      
      await alertService.checkBudgetAlerts(
        transactions: transactions,
        monthlyBudget: 200.0, // 85/200 = 42.5%
        warningThreshold: 0.8,
        criticalThreshold: 1.0,
      );

      verifyNever(() => mockRepo.add(any()));
    });

    test('should trigger warning alert if above warning threshold', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);
      when(() => mockRepo.add(any())).thenAnswer((_) async => {});

      await alertService.checkBudgetAlerts(
        transactions: transactions,
        monthlyBudget: 100.0, // 85/100 = 85%
        warningThreshold: 0.8,
        criticalThreshold: 1.0,
      );

      verify(() => mockRepo.add(any())).called(1);
    });

    test('should trigger critical alert if above critical threshold', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);
      when(() => mockRepo.add(any())).thenAnswer((_) async => {});

      await alertService.checkBudgetAlerts(
        transactions: transactions,
        monthlyBudget: 80.0, // 85/80 = 106%
        warningThreshold: 0.8,
        criticalThreshold: 1.0,
      );

      verify(() => mockRepo.add(any())).called(1);
    });

    test('should NOT trigger alert if already fired in last 24 hours', () async {
      final recentNotif = NotificationModel(
        id: 'prev',
        title: 'Title',
        body: 'Body',
        type: NotificationType.monthlyBudgetWarning,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      when(() => mockRepo.getAll()).thenAnswer((_) async => [recentNotif]);

      await alertService.checkBudgetAlerts(
        transactions: transactions,
        monthlyBudget: 80.0,
        warningThreshold: 0.8,
        criticalThreshold: 1.0,
      );

      verifyNever(() => mockRepo.add(any()));
    });
  });
}
