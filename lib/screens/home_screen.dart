import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapato/database.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/chat_screen.dart';
import 'package:mapato/theme.dart';
import 'package:mapato/utils.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;
  const HomeScreen({super.key, this.onOpenSettings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _Range { all, today, week, month, lastMonth, custom }

class _HomeScreenState extends State<HomeScreen> {
  _Range _range = _Range.month;
  DateTime? _customStart;
  DateTime? _customEnd;

  bool _inRange(Transaction t) {
    final ts = t.timestamp;
    switch (_range) {
      case _Range.all:
        return true;
      case _Range.today:
        final n = DateTime.now();
        return ts.year == n.year && ts.month == n.month && ts.day == n.day;
      case _Range.week:
        final w = DateTime.now().subtract(const Duration(days: 7));
        return !ts.isBefore(w);
      case _Range.month:
        final n = DateTime.now();
        return ts.year == n.year && ts.month == n.month;
      case _Range.lastMonth:
        final n = DateTime.now();
        final prev = DateTime(n.year, n.month - 1, 1);
        final next = DateTime(n.year, n.month, 1);
        return !ts.isBefore(prev) && ts.isBefore(next);
      case _Range.custom:
        if (_customStart == null || _customEnd == null) return true;
        final end = _customEnd!.add(const Duration(days: 1));
        return !ts.isBefore(_customStart!) && ts.isBefore(end);
    }
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: _customStart ?? now.subtract(const Duration(days: 30)),
        end: _customEnd ?? now,
      ),
    );
    if (r != null && mounted) {
      setState(() {
        _customStart = r.start;
        _customEnd = r.end;
        _range = _Range.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final txns = state.transactions;

    final filtered = txns.where(_inRange).toList();
    final inSum = _sum(filtered, 'in');
    final outSum = _sum(filtered, 'out');
    final savedSum = _sum(filtered, 'transfer');
    final netMonth = inSum - outSum;

    final byCategory = _categoryTotals(filtered);
    final slices = byCategory.entries
        .map((e) => _Slice(
              value: e.value,
              color: state.categoryColor(e.key),
              label: e.key,
            ))
        .toList();

    final rangeLabel = switch (_range) {
      _Range.all => 'All time',
      _Range.today => 'Today',
      _Range.week => 'Last 7 days',
      _Range.month => 'This month',
      _Range.lastMonth => 'Last month',
      _Range.custom => 'Custom',
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Mapato',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ask Mapato AI',
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to light' : 'Switch to dark',
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: state.toggleTheme,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: state.refresh,
          child: txns.isEmpty
              ? _EmptyHome(onOpenSettings: widget.onOpenSettings)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _Greeting(),
            const SizedBox(height: 14),
            _HeroCard(net: netMonth, inMonth: inSum, outMonth: outSum),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _RangeChip(label: 'All', selected: _range == _Range.all, onTap: () => setState(() => _range = _Range.all)),
                  _RangeChip(label: 'Today', selected: _range == _Range.today, onTap: () => setState(() => _range = _Range.today)),
                  _RangeChip(label: 'Week', selected: _range == _Range.week, onTap: () => setState(() => _range = _Range.week)),
                  _RangeChip(label: 'Month', selected: _range == _Range.month, onTap: () => setState(() => _range = _Range.month)),
                  _RangeChip(label: 'Last mo', selected: _range == _Range.lastMonth, onTap: () => setState(() => _range = _Range.lastMonth)),
                  _RangeChip(label: 'Custom', selected: _range == _Range.custom, onTap: _pickCustom),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Income',
                    value: tzs(inSum),
                    color: AppColors.income,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Expenses',
                    value: tzs(outSum),
                    color: AppColors.expense,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Saved',
                    value: tzs(savedSum),
                    color: AppColors.savings,
                    icon: Icons.savings_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (outSum > 0) ...[
              _SectionTitle('Where your money went', action: rangeLabel),
              const SizedBox(height: 12),
              _BreakdownCard(slices: slices, totalOut: outSum),
              const SizedBox(height: 24),
            ],
            _SectionTitle('Recent activity', action: rangeLabel),
            const SizedBox(height: 12),
          ...filtered.take(6).map((t) => _TxnTile(t)),
        ],
      ),
      ),
      ),
    );
  }

  double _sum(List<Transaction> txns, String dir) => txns
      .where((t) => t.direction == dir)
      .fold(0.0, (s, t) => s + t.amount);

  Map<String, double> _categoryTotals(List<Transaction> txns) {
    final map = <String, double>{};
    for (final t in txns) {
      if (t.direction != 'out') continue;
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting,
            style: TextStyle(
                fontSize: 14, color: cs.onSurface.withOpacity(0.6))),
        const SizedBox(height: 2),
        Text('Here is your money overview',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: cs.onSurface)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double net;
  final double inMonth;
  final double outMonth;
  const _HeroCard({
    required this.net,
    required this.inMonth,
    required this.outMonth,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = const [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][now.month];
    return Container(
      decoration: BoxDecoration(
        gradient: brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                '$month net flow',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            tzs(net),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            net >= 0 ? 'You are saving this month' : 'Spending exceeded income',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RangeChip(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionTitle(this.title, {this.action});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: cs.onSurface)),
        if (action != null)
          Text(action!,
              style: TextStyle(
                  color: cs.onSurface.withOpacity(0.6), fontSize: 12)),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final List<_Slice> slices;
  final double totalOut;
  const _BreakdownCard({required this.slices, required this.totalOut});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          DonutChart(slices: slices, size: 132),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total spent',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6), fontSize: 12)),
                const SizedBox(height: 2),
                Text(tzs(totalOut),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: cs.onSurface)),
                const SizedBox(height: 10),
                ...slices.take(3).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _LegendRow(slice: s, total: totalOut),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final _Slice slice;
  final double total;
  const _LegendRow({required this.slice, required this.total});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = total > 0 ? (slice.value / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: slice.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(slice.label,
              style: TextStyle(fontSize: 12.5, color: cs.onSurface)),
        ),
        Text('$pct%',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.6))),
      ],
    );
  }
}

class _TxnTile extends StatelessWidget {
  final Transaction t;
  const _TxnTile(this.t);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = t.direction == 'in';
    final dirColor = directionColor(t.direction);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.25)),
      ),
      child: Row(
        children: [
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
                  t.counterparty ?? t.category,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                      color: cs.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _NetBadge(network: t.network),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _time(t.timestamp),
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.6), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

class _EmptyHome extends StatefulWidget {
  final VoidCallback? onOpenSettings;
  const _EmptyHome({this.onOpenSettings});
  @override
  State<_EmptyHome> createState() => _EmptyHomeState();
}

class _EmptyHomeState extends State<_EmptyHome>
    with WidgetsBindingObserver {
  bool? _notifEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final enabled = await isNotificationListenerEnabled();
    if (!mounted) return;
    setState(() => _notifEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notifEnabled = _notifEnabled ?? false;
    return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
          Container(
            margin: const EdgeInsets.only(top: 24, bottom: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: brandGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Mapato',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('Your money, every network, one view.',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  notifEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_active_outlined,
                  size: 48,
                  color: notifEnabled
                      ? AppColors.income
                      : AppColors.primary.withOpacity(0.7)),
                const SizedBox(height: 12),
                const Text('No transactions yet',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  notifEnabled
                      ? 'Notification access is on — your M-Pesa, Mixx, Airtel, '
                        'HaloPesa & AzamPesa transactions will appear here '
                        'automatically as they arrive.'
                      : 'Enable notification access in Settings and your '
                        'M-Pesa, Mixx, Airtel, HaloPesa & AzamPesa transactions '
                        'will appear here automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (!notifEnabled)
                  FilledButton.tonal(
                    onPressed: widget.onOpenSettings,
                    child: const Text('Open Settings'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slice {
  final double value;
  final Color color;
  final String label;
  const _Slice({required this.value, required this.color, required this.label});
}

class DonutChart extends StatelessWidget {
  final List<_Slice> slices;
  final double size;
  final Widget? center;
  const DonutChart({required this.slices, this.size = 132, this.center});

  @override
  Widget build(BuildContext context) {
    final stroke = size * 0.16;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(slices, stroke),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  final double stroke;
  _DonutPainter(this.slices, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final rect = Rect.fromCircle(center: center, radius: r - stroke / 2);
    final total = slices.fold(0.0, (s, e) => s + e.value);

    if (total <= 0) {
      final paint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke;
      canvas.drawCircle(center, r - stroke / 2, paint);
      return;
    }

    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.slices != slices;
}

String _time(DateTime d) =>
    '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';

