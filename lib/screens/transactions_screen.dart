import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapato/database.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:mapato/utils.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _query = TextEditingController();
  String _network = 'all';
  bool _searching = false;
  final Set<int> _selected = {};
  bool _selectionMode = false;
  final _networks = ['all', 'mpesa', 'mixx', 'airtel', 'halo', 'azam'];
  final _ranges = ['all', 'today', 'week', 'month', 'lastmonth', 'custom'];
  String _range = 'all';
  DateTime? _from;
  DateTime? _to;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  (bool, DateTime, DateTime) _rangeBounds() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case 'today':
        return (true, today, today.add(const Duration(days: 1)));
      case 'week':
        final start = today.subtract(Duration(days: now.weekday - 1));
        return (true, start, start.add(const Duration(days: 7)));
      case 'month':
        final start = DateTime(now.year, now.month, 1);
        return (true, start, DateTime(now.year, now.month + 1, 1));
      case 'lastmonth':
        final start = DateTime(now.year, now.month - 1, 1);
        return (true, start, DateTime(now.year, now.month, 1));
      case 'custom':
        if (_from != null && _to != null) {
          return (true, _from!, _to!.add(const Duration(days: 1)));
        }
        return (false, today, today);
      default:
        return (false, today, today);
    }
  }

  List<dynamic> _visible() {
    final all = context.read<AppState>().transactions;
    final (useRange, start, end) = _rangeBounds();
    return all.where((t) {
      if (_network != 'all' && t.network != _network) return false;
      if (useRange &&
          (t.timestamp.isBefore(start) || t.timestamp.isAfter(end))) {
        return false;
      }
      final q = _query.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        final hay = '${t.counterparty ?? ''} ${t.category} ${t.network} '
            '${t.note ?? ''}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  void _enterSelection(int id) {
    setState(() {
      _selectionMode = true;
      _selected.add(id);
    });
  }

  void _startSelection() {
    setState(() => _selectionMode = true);
  }

  Future<void> _pickRange() async {
    final from = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (from == null) return;
    final to = await showDatePicker(
      context: context,
      initialDate: _to ?? from,
      firstDate: from,
      lastDate: DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      _from = from;
      _to = to ?? from;
    });
  }

  Future<void> _openDetail(dynamic t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TransactionDetailScreen(t: t)),
    );
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      if (_selected.isEmpty) _selectionMode = false;
    });
  }

  void _exitSelection() {
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  void _toggleSelectAll(List<dynamic> visible) {
    setState(() {
      final allSelected =
          visible.isNotEmpty && visible.every((t) => _selected.contains(t.id));
      if (allSelected) {
        _selected.clear();
        _selectionMode = false;
      } else {
        _selectionMode = true;
        _selected.addAll(visible.map((t) => t.id));
      }
    });
  }

  Future<void> _confirmDelete(List<int> ids) async {
    final s = AppLocalizations.of(context);
    final count = ids.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteCountQuestion(count)),
        content: Text(s.actionCannotUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await context.read<AppState>().deleteMany(ids);
      _exitSelection();
    }
  }

  Future<void> _openEdit(dynamic t) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditTxnSheet(t: t),
    );
  }

  String _dayKey(DateTime d) {
    final s = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return s.today;
    if (diff == 1) return s.yesterday;
    return DateFormat('d MMM yyyy').format(d);
  }

  List<_Group> _group(List<dynamic> txns) {
    final map = <String, List<dynamic>>{};
    for (final t in txns) {
      (map[_dayKey(t.timestamp)] ??= []).add(t);
    }
    return map.entries.map((e) => _Group(e.key, e.value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();
    final visible = _visible();
    final groups = _group(visible);
    return Scaffold(
      appBar: AppBar(
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelection,
              )
            : null,
        title: _searching
            ? TextField(
                controller: _query,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: s.searchTransactions,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: cs.onSurfaceVariant),
                ),
                style: TextStyle(color: cs.onSurface, fontSize: 16),
                onChanged: (_) => setState(() {}),
              )
            : Text(_selectionMode
                ? s.selectedCount(_selected.length)
                : s.transactions),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () => _toggleSelectAll(visible),
              tooltip: s.selectAll,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _selected.isEmpty
                  ? null
                  : () => _confirmDelete(_selected.toList()),
              tooltip: s.deleteSelected,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: s.select,
              onPressed: _startSelection,
            ),
            IconButton(
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _searching = !_searching;
                  if (!_searching) _query.clear();
                });
              },
            ),
          ],
        ],
      ),
      body: state.transactions.isEmpty
          ? const _NoTxns()
          : Column(
              children: [
                _FilterChips(
                  networks: _networks,
                  selected: _network,
                  onTap: (n) => setState(() => _network = n),
                ),
                _RangeChips(
                  ranges: _ranges,
                  selected: _range,
                  onTap: (r) async {
                    if (r == 'custom') {
                      await _pickRange();
                      if (_from == null) return;
                    }
                    setState(() => _range = r);
                  },
                ),
                if (_range == 'custom')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickRange,
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(_from == null
                              ? s.from
                              : DateFormat('d MMM yyyy').format(_from!)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _pickRange,
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(_to == null
                              ? s.to
                              : DateFormat('d MMM yyyy').format(_to!)),
                        ),
                      ],
                    ),
                  ),
                if (visible.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(s.noMatches,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: state.refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: groups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, gi) {
                          final g = groups[gi];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(4, 12, 4, 6),
                                child: Text(
                                  g.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                                ...g.items.map((t) => _TxnRow(
                                      t: t,
                                      selectionMode: _selectionMode,
                                      selected: _selected.contains(t.id),
                                      onTap: () {
                                        if (_selectionMode) {
                                          _toggle(t.id);
                                        } else {
                                          _openDetail(t);
                                        }
                                      },
                                      onLongPress: _selectionMode
                                          ? null
                                          : () => _enterSelection(t.id),
                                      onDelete: _selectionMode
                                          ? null
                                          : () => _confirmDelete([t.id]),
                                      onEdit: _selectionMode
                                          ? null
                                          : () => _openEdit(t),
                                    )),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
        ),
      );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> networks;
  final String selected;
  final ValueChanged<String> onTap;
  const _FilterChips({
    required this.networks,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: networks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final n = networks[i];
          final isAll = n == 'all';
          final label = isAll ? s.all : networkLabel(n);
          final active = selected == n;
          return ChoiceChip(
            label: Text(label),
            selected: active,
            onSelected: (_) => onTap(n),
            avatar: isAll
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: networkColor(n),
                      shape: BoxShape.circle,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _RangeChips extends StatelessWidget {
  final List<String> ranges;
  final String selected;
  final ValueChanged<String> onTap;
  const _RangeChips({
    required this.ranges,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final labels = {
      'all': s.all,
      'today': s.today,
      'week': s.thisWeek,
      'month': s.thisMonth,
      'lastmonth': s.lastMonth,
      'custom': s.custom,
    };
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ranges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final r = ranges[i];
          final active = selected == r;
          return ChoiceChip(
            label: Text(labels[r] ?? r),
            selected: active,
            onSelected: (_) => onTap(r),
          );
        },
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final dynamic t;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const _TxnRow({
    required this.t,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
  });
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isIncome = t.direction == 'in';
    final dirColor = directionColor(t.direction);
    final dirLabel = directionLabel(t.direction, context: context);
    final state = Provider.of<AppState>(context, listen: false);
    final catColor = state.categoryColor(t.category);
    return Material(
      color: selected ? AppColors.primary.withOpacity(0.08) : cs.surface,
      borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (selectionMode)
                Checkbox(
                  value: selected,
                  activeColor: AppColors.primary,
                  onChanged: (_) => onTap(),
                )
              else
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: networkColor(t.network).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    t.direction == 'transfer'
                        ? Icons.swap_horiz_rounded
                        : (isIncome
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded),
                    color: dirColor,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.counterparty ?? localizedCategoryName(t.category, context),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                        children: [
                          _NetBadge(network: t.network),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                           child: Text(
                            localizedCategoryName(t.category, context),
                            style: TextStyle(
                              color: catColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!selectionMode && (onDelete != null || onEdit != null))
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                  tooltip: s.more,
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit?.call();
                    } else if (action == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (_) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 18),
                            const SizedBox(width: 12),
                            Text(s.edit),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.expense),
                            const SizedBox(width: 12),
                            Text(s.delete,
                                style: const TextStyle(color: AppColors.expense)),
                          ],
                        ),
                      ),
                  ],
                )
              else
                 Text(
                  '${t.direction == 'transfer' ? '' : (isIncome ? '+' : '-')}${tzs(t.amount)}',
                  style: TextStyle(
                    color: dirColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetBadge extends StatelessWidget {
  final String network;
  const _NetBadge({required this.network});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: networkColor(network).withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          networkLabel(network),
          style: TextStyle(
            color: networkColor(network),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _NoTxns extends StatelessWidget {
  const _NoTxns();
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          s.noTransactionsFound,
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _Group {
  final String label;
  final List<dynamic> items;
  _Group(this.label, this.items);
}

class _EditTxnSheet extends StatefulWidget {
  final dynamic t;
  const _EditTxnSheet({required this.t});
  @override
  State<_EditTxnSheet> createState() => _EditTxnSheetState();
}

class _EditTxnSheetState extends State<_EditTxnSheet> {
  final _amount = TextEditingController();
  final _counterparty = TextEditingController();
  final _note = TextEditingController();
  late String _direction;
  late String _network;
  late String _category;
  final _networks = ['mpesa', 'mixx', 'airtel', 'halo', 'azam', 'manual'];

  @override
  void initState() {
    super.initState();
    final t = widget.t;
    _amount.text = t.amount.toString();
    _counterparty.text = t.counterparty ?? '';
    _note.text = t.note ?? '';
    _direction = t.direction;
    _network = _networks.contains(t.network) ? t.network : 'manual';
    _category = t.category;
  }

  @override
  void dispose() {
    _amount.dispose();
    _counterparty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppLocalizations.of(context);
    final amt = double.tryParse(_amount.text.replaceAll(',', ''));
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.enterValidAmount)));
      return;
    }
    final t = widget.t;
    final companion = TransactionsCompanion(
      id: Value(t.id),
      network: Value(_network),
      direction: Value(_direction),
      amount: Value(amt),
      balance: Value(t.balance),
      counterparty:
          Value(_counterparty.text.isEmpty ? null : _counterparty.text),
      category: Value(_category),
      note: Value(_note.text.isEmpty ? null : _note.text),
      timestamp: Value(t.timestamp),
      source: Value(t.source),
      raw: Value(t.raw),
    );
    await context.read<AppState>().saveTx(companion);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();
    final categories = state.categories;
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
              Text(s.editTransaction,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'out', label: Text(s.spent)),
              ButtonSegment(value: 'in', label: Text(s.received)),
              ButtonSegment(value: 'transfer', label: Text(s.saved)),
            ],
            selected: {_direction},
            onSelectionChanged: (s) => setState(() => _direction = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s.amountTsh,
              prefixIcon: const Icon(Icons.money_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel(s.networkLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _networks
                .map((n) => ChoiceChip(
                      label: Text(networkLabel(n)),
                      selected: _network == n,
                      onSelected: (_) => setState(() => _network = n),
                      avatar: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: networkColor(n),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          _FieldLabel(s.categoryLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((c) => ChoiceChip(
                      label: Text(localizedCategoryName(c.name, context)),
                      selected: _category == c.name,
                      avatar: Icon(state.categoryIcon(c.name), size: 16),
                      onSelected: (_) => setState(() {
                            _category = c.name;
                            _direction = categoryDirection(c.name);
                          }),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _counterparty,
            decoration: InputDecoration(
              labelText: s.counterpartyOptional,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: s.noteOptional,
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(s.saveChanges),
          ),
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

class TransactionDetailScreen extends StatelessWidget {
  final dynamic t;
  const TransactionDetailScreen({super.key, required this.t});

  Future<void> _confirmDelete(BuildContext context) async {
    final s = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteCountQuestion(1)),
        content: Text(s.actionCannotUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppState>().deleteTx(t.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();
    final isIncome = t.direction == 'in';
    final catColor = state.categoryColor(t.category);
    final catIcon = state.categoryIcon(t.category);
    final amountColor = directionColor(t.direction);
    final dirLabel = directionLabel(t.direction, context: context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.transaction),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: s.edit,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: cs.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => _EditTxnSheet(t: t),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: s.delete,
            color: AppColors.expense,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              '${t.direction == 'transfer' ? '' : (isIncome ? '+' : '-')}${tzs(t.amount)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: amountColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NetBadge(network: t.network),
                const SizedBox(width: 6),
                Text(dirLabel,
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: catIcon,
            iconColor: catColor,
            label: s.categoryLabel,
            value: localizedCategoryName(t.category, context),
          ),
          if (t.counterparty != null && t.counterparty.isNotEmpty)
            _DetailRow(
              icon: Icons.person_outline,
              label: t.direction == 'transfer'
                  ? s.account
                  : (isIncome ? s.from : s.to),
              value: t.counterparty,
            ),
          _DetailRow(
            icon: Icons.event,
            label: s.date,
            value: DateFormat('EEE, d MMM yyyy â€¢ HH:mm').format(t.timestamp),
          ),
          _DetailRow(
            icon: Icons.source_outlined,
            label: s.source,
            value: t.source == 'notification' ? s.notifSource : s.manualSource,
          ),
          if (t.balance != null)
            _DetailRow(
              icon: Icons.account_balance_wallet_outlined,
              label: s.balance,
              value: tzs(t.balance!),
            ),
          if (t.note != null && t.note.isNotEmpty)
            _DetailRow(icon: Icons.notes_outlined, label: s.noteDetail, value: t.note),
          const SizedBox(height: 16),
          if (t.raw != null && t.raw!.isNotEmpty) ...[
            _FieldLabel(s.originalMessage),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                t.raw!,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? cs.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      )),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
