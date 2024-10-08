import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordManager {
  static const String _passwordKey = 'user_password'; // Schlüssel für das gespeicherte Passwort
  static const _storage = FlutterSecureStorage();

  // Setzt ein neues Passwort in den sicheren Speicher
  static Future<void> setNewPassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }

  // Überprüft, ob ein Passwort bereits existiert
  static Future<bool> doesPasswordExist() async {
    String? storedPassword = await _storage.read(key: _passwordKey);
    return storedPassword != null;
  }

  // Überprüft das eingegebene Passwort mit dem gespeicherten Passwort
  static Future<bool> verifyPassword(String enteredPassword) async {
    String? storedPassword = await _storage.read(key: _passwordKey);
    return storedPassword == enteredPassword;
  }
}
