import 'package:flutter/material.dart';
import 'package:saveapp/logik/password_manager.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    // Überprüfe, ob das alte Passwort korrekt ist
    bool isOldPasswordValid = await PasswordManager.verifyPassword(oldPassword);

    if (!isOldPasswordValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Altes Passwort ist falsch!')),
        );
      }
      return;
    }

    // Überprüfe, ob das neue Passwort korrekt bestätigt wurde und nicht leer ist
    if (newPassword.isNotEmpty && newPassword == confirmNewPassword) {
      await PasswordManager.setNewPassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwort erfolgreich geändert!')),
        );

        Navigator.pop(context); // Schließe die Seite nach erfolgreicher Änderung
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwörter stimmen nicht überein!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwort ändern'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Altes Passwort:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Altes Passwort',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Neues Passwort:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Neues Passwort',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Neues Passwort bestätigen:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmNewPasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Neues Passwort bestätigen',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Passwort ändern'),
            ),
          ],
        ),
      ),
    );
  }
}
