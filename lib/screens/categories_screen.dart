import 'package:flutter/material.dart' hide Category;
import 'package:mapato/database.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:provider/provider.dart';

/// Palette offered when creating/editing a category.
const List<Color> categoryPalette = [
  Color(0xFF16A34A),
  Color(0xFF0B7A45),
  Color(0xFF0EA5E9),
  Color(0xFF06B6D4),
  Color(0xFF14B8A6),
  Color(0xFF8B5CF6),
  Color(0xFF6366F1),
  Color(0xFFEC4899),
  Color(0xFFDB2777),
  Color(0xFFEF4444),
  Color(0xFFF97316),
  Color(0xFFF59E0B),
  Color(0xFFB45309),
  Color(0xFF475569),
  Color(0xFF64748B),
];

/// Icons offered when creating/editing a category.
const List<IconData> categoryIconSet = [
  Icons.restaurant,
  Icons.directions_bus,
  Icons.shopping_bag,
  Icons.receipt_long,
  Icons.home,
  Icons.phone_android,
  Icons.wifi,
  Icons.school,
  Icons.favorite,
  Icons.movie,
  Icons.people,
  Icons.savings,
  Icons.business,
  Icons.account_balance_wallet,
  Icons.category,
  Icons.work,
  Icons.flight,
  Icons.pets,
  Icons.coffee,
  Icons.local_grocery_store,
];

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(s.categoriesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.categoriesInstruction,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...state.categories.map((c) {
            return Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(c.color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(IconData(c.icon, fontFamily: 'MaterialIcons'),
                      color: Color(c.color)),
                ),
                title: Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openEditor(context, state, c),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openEditor(context, state, null),
            icon: const Icon(Icons.add),
            label: Text(s.newCategory),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    AppState state,
    Category? existing,
  ) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryEditor(
        existing: existing,
        onSave: (name, color, icon) async {
          if (existing != null) {
            await state.editCategory(existing.id, name, color, icon);
          } else {
            await state.addCategory(name, color, icon);
          }
        },
        onDelete: existing == null
            ? null
            : () async => await state.removeCategory(existing.id),
      ),
    );
  }
}

class _CategoryEditor extends StatefulWidget {
  final Category? existing;
  final Future<void> Function(String name, int color, int icon) onSave;
  final Future<void> Function()? onDelete;
  const _CategoryEditor({
    required this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final TextEditingController _name;
  late Color _color;
  late IconData _icon;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _color = e != null ? Color(e.color) : categoryPalette.first;
    _icon = e != null
        ? IconData(e.icon, fontFamily: 'MaterialIcons')
        : categoryIconSet.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterCategoryName)),
      );
      return;
    }
    await widget.onSave(name, _color.value, _icon.codePoint);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.existing == null ? s.newCategory : s.editCategory,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18)),
              if (widget.existing != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: s.name,
              prefixIcon: const Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 20),
          _FieldLabel(s.color),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categoryPalette
                .map((c) => GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == c
                                ? cs.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          _FieldLabel(s.icon),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categoryIconSet
                .map((ic) => GestureDetector(
                      onTap: () => setState(() => _icon = ic),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _icon == ic
                              ? AppColors.primary.withOpacity(0.15)
                              : cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _icon == ic
                                ? AppColors.primary
                                : cs.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(ic,
                            color: _icon == ic
                                ? AppColors.primary
                                : cs.onSurfaceVariant),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(s.save),
          ),
          if (widget.onDelete != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await widget.onDelete!();
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(s.deleteCategory),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.expense,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
        fontSize: 14,
      ),
    );
  }
}
