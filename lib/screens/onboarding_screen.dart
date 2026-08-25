import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/root.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  ];

  Future<void> _finish() async {
    await setPrefBool('onboarded', true);
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const Root()));
  }

  Future<void> _showSmsDialog() async {
    final s = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.sms_outlined, size: 40, color: AppColors.primary),
        title: Text(s.allowSmsTitle),
        content: Text(s.allowSmsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.allow),
          ),
        ],
      ),
    );

    if (result == true) {
      await requestSmsPermission();
    }
    // After SMS dialog, show notification dialog
    await _showNotificationDialog();
  }

  Future<void> _showNotificationDialog() async {
    final s = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined, size: 40, color: AppColors.primary),
        title: Text(s.allowNotificationsTitle),
        content: Text(s.allowNotificationsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.allow),
          ),
        ],
      ),
    );

    if (result == true) {
      // Request POST_NOTIFICATIONS permission (Android 13+ system dialog)
      await requestPostNotificationPermission();
      // Open notification listener settings so user can manually enable it
      try {
        await settingsChannel.invokeMethod('openNotificationSettings');
      } on PlatformException {
        // ignored
      }
    }

    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final isLast = _page == pages.length - 1;
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
                  if (_page > 0 && !isLast)
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
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = pages[i];
                  if (p.isLanguagePicker) {
                    return _LanguagePickerPage(
                      onSelectLanguage: (locale) {
                        context.read<AppState>().setLocale(locale);
                      },
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
              child: isLast
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
                            onPressed: _showSmsDialog,
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
  const _Page({
    required this.icon,
    required this.title,
    required this.body,
    this.isLanguagePicker = false,
  });
}
