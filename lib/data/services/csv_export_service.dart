import 'dart:io';
import 'package:csv/csv.dart';
import 'package:finance_companion/data/models/transaction_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CSVExportService {
  static Future<void> exportTransactions(List<TransactionModel> transactions) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Title', 'Type', 'Category', 'Amount', 'Note']
    ];

    for (var t in transactions) {
      rows.add([
        t.date.toIso8601String(),
        t.title,
        t.type.name,
        t.category,
        t.amount,
        t.note ?? ''
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final Directory directory = await getTemporaryDirectory();
    final String path = '${directory.path}/transactions_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Exported Transactions');
  }
}
