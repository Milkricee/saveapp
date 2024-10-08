import 'package:flutter/material.dart';
import 'package:saveapp/logik/password_ui_helper.dart';
import 'package:saveapp/logik/password_manager.dart';
import 'galerie.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isPasswordSet = false;
  bool _isPasswordVerified = false; // Speichert, ob das Passwort eingegeben wurde

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observer hinzufügen
    _checkPasswordStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer entfernen
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App wurde aus dem Hintergrund wieder geöffnet
      setState(() {
        _isPasswordVerified = false; // Passwortabfrage erzwingen
      });
    }
  }

  // Prüft, ob ein Passwort bereits gesetzt ist
  Future<void> _checkPasswordStatus() async {
    bool passwordExists = await PasswordUIHelper.isPasswordSet();
    if (!mounted) return; // Überprüft, ob das Widget noch aktiv ist
    setState(() {
      _isPasswordSet = passwordExists;
      _isPasswordVerified = !passwordExists; // Kein Passwort -> Kein Login nötig
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto-Safe-App'),
      ),
      body: _isPasswordSet && !_isPasswordVerified
          ? _buildPasswordPrompt() // Passwortabfrage anzeigen
          : _buildContent(),
      bottomNavigationBar: _isPasswordSet && _isPasswordVerified
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_library),
                  label: 'Galerie',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Einstellungen',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
    );
  }

  // Zeigt die Passwortabfrage an
  Widget _buildPasswordPrompt() {
    return PasswordUIHelper.buildPasswordCheckInput(
      context,
      (enteredPassword) async {
        bool isValid = await PasswordManager.verifyPassword(enteredPassword);
        if (!mounted) return; // Überprüfen, ob das Widget noch aktiv ist
        if (isValid) {
          setState(() {
            _isPasswordVerified = true; // Passwort korrekt -> Zugriff erlauben
          });
        } else {
          // Überprüfen, ob das Widget noch gemounted ist, bevor der Kontext verwendet wird
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Falsches Passwort!')),
            );
          }
        }
      },
      () {},
    );
  }

  // App-Inhalt nach erfolgreicher Passwortvergabe
  Widget _buildContent() {
    return _pages[_selectedIndex];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    GalerieScreen(),
    SettingsScreen(),
  ];
}
