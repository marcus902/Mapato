import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/root.dart';
import 'package:mapato/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _Page(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Welcome to Mapato',
      body: 'The personal finance tracker built for every Tanzanian '
          'mobile-money wallet.',
    ),
    _Page(
      icon: Icons.smartphone_rounded,
      title: 'Captures every wallet',
      body: 'Automatically reads your M-Pesa, Mixx by Yas, Airtel Money, '
          'HaloPesa & AzamPesa transactions — via notifications and SMS.',
    ),
    _Page(
      icon: Icons.lock_outline_rounded,
      title: 'Private by design',
      body: 'Everything is processed and stored on your device. '
          'Your financial data never leaves your phone.',
    ),
    _Page(
      icon: Icons.insights_rounded,
      title: 'Beautiful insights',
      body: 'See income, expenses, and exactly where your money goes — '
          'by category and by network.',
    ),
  ];

  Future<void> _finish() async {
    await setPrefBool('onboarded', true);
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const Root()));
  }

  Future<void> _openNotifications() async {
    try {
      await settingsChannel.invokeMethod('openNotificationSettings');
    } on PlatformException {
      // ignored
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
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
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
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
                _pages.length,
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
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: _openNotifications,
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('Enable notification access'),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _finish,
                            child: const Text('Get started'),
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
                        child: const Text('Next'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String body;
  const _Page({required this.icon, required this.title, required this.body});
}
