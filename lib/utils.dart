import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/theme.dart';

final _fmt = NumberFormat('#,##0', 'en_US');

String tzs(double value) => 'Tsh ${_fmt.format(value.round())}';

/// English → Swahili category name translation.
const Map<String, String> _categorySw = {
  'Incoming': 'Mapato',
  'Uncategorized': 'Haijachaguliwa',
  'Food': 'Chakula',
  'Transport': 'Usafiri',
  'Shopping': 'Manunuzi',
  'Bills': 'Bili',
  'Rent': 'Kodi',
  'Airtime': 'Piga Simu',
  'Internet': 'Mtandao',
  'Education': 'Elimu',
  'Health': 'Afya',
  'Entertainment': 'Burudani',
  'Family': 'Familia',
  'Savings': 'Akiba',
  'Business': 'Biashara',
  'Salary': 'Mshahara',
  'Other': 'Nyingine',
};

/// Localized category name. Falls back to the original English name.
String localizedCategoryName(String name, BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'sw') return _categorySw[name] ?? name;
  return name;
}

/// Category names that represent money moving into savings (your own money,
/// treated separately from income/spending).
const Set<String> _savingsCategoryNames = {
  'Savings',
  'Investment',
  'Investments',
};

/// Category names that unambiguously represent money coming in (income).
const Set<String> _incomeCategoryNames = {
  'Incoming',
  'Salary',
};

/// Returns the transaction direction ('in', 'out' or 'transfer') implied by a
/// category name. Used to pre-select the Spent/Received/Saved toggle when a
/// category is picked in the Add screen.
String categoryDirection(String name) {
  final trimmed = name.trim();
  if (_savingsCategoryNames.contains(trimmed)) return 'transfer';
  if (_incomeCategoryNames.contains(trimmed)) return 'in';
  const keywords = [
    'income',
    'salary',
    'incoming',
    'earn',
    'refund',
    'grant',
    'dividend',
    'interest',
    'wage',
    'payout',
  ];
  final lower = trimmed.toLowerCase();
  for (final k in keywords) {
    if (lower.contains(k)) return 'in';
  }
  return 'out';
}

/// Visual colour for a transaction direction.
Color directionColor(String direction) {
  switch (direction) {
    case 'in':
      return AppColors.income;
    case 'transfer':
      return AppColors.savings;
    default:
      return AppColors.expense;
  }
}

/// Human label for a transaction direction.
String directionLabel(String direction, {BuildContext? context}) {
  final s = context != null ? AppLocalizations.of(context) : null;
  switch (direction) {
    case 'in':
      return s?.directionReceived ?? 'Received';
    case 'transfer':
      return s?.directionSaved ?? 'Saved';
    default:
      return s?.directionSpent ?? 'Spent';
  }
}
