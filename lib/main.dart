import 'package:flutter/material.dart';
import 'package:saveapp/screens/login_page.dart'; // Importiere die Login-Seite
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const SaveApp());
}

class SaveApp extends StatelessWidget {
  const SaveApp({super.key});

  Future<void> requestPermissions() async {
    // Speicherzugriffsberechtigung anfordern
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    // Die biometrische Berechtigung wird hier nicht angefordert, 
    // sie wird durch die local_auth-Bibliothek verwaltet.
  }

  @override
  Widget build(BuildContext context) {
    // Berechtigungen beim Start anfordern
    requestPermissions(); 

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
