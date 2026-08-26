import 'package:flutter/material.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:mapato/utils.dart';
import 'package:provider/provider.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _amount = TextEditingController();
  final _counterparty = TextEditingController();
  final _note = TextEditingController();

  String _direction = 'out';
  String _network = 'mpesa';
  String _category = 'Uncategorized';

  final _networks = ['mpesa', 'mixx', 'airtel', 'halo', 'azam', 'manual'];

  @override
  void dispose() {
    _amount.dispose();
    _counterparty.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() async {
    final s = AppLocalizations.of(context);
    final amt = double.tryParse(_amount.text.replaceAll(',', ''));
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.enterValidAmount)));
      return;
    }
    await context.read<AppState>().addManual(
          direction: _direction,
          amount: amt,
          category: _category,
          counterparty: _counterparty.text.isEmpty ? null : _counterparty.text,
          note: _note.text.isEmpty ? null : _note.text,
          network: _network,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.addedDirection(directionLabel(_direction, context: context), tzs(amt))),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();
    final categories = state.categories;
    return Scaffold(
      appBar: AppBar(title: Text(s.addTransaction)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'out', label: Text(s.spent)),
              ButtonSegment(value: 'in', label: Text(s.received)),
              ButtonSegment(value: 'transfer', label: Text(s.saved)),
            ],
            selected: {_direction},
            onSelectionChanged: (s) => setState(() => _direction = s.first),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s.amountTsh,
              prefixIcon: const Icon(Icons.money_rounded),
            ),
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 18),
          _FieldLabel(s.categoryLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((c) => ChoiceChip(
                      label: Text(c.name),
                      selected: _category == c.name,
                      avatar: Icon(state.categoryIcon(c.name), size: 16),
                      onSelected: (_) => setState(() {
                            _category = c.name;
                            _direction = categoryDirection(c.name);
                          }),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
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
            label: Text(s.saveTransaction),
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
