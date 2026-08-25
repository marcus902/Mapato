import 'package:flutter/material.dart';
import 'package:mapato/native.dart';
import 'package:mapato/screens/add_screen.dart';
import 'package:mapato/screens/home_screen.dart';
import 'package:mapato/screens/pin_screen.dart';
import 'package:mapato/screens/settings_screen.dart';
import 'package:mapato/screens/transactions_screen.dart';
import 'package:mapato/state/app_state.dart';
import 'package:provider/provider.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> with WidgetsBindingObserver {
  int _index = 0;
  late final _pages = [
    HomeScreen(onOpenSettings: () => setState(() => _index = 3)),
    const TransactionsScreen(),
    const AddScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().startNotificationCapture();
      requestPostNotificationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<AppState>().relock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.pinReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.pinEnabled && !state.pinUnlocked) {
      return PinScreen(
        mode: PinMode.unlock,
        onSuccess: () => state.unlock(),
      );
    }
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Txns'),
          NavigationDestination(icon: Icon(Icons.add), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
