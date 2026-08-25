import 'package:flutter/material.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/onboarding_screen.dart';
import 'package:mapato/screens/root.dart';
import 'package:mapato/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final onboarded = await getPrefBool('onboarded');
    if (!mounted) return;
    if (onboarded) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const Root()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mapato',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.tagline,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
