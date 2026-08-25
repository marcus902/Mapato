import 'package:flutter/material.dart';
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
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Parser Lab')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Paste a real money SMS / notification text below to see how '
              'Mapato will parse it. Use this to tune lib/parser.dart for each '
              'network. Anything that returns "no match" means the regex needs work.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            _SampleField(controller: _controller),
            const SizedBox(height: 24),
            if (state.capturedRaw.isNotEmpty) ...[
              const Text('Recent captured (tap to load)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text('No captures yet. Enable notification/SMS access and '
                  'do a real transfer to populate this list.'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Sample message',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 16),
        if (_result == null)
          const Text('No match — parser returned null. Tune the regexes.')
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row('Network', _result!.network),
                  _Row('Direction', _result!.direction),
                  _Row('Amount', _result!.amount.toString()),
                  _Row('Balance',
                      _result!.balance?.toString() ?? '—'),
                  _Row('Counterparty',
                      _result!.counterparty ?? '—'),
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
