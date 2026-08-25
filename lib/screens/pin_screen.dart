import 'package:flutter/material.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/security.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:provider/provider.dart';

enum PinMode { setup, unlock, change }

enum _PinStatus { enterPin, createPin, enterCurrent, enterNew, confirmNew, confirmPin }

enum _PinError { incorrectCurrent, mismatch, incorrect }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;
  const PinScreen({super.key, required this.mode, this.onSuccess});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final List<String> _digits = [];
  _PinStatus _statusKey = _PinStatus.enterPin;
  _PinError? _errorKey;
  bool _error = false;

  String? _firstEntry;
  bool _confirming = false;

  bool _oldVerified = false;

  @override
  void initState() {
    super.initState();
    switch (widget.mode) {
      case PinMode.unlock:
        _statusKey = _PinStatus.enterPin;
        break;
      case PinMode.setup:
        _statusKey = _PinStatus.createPin;
        break;
      case PinMode.change:
        _statusKey = _PinStatus.enterCurrent;
        break;
    }
  }

  void _onKey(String key) {
    if (_digits.length >= 4) return;
    setState(() {
      _error = false;
      _digits.add(key);
    });
    if (_digits.length == 4) _submit();
  }

  void _onBackspace() {
    if (_digits.isEmpty) return;
    setState(() {
      _error = false;
      _digits.removeLast();
    });
  }

  Future<void> _submit() async {
    final entered = _digits.join();

    if (widget.mode == PinMode.change) {
      if (!_oldVerified) {
        final ok = await context.read<AppState>().verifyPin(entered);
        if (!mounted) return;
        if (!ok) {
          _fail(_PinError.incorrectCurrent);
          return;
        }
        setState(() {
          _oldVerified = true;
          _confirming = false;
          _firstEntry = null;
          _digits.clear();
          _statusKey = _PinStatus.enterNew;
        });
        return;
      }
      if (!_confirming) {
        _firstEntry = entered;
        setState(() {
          _confirming = true;
          _digits.clear();
          _statusKey = _PinStatus.confirmNew;
        });
        return;
      }
      if (entered != _firstEntry) {
        _fail(_PinError.mismatch);
        return;
      }
      await context.read<AppState>().setPin(entered);
      widget.onSuccess?.call();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (widget.mode == PinMode.setup) {
      if (!_confirming) {
        _firstEntry = entered;
        setState(() {
          _confirming = true;
          _digits.clear();
          _statusKey = _PinStatus.confirmPin;
        });
        return;
      }
      if (entered != _firstEntry) {
        _fail(_PinError.mismatch);
        return;
      }
      await context.read<AppState>().setPin(entered);
      widget.onSuccess?.call();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final ok = await context.read<AppState>().verifyPin(entered);
    if (!mounted) return;
    if (ok) {
      widget.onSuccess?.call();
    } else {
      _fail(_PinError.incorrect);
    }
  }

  void _fail(_PinError error) {
    setState(() {
      _error = true;
      _digits.clear();
      _errorKey = error;
      _confirming = false;
      _firstEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context);

    final title = switch (widget.mode) {
      PinMode.change => s.changePin,
      _ => 'Mapato',
    };
    final subtitle = switch (widget.mode) {
      PinMode.change => _oldVerified ? s.setNewPin : s.verifyCurrentPin,
      PinMode.unlock => s.secureTracker,
      PinMode.setup => s.secureTracker,
    };

    final statusText = _error
        ? switch (_errorKey!) {
            _PinError.incorrectCurrent => s.pinIncorrectCurrent,
            _PinError.mismatch => s.pinMismatch,
            _PinError.incorrect => s.pinIncorrect,
          }
        : switch (_statusKey) {
            _PinStatus.enterPin => s.pinEnterYourPin,
            _PinStatus.createPin => s.pinCreate4Digit,
            _PinStatus.enterCurrent => s.pinEnterCurrent,
            _PinStatus.enterNew => s.pinEnterNew,
            _PinStatus.confirmNew => s.pinConfirmNew,
            _PinStatus.confirmPin => s.pinConfirmYour,
          };

    return Scaffold(
      appBar: widget.mode == PinMode.change
          ? AppBar(title: Text(s.changePin))
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.mode != PinMode.change) ...[
              const SizedBox(height: 54),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 46),
              ),
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 42),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => _box(i, cs)),
            ),
            const SizedBox(height: 14),
            Text(
              statusText,
              style: TextStyle(
                color: _error ? AppColors.expense : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 26),
            Expanded(child: _keypad(cs)),
          ],
        ),
      ),
    );
  }

  Widget _box(int i, ColorScheme cs) {
    final filled = i < _digits.length;
    return Container(
      width: 52,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _error ? AppColors.expense : cs.outlineVariant,
          width: 1.5,
        ),
      ),
      child: filled
          ? Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  Widget _keypad(ColorScheme cs) {
    final rows = const [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Column(
        children: [
          for (final row in rows)
            Expanded(
              child: Row(
                children: [
                  for (final k in row)
                    Expanded(
                      child: k.isEmpty
                          ? const SizedBox.shrink()
                          : _key(k, cs),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _key(String label, ColorScheme cs) {
    if (label == 'del') {
      return _keyButton(icon: Icons.backspace_outlined, onTap: _onBackspace);
    }
    return _keyButton(text: label, onTap: () => _onKey(label));
  }

  Widget _keyButton({
    String? text,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 30, color: Theme.of(context).colorScheme.onSurface)
            : Text(text!,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
