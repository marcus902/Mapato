import 'package:flutter/material.dart';

/// Brand design tokens for Mapato.
class AppColors {
  static const primary = Color(0xFF0B7A45);
  static const primaryDark = Color(0xFF075C34);
  static const accent = Color(0xFFF2A900); // Tanzanite gold
  static const income = Color(0xFF16A34A);
  static const expense = Color(0xFFE11D48);
  static const savings = Color(0xFF0D9488); // teal — your own money moving pots
  static const bg = Color(0xFFF5F8F6);
  static const surface = Colors.white;
  static const ink = Color(0xFF0F1B16);
  static const inkSoft = Color(0xFF5B6B63);
}

/// Brand gradient used on hero cards.
const Gradient brandGradient = LinearGradient(
  colors: [Color(0xFF0E8A4F), Color(0xFF1FB36B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Per-network brand colors.
const Map<String, Color> networkColors = {
  'mpesa': Color(0xFF0B7A45),
  'mixx': Color(0xFFE11D48),
  'airtel': Color(0xFFD4001A),
  'halo': Color(0xFF7C3AED),
  'azam': Color(0xFF0EA5E9),
  'manual': Color(0xFF64748B),
  'unknown': Color(0xFF94A3B8),
};

/// Friendly display names for networks.
const Map<String, String> networkLabels = {
  'mpesa': 'M-Pesa',
  'mixx': 'Mixx by Yas',
  'airtel': 'Airtel Money',
  'halo': 'HaloPesa',
  'azam': 'AzamPesa',
  'manual': 'Manual',
  'unknown': 'Unknown',
};

/// Category colors used across charts and chips.
const Map<String, Color> categoryColors = {
  'Food': Color(0xFFF59E0B),
  'Transport': Color(0xFF0EA5E9),
  'Bills': Color(0xFF8B5CF6),
  'Shopping': Color(0xFFEC4899),
  'Airtime': Color(0xFF14B8A6),
  'Health': Color(0xFFEF4444),
  'Education': Color(0xFF6366F1),
  'Savings': Color(0xFF16A34A),
  'Incoming': Color(0xFF16A34A),
  'Uncategorized': Color(0xFF94A3B8),
};

Color categoryColor(String c) {
  if (categoryColors.containsKey(c)) return categoryColors[c]!;
  // Deterministic fallback for custom categories not loaded from the DB.
  const palette = [
    Color(0xFFF59E0B),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
    Color(0xFF6366F1),
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFFB45309),
    Color(0xFFDB2777),
    Color(0xFF475569),
    Color(0xFF0B7A45),
  ];
  if (c.isEmpty) return const Color(0xFF94A3B8);
  var h = 0;
  for (final r in c.runes) {
    h = (h * 31 + r) & 0x7fffffff;
  }
  return palette[h % palette.length];
}

Color networkColor(String n) => networkColors[n] ?? networkColors['unknown']!;

String networkLabel(String n) => networkLabels[n] ?? n;

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    secondary: AppColors.accent,
    brightness: Brightness.light,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE6ECE9), width: 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.bg,
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: const TextStyle(color: AppColors.ink),
      secondaryLabelStyle: const TextStyle(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6ECE9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6ECE9)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

ThemeData buildDarkTheme() {
  const surface = Color(0xFF16201B);
  const surfaceHi = Color(0xFF1E2A24);
  const border = Color(0xFF26332C);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    secondary: AppColors.accent,
    brightness: Brightness.dark,
    surface: surface,
    onSurface: const Color(0xFFE8F0EB),
    surfaceContainer: surfaceHi,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0C1310),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFFE8F0EB),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE8F0EB),
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceHi,
      selectedColor: AppColors.primary.withOpacity(0.35),
      labelStyle: const TextStyle(color: Color(0xFFE8F0EB)),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
