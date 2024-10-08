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
  String _password = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

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
          : PasswordUIHelper.buildPasswordInput(
              context,
              true, // Immer `true`, weil wir das Layout für die erste Passwortvergabe anpassen
              (value) {
                setState(() {
                  _password = value;
                });
              },
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

  Widget _buildContent() {
    return _pages[_selectedIndex];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    GalerieScreen(), // Galerie-Seite
    SettingsScreen(),
  ];
}
