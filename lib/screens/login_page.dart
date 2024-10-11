// lib/screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:saveapp/logik/password_manager.dart';
import 'package:saveapp/logik/biometrie.dart'; // Importiere die BiometrieManager
import 'home.dart'; // Importiere den HomeScreen für die Navigation

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _password = '';
  String _confirmPassword = ''; // Bestätigungspasswort
  bool _isPasswordSet = false;
  bool _canCheckBiometrics = false;
  bool _isBiometricsEnabled = false;

  final BiometrieManager _biometrieManager = BiometrieManager();

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
    _checkBiometricsStatus(); // Automatische biometrische Prüfung
  }

  // Überprüft, ob ein Passwort bereits gesetzt ist
  Future<void> _checkPasswordStatus() async {
    bool passwordExists = await PasswordManager.doesPasswordExist();
    setState(() {
      _isPasswordSet = passwordExists;
    });
  }

  // Überprüft den Status der Biometrie und startet ggf. die Authentifizierung
  Future<void> _checkBiometricsStatus() async {
    _canCheckBiometrics = await _biometrieManager.canCheckBiometrics();
    _isBiometricsEnabled = await _biometrieManager.isBiometricsEnabled();

    if (_canCheckBiometrics && _isBiometricsEnabled) {
      bool authenticated = await _biometrieManager.authenticateWithBiometrics();
      if (authenticated) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  // Überprüft das eingegebene Passwort und leitet weiter
 Future<void> _verifyPassword() async {
  bool isValid = await PasswordManager.verifyPassword(_password);
  if (!mounted) return; // Check if the widget is still mounted before using the context
  if (isValid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Falsches Passwort!')),
    );
  }
}


  // Überprüft, ob beide Passwörter übereinstimmen und setzt das neue Passwort
  Future<void> _setNewPassword() async {
    if (_password == _confirmPassword) {
      await PasswordManager.setNewPassword(_password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort erfolgreich festgelegt!')),
      );
      await _verifyPassword(); // Direkt zum HomeScreen weiterleiten
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwörter stimmen nicht überein!')),
      );
    }
  }

  // Handhabt die biometrische Anmeldung über den Button
Future<void> _handleBiometricLogin() async {
  bool authenticated = await _biometrieManager.authenticateWithBiometrics();
  if (!mounted) return; // Check if the widget is still mounted before using the context
  if (authenticated) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biometrische Authentifizierung fehlgeschlagen!')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto-Safe Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView( // Ermöglicht Scrollen bei kleinen Bildschirmen
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isPasswordSet ? 'Bitte Passwort eingeben:' : 'Bitte neues Passwort festlegen:',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  onChanged: (value) => _password = value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Passwort',
                  ),
                ),
                if (!_isPasswordSet) // Wenn Passwort noch nicht gesetzt ist, zeige zweite Eingabe
                  const SizedBox(height: 20),
                if (!_isPasswordSet)
                  TextField(
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    onChanged: (value) => _confirmPassword = value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Passwort bestätigen',
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_isPasswordSet) {
                      await _verifyPassword();
                    } else {
                      // Überprüfen, ob das Passwort korrekt bestätigt wurde
                      await _setNewPassword();
                    }
                  },
                  child: Text(_isPasswordSet ? 'Anmelden' : 'Passwort festlegen'),
                ),
                if (_canCheckBiometrics && _isBiometricsEnabled) // Wenn Biometrie verfügbar und aktiviert ist, zeige zusätzlichen Button
                  const SizedBox(height: 20),
                if (_canCheckBiometrics && _isBiometricsEnabled)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _handleBiometricLogin();
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Mit Fingerabdruck anmelden'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
