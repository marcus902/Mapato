import 'package:flutter/material.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/parser.dart';
import 'package:mapato/state/app_state.dart';
import 'package:provider/provider.dart';

class ParserLabScreen extends StatefulWidget {
  const ParserLabScreen({super.key});

  @override
  State<ParserLabScreen> createState() => _ParserLabScreenState();
}

class _ParserLabScreenState extends State<ParserLabScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(s.parserLab)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              s.parserLabInstruction,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            _SampleField(controller: _controller),
            const SizedBox(height: 24),
            if (state.capturedRaw.isNotEmpty) ...[
              Text(s.recentCaptured,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...state.capturedRaw.take(20).map(
                    (raw) => ListTile(
                      dense: true,
                      title: Text(
                        raw.replaceAll('\n', ' ').trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _controller.text = raw,
                    ),
                  ),
            ] else
              Text(s.noCapturesYet),
          ],
        ),
      ),
    );
  }
}

class _SampleField extends StatefulWidget {
  final TextEditingController controller;
  const _SampleField({required this.controller});

  @override
  State<_SampleField> createState() => _SampleFieldState();
}

class _SampleFieldState extends State<_SampleField> {
  ParsedTransaction? _result;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  void _update() {
    final text = widget.controller.text;
    setState(() => _result = text.isEmpty ? null : parseMessage(text));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: s.sampleMessage,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 16),
        if (_result == null)
          Text(s.noMatch)
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(s.networkLabel, _result!.network),
                  _Row(s.directionLabel, _result!.direction),
                  _Row(s.amountTsh, _result!.amount.toString()),
                  _Row(s.balance,
                      _result!.balance?.toString() ?? 'â€”'),
                  _Row(s.counterparty,
                      _result!.counterparty ?? 'â€”'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
