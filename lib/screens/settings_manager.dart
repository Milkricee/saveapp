import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _deleteAfterImportKey = 'delete_after_import';
  static const String _directoryPathKey = 'custom_directory_path'; // Schlüssel für den Ordnerpfad

  // Legt fest, ob Fotos nach dem Import gelöscht werden sollen.
  static Future<void> setDeleteAfterImport(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteAfterImportKey, value);
  }

  // Lädt den Status für automatisches Löschen nach dem Import.
  static Future<bool> getDeleteAfterImport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deleteAfterImportKey) ?? false;
  }

  // Speichert den vom Nutzer gewählten Ordnerpfad.
  static Future<void> setDirectoryPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_directoryPathKey, path);
  }

  // Lädt den gespeicherten Ordnerpfad.
  static Future<String?> getDirectoryPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_directoryPathKey);
  }
}
