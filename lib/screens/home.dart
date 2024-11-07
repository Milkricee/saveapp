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
  final HomeScreenLogic _logic = HomeScreenLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Safe'),
      ),
      backgroundColor: Colors.white, // Hintergrundfarbe des Screens
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Einheitliches Padding für den Body
        child: _pages[_logic.selectedIndex],
      ),
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
        onTap: (index) => _logic.onItemTapped(index, setState),
      ),
    );
  }

  static const List<Widget> _pages = <Widget>[
    GalerieScreen(), // Galerie-Seite einfügen
    SettingsScreen(),
  ];
}

