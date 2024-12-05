import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _deleteAfterImportKey = 'delete_after_import';

  // Setze den Wert
  static Future<void> setDeleteAfterImport(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteAfterImportKey, value);
  }

  // Hole den Wert (Standard: false, falls noch nicht gesetzt)
  static Future<bool> getDeleteAfterImport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deleteAfterImportKey) ?? false;
  }
}
