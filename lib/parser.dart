import 'package:drift/drift.dart';
import 'package:mapato/database.dart';

/// Supported Tanzanian mobile money networks.
const Map<String, String> packageToNetwork = {
  // Mobile money
  'com.vodacom.mpesa': 'mpesa',
  'tz.tigo.mfsapp': 'mixx',
  'com.tigo.pesa': 'mixx',
  'com.airtel.money': 'airtel',
  'com.halopesa.eu': 'halo',
  'tz.co.halo.halopesa': 'halo',
  'com.azampesa': 'azam',
  // Banks
  'com.crdbbank': 'CRDB',
  'com.nmb.bank': 'NMB',
  'com.ttb.mobilebanking': 'TTB',
  'com.stanbicbank.tz': 'Stanbic',
  'com.nbcbank': 'NBC',
  'com.absa.link': 'Absa',
  'com.eximbank': 'Exim',
  'com.kcbgroup.tz': 'KCB',
  'com.diamondtrustbank': 'DTB',
  'com.azaniabank': 'Azania',
  'com.akibabank': 'Akiba',
  'com.tib.co.tz': 'TIB',
};

class ParsedTransaction {
  final String network;
  final String direction; // 'in' | 'out'
  final double amount;
  final double? balance;
  final String? counterparty;
  final String raw;

  ParsedTransaction({
    required this.network,
    required this.direction,
    required this.amount,
    this.balance,
    this.counterparty,
    required this.raw,
  });

  TransactionsCompanion toCompanion() {
    final category = direction == 'transfer'
        ? 'Savings'
        : (direction == 'in' ? 'Incoming' : 'Uncategorized');
    return TransactionsCompanion.insert(
      network: Value(network),
      direction: direction,
      amount: amount,
      balance: Value(balance),
      counterparty: Value(counterparty),
      category: Value(category),
      source: const Value('notification'),
      raw: Value(raw),
    );
  }
}

final _amountReg = RegExp(
  r'(?:TZS|TSH)\s*([\d,]+(?:\.\d+)?)|([\d,]+(?:\.\d+)?)\s*(?:TZS|TSH)',
  caseSensitive: false,
);

double? _parseAmount(String text) {
  final m = _amountReg.firstMatch(text);
  if (m == null) return null;
  final raw = (m.group(1) ?? m.group(2))!.replaceAll(',', '');
  return double.tryParse(raw);
}

double? _parseBalance(String text) {
  // e.g. "Salio ya M-Pesa ni TZS 12,345" or "balance is TZS 1,234"
  final m = RegExp(
    r'salio[^TZS]*?(?:TZS|TSH)\s*([\d,]+(?:\.\d+)?)|balance[^TZS]*?(?:TZS|TSH)\s*([\d,]+(?:\.\d+)?)',
    caseSensitive: false,
  ).firstMatch(text);
  if (m == null) return null;
  final raw = (m.group(1) ?? m.group(2))!.replaceAll(',', '');
  return double.tryParse(raw);
}

String _detectNetwork(String text, String? package) {
  if (package != null && packageToNetwork.containsKey(package)) {
    return packageToNetwork[package]!;
  }
  final t = text.toLowerCase();
  // Mobile money
  if (t.contains('mixx') || t.contains('yas') || t.contains('tigo')) return 'mixx';
  if (t.contains('airtel')) return 'airtel';
  if (t.contains('halo')) return 'halo';
  if (t.contains('azam')) return 'azam';
  if (t.contains('mpesa') || t.contains('m-pesa')) return 'mpesa';
  // Banks
  if (t.contains('crdb')) return 'CRDB';
  if (t.contains('nmb')) return 'NMB';
  if (t.contains('ttb')) return 'TTB';
  if (t.contains('stanbic')) return 'Stanbic';
  if (t.contains('nbc')) return 'NBC';
  if (t.contains('absa')) return 'Absa';
  if (t.contains('exim')) return 'Exim';
  if (t.contains('kcb')) return 'KCB';
  if (t.contains('dtb') || t.contains('diamond trust')) return 'DTB';
  if (t.contains('azania')) return 'Azania';
  if (t.contains('akiba')) return 'Akiba';
  if (t.contains('tib')) return 'TIB';
  return 'unknown';
}

String _detectDirection(String text) {
  final t = text.toLowerCase();
  // Money coming TO you.
  final incoming = [
    'pokea', 'kupokea', 'imepokea', 'umepokea', 'mepokea',
    'received', 'have received', 'incoming',
    'ingia', 'kuingia', 'ingizia', 'imeingia',
    'kukutumia', // "X kukutumia" — X sent you
    'sent you', 'sent yu',
    'kupewa', 'umepewa', 'kupewa',
    'imedalia', 'amedalia', // deposit/credit to you
    'receipt', 'credit', 'credited',
    'inflow', 'inflows',
    'has been credited', 'has been deposited',
  ];
  // Money leaving YOU. Note: bare "sent" is ambiguous, so only treat as
  // outgoing when it clearly refers to you sending (e.g. "you sent",
  // "sent money", "has been sent to").
  final outgoing = [
    'umetuma', 'tuma', 'ulituma', 'metuma',
    'you sent', 'sent money', 'has been sent to', 'been sent to',
    'umelipa', 'lipa', 'ulilipia', 'lipia', 'lipa mdogo',
    'toa', 'ametoa', 'metoa', 'withdraw', 'withdrawal',
    'lima', 'paid', 'paybill', 'debit', 'debited',
    'outflow', 'outflows',
    'has been debited', 'has been deducted',
  ];
  if (incoming.any((w) => t.contains(w))) return 'in';
  if (outgoing.any((w) => t.contains(w))) return 'out';
  // Unclear: a real transaction was detected but no direction signal.
  // Default to incoming so a received transfer is not silently lost as an
  // expense (the user can fix it manually in Add/Transactions).
  return 'in';
}

String? _detectCounterparty(String text) {
  // 1. "kwa [Name]" — Swahili pattern
  final m1 = RegExp(r"kwa\s+([A-Z][A-Za-z .'-]{2,30})").firstMatch(text);
  if (m1 != null) {
    var name = m1.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  // 2. "from [Name]" — English incoming
  final m2 = RegExp(r"from\s+([A-Z][A-Za-z .'-]{2,30})").firstMatch(text);
  if (m2 != null) {
    var name = m2.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  // 3. "to [Name]" — English outgoing
  final m3 = RegExp(r"to\s+([A-Z][A-Za-z .'-]{2,30})").firstMatch(text);
  if (m3 != null) {
    var name = m3.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  // 4. "kutoka [Name]" / "kwenda [Name]" — Swahili
  final m4 = RegExp(r"kutoka\s+([A-Z][A-Za-z .'-]{2,30})").firstMatch(text);
  if (m4 != null) {
    var name = m4.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  final m5 = RegExp(r"kwenda\s+([A-Z][A-Za-z .'-]{2,30})").firstMatch(text);
  if (m5 != null) {
    var name = m5.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  // 5. "Jina: [Name]" — Tanzanian receipt format
  final m6 = RegExp(r"jina[:\s]+([A-Z][A-Za-z .'-]{2,30})", caseSensitive: false).firstMatch(text);
  if (m6 != null) {
    var name = m6.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  // 6. Phone number: +255 712 345 678 or 0712 345 678
  final m7 = RegExp(r"(\+?255[\d\s-]{9,13}|0\d{2,3}[\s-]?\d{3}[\s-]?\d{4})").firstMatch(text);
  if (m7 != null) {
    return m7.group(1)!.trim();
  }
  // 7. "Name: [Name]" — generic label
  final m8 = RegExp(r"name[:\s]+([A-Z][A-Za-z .'-]{2,30})", caseSensitive: false).firstMatch(text);
  if (m8 != null) {
    var name = m8.group(1)!.trim();
    name = name.replaceFirst(RegExp(r'[.,].*$'), '').trim();
    if (name.isNotEmpty) return name;
  }
  return null;
}

/// Words/phrases that indicate a genuine mobile-money transaction message.
/// An amount alone (e.g. "TSH 5000 for lunch?") is NOT treated as a transaction.
const _txnSignals = [
  'pokea', 'kupokea', 'ingia', 'kuingia', 'ingizia', 'imeningia', 'imeingia',
  'received', 'incoming',
  'tuma', 'lipa', 'lipia', 'kulipia', 'toa', 'kutoa', 'lima',
  'sent', 'paid', 'paybill', 'pay bill', 'lipa mdogo',
  'withdraw', 'withdrawal', 'deposit', 'transfer', 'cash',
  'salio', 'balance',
  'malipo', 'miamala', 'muamala', 'transaction', 'payment',
  // Bank signals
  'credit', 'credited', 'debit', 'debited',
  'inflow', 'outflow', 'deducted',
  'account', 'akaunti',
];

bool _looksLikeTransaction(String text) {
  final t = text.toLowerCase();
  return _txnSignals.any((w) => t.contains(w));
}

/// Returns null when the text is not a recognizable mobile-money transaction.
ParsedTransaction? parseMessage(String text, {String? packageName}) {
  // Require a real transaction signal so generic "TSH 5000" text is ignored.
  if (!_looksLikeTransaction(text)) return null;

  final amount = _parseAmount(text);
  if (amount == null) return null;

  final network = _detectNetwork(text, packageName);
  return ParsedTransaction(
    network: network,
    direction: _detectDirection(text),
    amount: amount,
    balance: _parseBalance(text),
    counterparty: _detectCounterparty(text),
    raw: text,
  );
}
