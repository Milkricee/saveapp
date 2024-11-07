import 'package:flutter/material.dart';
import 'package:saveapp/screens/login_page.dart'; // Importiere die Login-Seite

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const SaveApp());
}

class SaveApp extends StatefulWidget {
  const SaveApp({super.key});

  @override
  State<SaveApp> createState() => SaveAppState();
}

class SaveAppState extends State<SaveApp> with WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Lifecycle-Observer hinzufügen
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer entfernen
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState changed to: $state');

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToLogin(); // Navigiere zur Login-Seite nach Rückkehr
      });
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _wasInBackground = true;
      debugPrint('App wurde in den Hintergrund verschoben, _wasInBackground = $_wasInBackground');
    }
  }

  Future<void> _navigateToLogin() async {
    // Verwende den globalen Navigator-Schlüssel
    debugPrint('Navigating to LoginPage...');
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Hintergrundfarbe setzen
      ),
      navigatorKey: navigatorKey,
      home: const LoginPage(), // Home- oder Login-Seite einbinden
      debugShowCheckedModeBanner: false,
    );
  }
}
