import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mapato/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const _csvHeader = [
  'id',
  'network',
  'direction',
  'amount',
  'balance',
  'counterparty',
  'category',
  'note',
  'timestamp',
  'source',
  'raw',
];

String _csvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _encodeCsv(List<Transaction> txns) {
  final sb = StringBuffer();
  sb.writeln(_csvHeader.join(','));
  for (final t in txns) {
    final row = [
      t.id.toString(),
      t.network,
      t.direction,
      t.amount.toString(),
      t.balance?.toString() ?? '',
      t.counterparty ?? '',
      t.category,
      t.note ?? '',
      t.timestamp.toIso8601String(),
      t.source,
      t.raw ?? '',
    ].map(_csvField).join(',');
    sb.writeln(row);
  }
  return sb.toString();
}

/// Writes the transactions to a CSV file and opens the system share sheet so
/// the user can save it to Drive, send it via WhatsApp, etc.
Future<void> exportTransactionsCsv(List<Transaction> txns) async {
  final csv = _encodeCsv(txns);
  final dir = await getTemporaryDirectory();
  final file = File(p.join(
    dir.path,
    'mapato_transactions_${DateTime.now().millisecondsSinceEpoch}.csv',
  ));
  await file.writeAsString(csv);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    subject: 'Mapato transactions',
    text: 'Mapato transactions export (${txns.length} rows)',
  );
}

/// Minimal RFC-4180-style CSV parser handling quoted fields, escaped quotes
/// and embedded commas / newlines.
List<List<String>> _parseCsv(String content) {
  final rows = <List<String>>[];
  var i = 0;
  final n = content.length;
  while (i < n) {
    final row = <String>[];
    while (i < n) {
      String field;
      if (content[i] == '"') {
        i++;
        final sb = StringBuffer();
        while (i < n) {
          if (content[i] == '"') {
            if (i + 1 < n && content[i + 1] == '"') {
              sb.write('"');
              i += 2;
            } else {
              i++;
              break;
            }
          } else {
            sb.write(content[i]);
            i++;
          }
        }
        field = sb.toString();
      } else {
        final sb = StringBuffer();
        while (i < n && content[i] != ',' && content[i] != '\n' && content[i] != '\r') {
          sb.write(content[i]);
          i++;
        }
        field = sb.toString();
      }
      row.add(field);
      if (i < n && content[i] == ',') {
        i++;
        continue;
      }
      if (i < n && (content[i] == '\n' || content[i] == '\r')) {
        if (content[i] == '\r' && i + 1 < n && content[i + 1] == '\n') i++;
        i++;
        break;
      }
      break;
    }
    if (row.isNotEmpty) rows.add(row);
  }
  return rows;
}

/// Parses previously exported Mapato CSV text into companion rows ready to be
/// inserted. Rows with a bad amount are skipped.
Future<List<TransactionsCompanion>> importTransactionsCsv(String content) async {
  final rows = _parseCsv(content);
  if (rows.length < 2) return [];

  final header = rows.first;
  String get(List<String> row, String name) {
    final idx = header.indexOf(name);
    return (idx >= 0 && idx < row.length) ? row[idx] : '';
  }

  final companions = <TransactionsCompanion>[];
  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    if (row.length < header.length) continue;

    final amount = double.tryParse(get(row, 'amount'));
    if (amount == null || amount <= 0) continue;

    final idStr = get(row, 'id');
    final balance = double.tryParse(get(row, 'balance'));
    final ts = DateTime.tryParse(get(row, 'timestamp')) ?? DateTime.now();

    companions.add(TransactionsCompanion(
      id: idStr.isNotEmpty
          ? Value(int.tryParse(idStr) ?? 0)
          : const Value.absent(),
      network: Value(get(row, 'network').isNotEmpty ? get(row, 'network') : 'unknown'),
      direction: Value(get(row, 'direction') == 'in' ? 'in' : 'out'),
      amount: Value(amount),
      balance: Value(balance),
      counterparty:
          Value(get(row, 'counterparty').isEmpty ? null : get(row, 'counterparty')),
      category: Value(
          get(row, 'category').isNotEmpty ? get(row, 'category') : 'Uncategorized'),
      note: Value(get(row, 'note').isEmpty ? null : get(row, 'note')),
      timestamp: Value(ts),
      source: Value(get(row, 'source').isNotEmpty ? get(row, 'source') : 'notification'),
      raw: Value(get(row, 'raw').isEmpty ? null : get(row, 'raw')),
    ));
  }
  return companions;
}

/// Opens the system file picker for a Mapato CSV and returns its text content,
/// or null if the user cancelled.
Future<String?> pickCsvFile() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result == null || result.isEmpty) return null;
  final bytes = await result.first.readAsBytes();
  return utf8.decode(bytes);
}
