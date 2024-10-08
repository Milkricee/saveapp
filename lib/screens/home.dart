import 'package:flutter/material.dart';
import 'package:saveapp/logik/home_screen_logic.dart'; // Importiere die Logik-Datei
import 'galerie.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final HomeScreenLogic _logic = HomeScreenLogic(); // Logik-Instanz erstellen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto-Safe-App'),
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _logic.selectedIndex,
        onTap: (index) => _logic.onItemTapped(index, setState), // Logik verwenden
      ),
    );
  }

  Widget _buildContent() {
    return _pages[_logic.selectedIndex];
  }

  static const List<Widget> _pages = <Widget>[
    GalerieScreen(),
    SettingsScreen(),
  ];
}
