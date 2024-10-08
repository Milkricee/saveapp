import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Einstellungen für die App:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '• Passwort ändern',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• Biometrie aktivieren/deaktivieren',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '• (Zukünftig) Cloud-Synchronisation konfigurieren',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
