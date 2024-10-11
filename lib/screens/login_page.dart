import 'package:flutter/material.dart';
import 'package:saveapp/screens/animated_image_switcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saveapp/logik/password_manager.dart';
import 'package:saveapp/logik/biometrie.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _password = '';
  String _confirmPassword = '';
  bool _isPasswordSet = false;
  bool _canCheckBiometrics = false;
  bool _isBiometricsEnabled = false;

  final BiometrieManager _biometrieManager = BiometrieManager();

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
    _checkBiometricsStatus();
  }

  Future<void> _checkPasswordStatus() async {
    bool passwordExists = await PasswordManager.doesPasswordExist();
    setState(() {
      _isPasswordSet = passwordExists;
    });
  }

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

  Future<void> _verifyPassword() async {
    bool isValid = await PasswordManager.verifyPassword(_password);
    if (!mounted) return;
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

  Future<void> _setNewPassword() async {
    if (_password == _confirmPassword) {
      await PasswordManager.setNewPassword(_password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort erfolgreich festgelegt!')),
      );
      await _verifyPassword();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwörter stimmen nicht überein!')),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    bool authenticated = await _biometrieManager.authenticateWithBiometrics();
    if (!mounted) return;
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

  Future<void> _launchPaypal() async {
    const url = 'https://paypal.me/miedrei?country.x=DE&locale.x=de_DE';
    final Uri paypalUri = Uri.parse(url);
    if (await canLaunchUrl(paypalUri)) {
      await launchUrl(paypalUri);
    } else {
      throw 'Konnte PayPal-Link nicht öffnen $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Zentriert den Inhalt
          crossAxisAlignment: CrossAxisAlignment.stretch, // Dehnt die Textfelder auf die Breite aus
          children: [
            GestureDetector(
              onTap: _launchPaypal,
              child: const SizedBox(
                height: 150, // Höhe des Bildbereichs
                child: ImageAnimation(), // Animation der Bilder
              ),
            ),
            const SizedBox(height: 20),
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
            if (!_isPasswordSet)
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
                  await _setNewPassword();
                }
              },
              child: Text(_isPasswordSet ? 'Anmelden' : 'Passwort festlegen'),
            ),
            if (_canCheckBiometrics && _isBiometricsEnabled)
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
    );
  }
}
