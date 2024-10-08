import 'package:flutter/material.dart';
import 'package:saveapp/screens/login_page.dart'; // Importiere die Login-Seite

void main() {
  runApp(const SaveApp());
}

class SaveApp extends StatelessWidget {
  const SaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foto-Safe-App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // LoginPage als Startseite festlegen
      debugShowCheckedModeBanner: false, // Entfernt das Debug-Banner im Web
    );
  }
}
