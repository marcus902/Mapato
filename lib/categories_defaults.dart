import 'package:flutter/material.dart';

/// A plain holder for a category seed (used to populate built-in categories
/// on first run). [color] is an ARGB int, [icon] a Material icon codepoint.
class CategorySeed {
  final String name;
  final int color;
  final int icon;
  CategorySeed(this.name, this.color, this.icon);
}

/// Built-in categories. Custom categories are added by the user on top of these.
final List<CategorySeed> defaultCategories = [
  CategorySeed('Incoming', 0xFF16A34A, Icons.arrow_downward_rounded.codePoint),
  CategorySeed('Uncategorized', 0xFF94A3B8, Icons.help_outline.codePoint),
  CategorySeed('Food', 0xFFF59E0B, Icons.restaurant.codePoint),
  CategorySeed('Transport', 0xFF0EA5E9, Icons.directions_bus.codePoint),
  CategorySeed('Shopping', 0xFFEC4899, Icons.shopping_bag.codePoint),
  CategorySeed('Bills', 0xFF8B5CF6, Icons.receipt_long.codePoint),
  CategorySeed('Rent', 0xFFB45309, Icons.home.codePoint),
  CategorySeed('Airtime', 0xFF14B8A6, Icons.phone_android.codePoint),
  CategorySeed('Internet', 0xFF06B6D4, Icons.wifi.codePoint),
  CategorySeed('Education', 0xFF6366F1, Icons.school.codePoint),
  CategorySeed('Health', 0xFFEF4444, Icons.favorite.codePoint),
  CategorySeed('Entertainment', 0xFFF97316, Icons.movie.codePoint),
  CategorySeed('Family', 0xFFDB2777, Icons.people.codePoint),
  CategorySeed('Savings', 0xFF16A34A, Icons.savings.codePoint),
  CategorySeed('Business', 0xFF475569, Icons.business.codePoint),
  CategorySeed('Salary', 0xFF0B7A45, Icons.account_balance_wallet.codePoint),
  CategorySeed('Other', 0xFF64748B, Icons.category.codePoint),
];
