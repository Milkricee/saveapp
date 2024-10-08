import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordManager {
  static const _storage = FlutterSecureStorage();
  static const _passwordKey = 'user_password';

  // Prüft, ob ein Passwort bereits existiert
  static Future<bool> doesPasswordExist() async {
    String? password = await _storage.read(key: _passwordKey);
    return password != null;
  }

  // Setzt ein neues Passwort, wenn keines vorhanden ist
  static Future<void> setNewPassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }

  // Überprüft, ob das eingegebene Passwort korrekt ist
  static Future<bool> checkPassword(String enteredPassword) async {
    String? savedPassword = await _storage.read(key: _passwordKey);
    return savedPassword == enteredPassword;
  }
}
