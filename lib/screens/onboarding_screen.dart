import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/root.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:provider/provider.dart';

const _captureChannel = MethodChannel('tz.mapato/capture');

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  final _controller = PageController();
  int _page = 0;

  // Permission states for the permissions page
  bool _notifEnabled = false;
  bool _smsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final notif = await isNotificationListenerEnabled();
    final sms = await permissionsChannel.invokeMethod<bool>('checkSmsPermission') ?? false;
    if (!mounted) return;
    setState(() {
      _notifEnabled = notif;
      _smsEnabled = sms;
    });
  }

  List<_Page> _pages(BuildContext context) => [
    _Page(
      icon: Icons.account_balance_wallet_rounded,
      title: AppLocalizations.of(context).onboardingWelcomeTitle,
      body: AppLocalizations.of(context).onboardingWelcomeBody,
    ),
    _Page(
      icon: Icons.smartphone_rounded,
      title: AppLocalizations.of(context).onboardingCapturesTitle,
      body: AppLocalizations.of(context).onboardingCapturesBody,
    ),
    _Page(
      icon: Icons.lock_outline_rounded,
      title: AppLocalizations.of(context).onboardingPrivateTitle,
      body: AppLocalizations.of(context).onboardingPrivateBody,
    ),
    _Page(
      icon: Icons.insights_rounded,
      title: AppLocalizations.of(context).onboardingInsightsTitle,
      body: AppLocalizations.of(context).onboardingInsightsBody,
    ),
    _Page(
      icon: Icons.language_rounded,
      title: AppLocalizations.of(context).onboardingLanguageTitle,
      body: AppLocalizations.of(context).onboardingLanguageSubtitle,
      isLanguagePicker: true,
    ),
    _Page(
      icon: Icons.shield_outlined,
      title: AppLocalizations.of(context).permissionsTitle,
      body: AppLocalizations.of(context).permissionsSubtitle,
      isPermissions: true,
    ),
  ];

  Future<void> _finish() async {
    await setPrefBool('onboarded', true);
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const Root()));
  }

  Future<void> _enableNotificationAccess() async {
    // Request POST_NOTIFICATIONS permission (Android 13+ system dialog)
    await requestPostNotificationPermission();
    // Open notification listener settings so user can manually enable it
    try {
      await settingsChannel.invokeMethod('openNotificationSettings');
    } on PlatformException {
      // ignored
    }
  }

  Future<void> _enableSmsAccess() async {
    await requestSmsPermission();
    // Check if granted after dialog
    final granted = await permissionsChannel.invokeMethod<bool>('checkSmsPermission') ?? false;
    if (!mounted) return;
    if (granted) {
      // Save the pref and start the SMS service so Settings shows it as enabled
      await setPrefBool('sms_capture_enabled', true);
      try {
        await _captureChannel.invokeMethod('startSmsService');
      } on PlatformException {
        // ignored
      }
    }
    setState(() => _smsEnabled = granted);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final isLast = _page == pages.length - 1;
    final isPerms = pages[_page].isPermissions;
    final s = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mapato',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  if (_page > 0 && !isLast && !isPerms)
                    TextButton(
                      onPressed: _finish,
                      child: Text(s.skip,
                          style: const TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  if (pages[i].isPermissions) _refreshPermissions();
                },
                itemBuilder: (context, i) {
                  final p = pages[i];
                  if (p.isLanguagePicker) {
                    return _LanguagePickerPage(
                      onSelectLanguage: (locale) {
                        context.read<AppState>().setLocale(locale);
                      },
                    );
                  }
                  if (p.isPermissions) {
                    return _PermissionsPage(
                      notifEnabled: _notifEnabled,
                      smsEnabled: _smsEnabled,
                      onEnableNotif: _enableNotificationAccess,
                      onEnableSms: _enableSmsAccess,
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(p.icon,
                              color: Colors.white, size: 60),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: isPerms
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _finish,
                        child: Text(s.setupComplete,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    )
                  : isLast
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                ),
                                child: Text(s.getStarted,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            ),
                            child: Text(s.next),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  final bool notifEnabled;
  final bool smsEnabled;
  final VoidCallback onEnableNotif;
  final VoidCallback onEnableSms;

  const _PermissionsPage({
    required this.notifEnabled,
    required this.smsEnabled,
    required this.onEnableNotif,
    required this.onEnableSms,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.shield_outlined,
                color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            s.permissionsTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.permissionsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _PermCard(
            icon: Icons.notifications_active_outlined,
            label: s.notificationAccessLabel,
            desc: s.notificationAccessDesc,
            granted: notifEnabled,
            onEnable: onEnableNotif,
            enableLabel: s.enableAccess,
            grantedLabel: s.granted,
          ),
          const SizedBox(height: 12),
          _PermCard(
            icon: Icons.sms_outlined,
            label: s.smsAccessLabel,
            desc: s.smsAccessDesc,
            granted: smsEnabled,
            onEnable: onEnableSms,
            enableLabel: s.enableAccess,
            grantedLabel: s.granted,
          ),
        ],
      ),
    );
  }
}

class _PermCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool granted;
  final VoidCallback onEnable;
  final String enableLabel;
  final String grantedLabel;

  const _PermCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.granted,
    required this.onEnable,
    required this.enableLabel,
    required this.grantedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: granted
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: granted
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          granted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        grantedLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : FilledButton(
                  onPressed: onEnable,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(enableLabel,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
    );
  }
}

class _LanguagePickerPage extends StatelessWidget {
  final ValueChanged<Locale> onSelectLanguage;
  const _LanguagePickerPage({required this.onSelectLanguage});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.language_rounded,
                color: Colors.white, size: 60),
          ),
          const SizedBox(height: 32),
          Text(
            s.onboardingLanguageTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),
          _LangButton(
            label: 'English',
            onTap: () => onSelectLanguage(const Locale('en')),
          ),
          const SizedBox(height: 14),
          _LangButton(
            label: 'Kiswahili',
            onTap: () => onSelectLanguage(const Locale('sw')),
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LangButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String body;
  final bool isLanguagePicker;
  final bool isPermissions;
  const _Page({
    required this.icon,
    required this.title,
    required this.body,
    this.isLanguagePicker = false,
    this.isPermissions = false,
  });
}
