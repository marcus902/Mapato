import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:mapato/database.dart';
import 'package:mapato/native.dart';
import 'package:mapato/parser.dart';
import 'package:mapato/export_import.dart';
import 'package:mapato/categories_defaults.dart';
import 'package:mapato/security.dart';
import 'package:mapato/theme.dart';
import 'package:mapato/utils.dart';

const _channel = EventChannel('tz.mapato/notifications');

class AppState extends ChangeNotifier {
  final AppDatabase db = AppDatabase();

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Color categoryColor(String name) {
    final c = _categories.where((e) => e.name == name).firstOrNull;
    if (c != null) return Color(c.color);
    return _fallbackCategoryColor(name);
  }

  IconData categoryIcon(String name) {
    final c = _categories.where((e) => e.name == name).firstOrNull;
    if (c != null) return IconData(c.icon, fontFamily: 'MaterialIcons');
    return Icons.label_outline;
  }

  final _fallbackPalette = const [
    Colors.amber,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
    Colors.blueGrey,
    Colors.lime,
  ];

  Color _fallbackCategoryColor(String name) {
    if (name.isEmpty) return Colors.grey;
    var h = 0;
    for (final r in name.runes) {
      h = (h * 31 + r) & 0x7fffffff;
    }
    return _fallbackPalette[h % _fallbackPalette.length];
  }

  Future<void> addCategory(String name, int color, int icon) async {
    await db.insertCategory(CategoriesCompanion.insert(
      name: name,
      color: color,
      icon: icon,
    ));
    await _load();
  }

  Future<void> editCategory(int id, String name, int color, int icon) async {
    await db.updateCategory(CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
    ));
    await _load();
  }

  Future<void> removeCategory(int id) async {
    // Find the category name being deleted so we can reassign its
    // transactions to "Other" instead of leaving them dangling.
    final cat = categories.where((c) => c.id == id).firstOrNull;
    if (cat != null) {
      final fallback =
          categories.where((c) => c.name == 'Other' && c.id != id).firstOrNull ??
              categories.where((c) => c.id != id).firstOrNull;
      if (fallback != null) {
        await db.reassignCategory(cat.name, fallback.name);
      }
    }
    await db.deleteCategory(id);
    await _load();
  }

  // Recent raw captured texts (notification or SMS) — used by the Parser Lab.
  final List<String> capturedRaw = [];

  int? _lastCapturedId;
  int? get lastCapturedId => _lastCapturedId;

  void _pushRaw(String text) {
    capturedRaw.insert(0, text);
    if (capturedRaw.length > 100) capturedRaw.removeLast();
    notifyListeners();
  }

  bool _listening = false;

  AppState() {
    _loadTheme();
    _loadLocale();
    _init();
  }

  Future<void> _init() async {
    await _loadPinSettings();
    await _load();
  }

  // --- App lock (optional PIN) ---
  bool _pinEnabled = false;
  bool get pinEnabled => _pinEnabled;

  bool _pinReady = true;
  bool get pinReady => _pinReady;

  // Runtime-only flag: whether the PIN has been satisfied this session.
  bool pinUnlocked = false;

  String? _pinHash;

  Future<void> _loadPinSettings() async {
    final results = await Future.wait([
      getPrefBool('app_pin_enabled'),
      getPrefString('app_pin_hash'),
    ]);
    _pinEnabled = results[0] as bool;
    _pinHash = results[1] as String;
    _pinReady = true;
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    _pinHash = hashPin(pin);
    await setPrefString('app_pin_hash', _pinHash!);
    _pinEnabled = true;
    await setPrefBool('app_pin_enabled', true);
    pinUnlocked = true;
    notifyListeners();
  }

  Future<void> disablePin() async {
    _pinHash = null;
    await setPrefString('app_pin_hash', '');
    _pinEnabled = false;
    await setPrefBool('app_pin_enabled', false);
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final stored = _pinHash ?? await getPrefString('app_pin_hash');
    return verifyPinHash(pin, stored);
  }

  /// Require the PIN again (e.g. when the app returns from the background).
  void relock() {
    if (_pinEnabled && pinUnlocked) {
      pinUnlocked = false;
      notifyListeners();
    }
  }

  void unlock() {
    pinUnlocked = true;
    notifyListeners();
  }

  // --- Theme (light / dark) ---
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    getPrefString('theme_mode', 'light').then((v) {
      final next = _modeFromString(v);
      if (next != _themeMode) {
        _themeMode = next;
        notifyListeners();
      }
    });
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    setPrefString('theme_mode', _modeToString(mode));
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  ThemeMode _modeFromString(String v) {
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _modeToString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  Future<void> _load() async {
    _transactions = await db.all();
    _categories = await db.allCategories();
    if (_categories.isEmpty) {
      await db.seedCategories(defaultCategories);
      _categories = await db.allCategories();
    }
    notifyListeners();
  }

  Future<void> refresh() => _load();

  /// Start listening to mobile-money notifications from the native service.
  void startNotificationCapture() {
    if (_listening) return;
    _listening = true;
    _channel.receiveBroadcastStream().listen((event) {
      if (event is! String) return;
      _pushRaw(event);
      final parsed = parseMessage(event);
      if (parsed == null) return;
      _insert(parsed.toCompanion());
    }, onError: (_) {/* permission missing or service not enabled */});
  }

  Future<void> _insert(TransactionsCompanion c) async {
    // Drop duplicate captures from the same raw text (listener restart).
    if (c.raw.present && c.raw.value != null) {
      final dup = await db.hasRawSince(
        c.raw.value!,
        DateTime.now().subtract(const Duration(hours: 24)),
      );
      if (dup) return;
    }
    // Drop duplicates when both notification + SMS capture the same
    // transaction (same amount, network, direction within 30 minutes).
    if (c.amount.present && c.network.present && c.direction.present) {
      final dup = await db.hasDuplicate(
        c.amount.value,
        c.network.value,
        c.direction.value,
        const Duration(minutes: 30),
      );
      if (dup) return;
      // Also catch same amount + direction across different networks
      // (e.g., HaloPesa notification + bank SMS for the same payment).
      final dupLoose = await db.hasDuplicateLoose(
        c.amount.value,
        c.direction.value,
        const Duration(minutes: 30),
      );
      if (dupLoose) return;
    }
    final id = await db.insertTx(c);
    _lastCapturedId = id;
    await _load();
    final tx = await db.byId(id);
    if (tx != null) {
      final who = tx.counterparty != null ? ' • ${tx.counterparty}' : '';
      final sign = tx.direction == 'transfer'
          ? ''
          : (tx.direction == 'in' ? '+' : '-');
      final body =
          '$sign${tzs(tx.amount)} • ${networkLabel(tx.network)}$who';
      await notifyTransaction('Mapato', body);
    }
  }

  /// Manual entry from the Add screen.
  Future<void> addManual({
    required String direction,
    required double amount,
    required String category,
    String? counterparty,
    String? note,
    required String network,
  }) {
    return _insert(TransactionsCompanion.insert(
      network: Value(network),
      direction: direction,
      amount: amount,
      counterparty: Value(counterparty),
      category: Value(category),
      note: Value(note),
      source: const Value('manual'),
    ));
  }

  Future<void> deleteTx(int id) async {
    await db.deleteTx(id);
    await _load();
  }

  Future<void> deleteMany(List<int> ids) async {
    for (final id in ids) {
      await db.deleteTx(id);
    }
    await _load();
  }

  /// Imports rows parsed from CSV text and merges them into the database.
  /// Returns the number of rows imported.
  Future<int> importCsv(String content) async {
    final companions = await importTransactionsCsv(content);
    if (companions.isEmpty) return 0;
    await db.insertMany(companions);
    await _load();
    return companions.length;
  }

  /// Saves an edited transaction (replaces all of its columns).
  Future<void> saveTx(TransactionsCompanion c) async {
    await db.updateTx(c);
    await _load();
  }

  double get totalIn => _transactions
      .where((t) => t.direction == 'in')
      .fold(0.0, (s, t) => s + t.amount);

  double get totalOut => _transactions
      .where((t) => t.direction == 'out')
      .fold(0.0, (s, t) => s + t.amount);

  double get net => totalIn - totalOut;

  // --- Locale ---
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void _loadLocale() {
    getPrefString('language_code', '').then((v) {
      if (v.isNotEmpty && _locale.languageCode != v) {
        _locale = Locale(v);
        notifyListeners();
      }
    });
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await setPrefString('language_code', locale.languageCode);
    notifyListeners();
  }
}
