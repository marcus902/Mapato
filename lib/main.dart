import 'package:flutter/material.dart';
import 'package:mapato/screens/splash_screen.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MapatoApp());
}

class MapatoApp extends StatelessWidget {
  const MapatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, _) => MaterialApp(
          title: 'Mapato',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: state.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
