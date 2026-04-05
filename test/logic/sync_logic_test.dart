import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:finance_companion/data/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {


  group('Sync Logic Tests', () {
    setUp(() {});

    test('TransactionModel should correctly handle isSynced flag', () {
      final now = DateTime(2023, 1, 1, 10, 30);
      final t = TransactionModel(
        id: '1',
        userId: 1,
        amount: 100.0,
        type: TransactionType.expense,
        category: 'Food',
        date: now,
        title: 'Lunch',
        lastUpdated: now,
        isSynced: false,
      );

      final map = t.toMap();
      expect(map['isSynced'], 0);
      expect(map['userId'], 1);

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.isSynced, false);
      expect(fromMap.id, '1');
    });


  });
}
