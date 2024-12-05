import 'package:flutter/material.dart';
import 'package:saveapp/screens/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
    WidgetsBinding.instance.addObserver(this);
    _requestAllStoragePermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

Future<void> _requestAllStoragePermissions() async {
  // Erst normale Speicherberechtigung anfragen
  var status = await Permission.storage.request();

  if (status.isGranted) {
    // Unter Android 11+ könnte trotzdem ein eingeschränkter Zugriff vorliegen.
    // Wir prüfen, ob MANAGE_EXTERNAL_STORAGE verfügbar ist:
    if (Platform.isAndroid) {
      // Prüfen ob MANAGE_EXTERNAL_STORAGE nötig ist:
      // Ab Android 11 (API 30) ist das relevant.
      var manageStorageStatus = await Permission.manageExternalStorage.request();

      // Wir warten einen Frame, um sicherzustellen, dass der Build-Prozess abgeschlossen ist,
      // bevor wir eine SnackBar anzeigen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (manageStorageStatus.isGranted) {
          ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
            const SnackBar(content: Text('Voller Speicherzugriff erteilt!')),
          );
        } else {
          ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
            const SnackBar(content: Text('Eingeschränkter Speicherzugriff. Bitte alle Dateien zulassen.')),
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
          const SnackBar(content: Text('Speicherzugriff erteilt!')),
        );
      });
    }
  } else {
    // Hier könntest du eine Meldung anzeigen, dass ohne Berechtigungen nichts geht.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        const SnackBar(content: Text('Speicherzugriff verweigert! Bitte Berechtigungen in den Einstellungen erlauben.')),
      );
    });
  }
}


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState changed to: $state');

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToLogin();
      });
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _wasInBackground = true;
      debugPrint('App wurde in den Hintergrund verschoben, _wasInBackground = $_wasInBackground');
    }
  }

  Future<void> _navigateToLogin() async {
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
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorKey: navigatorKey,
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
