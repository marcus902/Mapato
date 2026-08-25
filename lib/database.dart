import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mapato/categories_defaults.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  // mpesa | tigo | airtel | halo | azam | manual
  TextColumn get network =>
      text().withDefault(const Constant('unknown'))();

  // 'in' | 'out'
  TextColumn get direction => text()();

  RealColumn get amount => real()();

  RealColumn get balance => real().nullable()();

  TextColumn get counterparty => text().nullable()();

  TextColumn get category =>
      text().withDefault(const Constant('Uncategorized'))();

  TextColumn get note => text().nullable()();

  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();

  // 'notification' | 'manual'
  TextColumn get source =>
      text().withDefault(const Constant('notification'))();

  TextColumn get raw => text().nullable()();
}

/// User-managed (and built-in default) categories with a custom color + icon.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().unique()();

  /// ARGB color int.
  IntColumn get color => integer()();

  /// Material icon codepoint.
  IntColumn get icon => integer()();
}

@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(categories);
          }
        },
      );

  Future<List<Transaction>> all() =>
      (select(transactions)
            ..orderBy([
              (t) => OrderingTerm.desc(t.timestamp),
            ]))
          .get();

  Future<List<Transaction>> recent(int limit) =>
      (select(transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .get();

  Future<int> insertTx(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  /// Inserts many rows, replacing any existing row with the same id so a
  /// re-import of an export is idempotent.
  Future<void> insertMany(List<TransactionsCompanion> entries) => batch((b) =>
      b.insertAll(transactions, entries, mode: InsertMode.insertOrReplace));

  Future<Transaction?> byId(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// True if a transaction with the same raw text exists since [since].
  /// Used to drop duplicate captures (e.g. when the listener restarts).
  Future<bool> hasRawSince(String raw, DateTime since) =>
      (select(transactions)
            ..where((t) => t.raw.equals(raw) & t.timestamp.isBiggerThanValue(since)))
          .get()
          .then((rows) => rows.isNotEmpty);

  /// True if a transaction with the same amount, network, and direction exists
  /// within [window]. Used to prevent duplicates from both notification + SMS
  /// capturing the same transaction.
  Future<bool> hasDuplicate(
      double amount, String network, String direction, Duration window) {
    final since = DateTime.now().subtract(window);
    return (select(transactions)
          ..where((t) =>
              t.amount.equals(amount) &
              t.network.equals(network) &
              t.direction.equals(direction) &
              t.timestamp.isBiggerThanValue(since)))
        .get()
        .then((rows) => rows.isNotEmpty);
  }

  /// True if a duplicate exists by amount + direction within [window],
  /// regardless of network. Catches the same payment showing up from
  /// both the MNO app and the bank app.
  Future<bool> hasDuplicateLoose(
      double amount, String direction, Duration window) {
    final since = DateTime.now().subtract(window);
    return (select(transactions)
          ..where((t) =>
              t.amount.equals(amount) &
              t.direction.equals(direction) &
              t.timestamp.isBiggerThanValue(since)))
        .get()
        .then((rows) => rows.isNotEmpty);
  }

  /// Replaces every column of the row identified by the companion's id.
  Future<void> updateTx(TransactionsCompanion entry) =>
      update(transactions).replace(entry);

  Future<void> deleteTx(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<List<Category>> allCategories() => select(categories).get();

  Future<void> seedCategories(List<CategorySeed> seeds) => batch((b) =>
      b.insertAll(
        categories,
        seeds.map((s) => CategoriesCompanion.insert(
              name: s.name,
              color: s.color,
              icon: s.icon,
            )),
        mode: InsertMode.insertOrIgnore,
      ));

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry, mode: InsertMode.insertOrIgnore);

  Future<void> updateCategory(CategoriesCompanion entry) =>
      (update(categories)..where((c) => c.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  /// Reassign transactions that used [from] to [to] (used before deletion so
  /// no transaction is left with a dangling category).
  Future<void> reassignCategory(String from, String to) =>
      (update(transactions)..where((t) => t.category.equals(from)))
          .write(TransactionsCompanion(category: Value(to)));

  /// Spend per category for a given month (direction = 'out').
  Future<List<CategorySum>> spendByCategory(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return (select(transactions)
          ..where((t) =>
              t.direction.equals('out') &
              t.timestamp.isBiggerOrEqualValue(start) &
              t.timestamp.isSmallerThanValue(end)))
        .watch()
        .first
        .then((rows) {
      final map = <String, double>{};
      for (final r in rows) {
        map[r.category] = (map[r.category] ?? 0) + r.amount;
      }
      return map.entries
          .map((e) => CategorySum(e.key, e.value))
          .toList()
        ..sort((a, b) => b.total.compareTo(a.total));
    });
  }
}

class CategorySum {
  final String category;
  final double total;
  CategorySum(this.category, this.total);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mapato.sqlite'));
    return NativeDatabase(file);
  });
}
