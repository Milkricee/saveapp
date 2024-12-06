import 'package:flutter/material.dart';
import 'package:saveapp/screens/change_password_screen.dart';
import 'package:saveapp/logik/biometrie.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricsEnabled = false;
  final BiometrieManager _biometrieManager = BiometrieManager();

  @override
  void initState() {
    super.initState();
    _loadBiometricsStatus();
    _loadDeleteAfterImportStatus(); // Lade den aktuellen Status aus dem SettingsManager
  }

  Future<void> _loadBiometricsStatus() async {
    bool isEnabled = await _biometrieManager.isBiometricsEnabled();
    if (mounted) {
      setState(() {
        _isBiometricsEnabled = isEnabled;
      });
    }
  }

  Future<void> _loadDeleteAfterImportStatus() async {
    if (mounted) {
      setState(() {
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      await _biometrieManager.setBiometricsEnabled(true);
    } else {
      await _biometrieManager.setBiometricsEnabled(false);
    }

    if (mounted) {
      setState(() {
        _isBiometricsEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometrie wurde ${_isBiometricsEnabled ? "aktiviert" : "deaktiviert"}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Passwort ändern:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
              child: const Text('Passwort ändern'),
            ),
            const SizedBox(height: 40),
            const Text(
              'Biometrie aktivieren',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text(' ${_isBiometricsEnabled ? "JA" : "NEIN"}'),
              value: _isBiometricsEnabled,
              onChanged: (bool value) {
                _toggleBiometrics(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
