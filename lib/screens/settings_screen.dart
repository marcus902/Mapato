import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapato/export_import.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/categories_screen.dart';
import 'package:mapato/screens/parser_lab_screen.dart';
import 'package:mapato/screens/pin_screen.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:provider/provider.dart';

const _captureChannel = MethodChannel('tz.mapato/capture');
const _smsPrefKey = 'sms_capture_enabled';

class _CaptureSource {
  final String label;
  final String pkg;
  const _CaptureSource(this.label, this.pkg);
}

const _captureSources = [
  _CaptureSource('M-Pesa', 'com.vodacom.mpesa'),
  _CaptureSource('Mixx by Yas', 'tz.tigo.mfsapp'),
  _CaptureSource('Tigo Pesa (legacy)', 'com.tigo.pesa'),
  _CaptureSource('Airtel Money', 'com.airtel.money'),
  _CaptureSource('HaloPesa', 'com.halopesa.eu'),
  _CaptureSource('HaloPesa (legacy)', 'tz.co.halo.halopesa'),
  _CaptureSource('AzamPesa', 'com.azampesa'),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _smsEnabled = false;
  bool _notifEnabled = false;
  bool _loading = true;

  bool _captureAll = false;
  final Set<String> _captureSet = {};
  bool _captureLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshNotifStatus();
  }

  Future<void> _refreshNotifStatus() async {
    final notif = await isNotificationListenerEnabled();
    if (!mounted) return;
    setState(() => _notifEnabled = notif);
  }

  Future<void> _initState() async {
    final notif = await isNotificationListenerEnabled();
    await _initSmsState();
    await _initCaptureState();
    if (!mounted) return;
    setState(() => _notifEnabled = notif);
  }

  Future<void> _initCaptureState() async {
    final all = await getPrefBool('capture_all');
    final csv = await getPrefString('capture_packages');
    final set = csv.isEmpty
        ? _captureSources.map((s) => s.pkg).toSet()
        : csv.split(',').where((e) => e.isNotEmpty).toSet();
    if (csv.isEmpty) {
      await setPrefString('capture_packages', set.join(','));
    }
    if (!mounted) return;
    setState(() {
      _captureAll = all;
      _captureSet
        ..clear()
        ..addAll(set);
      _captureLoading = false;
    });
  }

  Future<void> _setCaptureAll(bool value) async {
    if (!mounted) return;
    setState(() => _captureAll = value);
    await setPrefBool('capture_all', value);
  }

  Future<void> _toggleSource(String pkg, bool value) async {
    if (!mounted) return;
    setState(() {
      if (value) {
        _captureSet.add(pkg);
      } else {
        _captureSet.remove(pkg);
      }
    });
    await setPrefString('capture_packages', _captureSet.join(','));
  }

  Future<void> _initSmsState() async {
    final saved = await getPrefBool(_smsPrefKey);
    final granted =
        await permissionsChannel.invokeMethod('checkSmsPermission') ?? false;
    final active = saved && granted;
    if (active) {
      try {
        await _captureChannel.invokeMethod('startSmsService');
      } on PlatformException {
        // ignore
      }
    }
    if (!mounted) return;
    setState(() {
      _smsEnabled = active;
      _loading = false;
    });
  }

  Future<void> _openListenerSettings() async {
    try {
      await settingsChannel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open settings: $e')),
      );
    }
  }

  Future<void> _toggleSms(bool value) async {
    if (!mounted) return;
    if (value) {
      bool granted = false;
      try {
        granted = await permissionsChannel.invokeMethod('requestSmsPermission') ??
            false;
      } on PlatformException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('SMS permission failed: $e')));
        return;
      }
      if (!mounted) return;
      if (!granted) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('SMS Permission Blocked'),
            content: const Text(
              'Google Play Protect is blocking SMS permission for Mapato.\n\n'
              'To enable SMS capture:\n\n'
              '1. Open Google Play Store\n'
              '2. Tap your profile icon > Play Protect\n'
              '3. Tap the settings gear icon\n'
              '4. Turn OFF "Improve harmful app protection"\n\n'
              'This is safe — Mapato only reads mobile-money SMS. '
              'Alternatively, use Notification access only (recommended).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() => _smsEnabled = false);
        return;
      }
      await setPrefBool(_smsPrefKey, true);
      try {
        await _captureChannel.invokeMethod('startSmsService');
      } on PlatformException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('SMS capture failed: $e')));
        return;
      }
      if (!mounted) return;
      setState(() => _smsEnabled = true);
    } else {
      await setPrefBool(_smsPrefKey, false);
      try {
        await _captureChannel.invokeMethod('stopSmsService');
      } on PlatformException {
        // ignore
      }
      if (!mounted) return;
      setState(() => _smsEnabled = false);
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 24),
      children: [
        // ── Data Capture ──
        _sectionHeader('Data Capture'),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Icon(
                  Icons.notifications_active,
                  size: 22,
                  color: _notifEnabled ? AppColors.income : null,
                ),
                title: const Text('Notification access', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  _notifEnabled ? 'Active' : 'Required to auto-capture',
                  style: TextStyle(
                    color: _notifEnabled ? AppColors.income : cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: _notifEnabled
                    ? Icon(Icons.check_circle, color: AppColors.income, size: 18)
                    : FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _openListenerSettings,
                        child: const Text('Enable', style: TextStyle(fontSize: 12)),
                      ),
                onTap: _openListenerSettings,
              ),
              const Divider(height: 1),
              SwitchListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                secondary: const Icon(Icons.sms, size: 22),
                title: const Text('SMS capture', style: TextStyle(fontSize: 14)),
                subtitle: const Text(
                  'Fallback when no notification',
                  style: TextStyle(fontSize: 12),
                ),
                value: _loading ? false : _smsEnabled,
                onChanged: _loading ? null : _toggleSms,
              ),
              const Divider(height: 1),
              ExpansionTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.apps, size: 22),
                title: const Text('Capture sources', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  _captureAll
                      ? 'All apps'
                      : '${_captureSet.length}/${_captureSources.length} selected',
                  style: const TextStyle(fontSize: 12),
                ),
                childrenPadding: const EdgeInsets.only(left: 16),
                children: [
                  SwitchListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: const Text('Capture from all apps', style: TextStyle(fontSize: 13)),
                    value: _captureLoading ? false : _captureAll,
                    onChanged: _captureLoading ? null : _setCaptureAll,
                  ),
                  if (!_captureAll)
                    ..._captureSources.map((s) => SwitchListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(s.label, style: const TextStyle(fontSize: 13)),
                          value: _captureSet.contains(s.pkg),
                          onChanged: _captureLoading
                              ? null
                              : (v) => _toggleSource(s.pkg, v),
                        )),
                ],
              ),
            ],
          ),
        ),

        // ── Security ──
        _sectionHeader('Security'),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                secondary: const Icon(Icons.lock_outline, size: 22),
                title: const Text('App lock (PIN)', style: TextStyle(fontSize: 14)),
                subtitle: const Text(
                  'Require PIN to open',
                  style: TextStyle(fontSize: 12),
                ),
                value: state.pinEnabled,
                onChanged: (v) async {
                  if (v) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PinScreen(
                          mode: PinMode.setup,
                          onSuccess: () => setState(() {}),
                        ),
                      ),
                    );
                    setState(() {});
                  } else {
                    await state.disablePin();
                    setState(() {});
                  }
                },
              ),
              if (state.pinEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.pin_outlined, size: 22),
                  title: const Text('Change PIN', style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PinScreen(mode: PinMode.change),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Appearance ──
        _sectionHeader('Appearance'),
        Card(
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.dark_mode_outlined, size: 22),
            title: const Text('Theme', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              state.themeMode == ThemeMode.dark
                  ? 'Dark'
                  : state.themeMode == ThemeMode.light
                      ? 'Light'
                      : 'System',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Theme'),
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                      groupValue: state.themeMode,
                      onChanged: (v) {
                        state.setThemeMode(v!);
                        Navigator.pop(ctx);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                      groupValue: state.themeMode,
                      onChanged: (v) {
                        state.setThemeMode(v!);
                        Navigator.pop(ctx);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('System default'),
                      value: ThemeMode.system,
                      groupValue: state.themeMode,
                      onChanged: (v) {
                        state.setThemeMode(v!);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Data ──
        _sectionHeader('Data'),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.storage, size: 22),
                title: const Text('Transactions captured', style: TextStyle(fontSize: 14)),
                trailing: Text(
                  '${state.transactions.length}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.category_outlined, size: 22),
                title: const Text('Categories', style: TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.science, size: 22),
                title: const Text('Parser Lab', style: TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ParserLabScreen()),
                ),
              ),
            ],
          ),
        ),

        // ── Backup & Restore ──
        _sectionHeader('Backup & Restore'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: state.transactions.isEmpty
                        ? null
                        : () async {
                            try {
                              await exportTransactionsCsv(state.transactions);
                            } on PlatformException catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Export failed: $e')),
                              );
                            }
                          },
                    icon: const Icon(Icons.upload, size: 16),
                    label: const Text('Export', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final content = await pickCsvFile();
                      if (content == null) return;
                      final count = await state.importCsv(content);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(count > 0
                              ? 'Imported $count transaction${count == 1 ? '' : 's'}.'
                              : 'No valid transactions found.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Import', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── About ──
        _sectionHeader('About'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mapato',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Personal money tracker • v1.0.0',
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _aboutRow(Icons.person_outline, 'Developer', 'Malik'),
                const SizedBox(height: 8),
                _aboutRow(Icons.phone_outlined, 'Phone', '+255 628 946 399'),
                const SizedBox(height: 10),
                Text(
                  'Supports M-Pesa, Mixx by Yas, Airtel Money, HaloPesa & AzamPesa. '
                  'Your data stays on your device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ],
    );
  }
}
