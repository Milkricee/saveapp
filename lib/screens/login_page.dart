import 'package:flutter/material.dart';
import 'package:saveapp/logik/password_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  // Überprüft, ob ein Passwort bereits gesetzt ist
  Future<void> _checkPasswordStatus() async {
    bool passwordExists = await PasswordManager.doesPasswordExist();
    setState(() {
      _isPasswordSet = passwordExists;
    });
  }

  // Überprüft das eingegebene Passwort und leitet weiter
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto-Safe Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
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
                },
                child: Text(_isPasswordSet ? 'Anmelden' : 'Passwort festlegen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
