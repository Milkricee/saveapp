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

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isPasswordSet = false;
  bool _isFirstPasswordInput = true;
  String _password = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  // Prüft, ob ein Passwort bereits gesetzt ist (Verwendung der ausgelagerten Logik)
  Future<void> _checkPasswordStatus() async {
    bool passwordExists = await PasswordUIHelper.isPasswordSet();
    setState(() {
      _isPasswordSet = passwordExists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto-Safe-App'),
      ),
      body: _isPasswordSet
          ? _buildContent()
          : _isFirstPasswordInput
              ? PasswordUIHelper.buildPasswordInput(
                  context,
                  _isFirstPasswordInput,
                  (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                  () {
                    setState(() {
                      _isFirstPasswordInput = false;
                    });
                  },
                )
              : PasswordUIHelper.buildPasswordInput(
                  context,
                  _isFirstPasswordInput,
                  (value) {
                    setState(() {
                      _confirmPassword = value;
                    });
                  },
                  () async {
                    if (_password == _confirmPassword) {
                      await PasswordManager.setNewPassword(_password);
                      setState(() {
                        _isPasswordSet = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwörter stimmen nicht überein!')),
                      );
                    }
                  },
                ),
      bottomNavigationBar: _isPasswordSet
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
