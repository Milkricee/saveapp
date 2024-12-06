import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SettingsManager {
  static const String _deleteAfterImportKey = 'delete_after_import';
  static const String _directoryPathKey = 'custom_directory_path';

  /// Setzt den Status für das automatische Löschen von Fotos nach dem Import.
  static Future<void> setDeleteAfterImport(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteAfterImportKey, value);
    debugPrint("Automatisches Löschen nach Import wurde auf $value gesetzt.");
  }

  /// Gibt den Status des automatischen Löschens nach dem Import zurück.
  static Future<bool> getDeleteAfterImport() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_deleteAfterImportKey) ?? false;
    debugPrint("Status des automatischen Löschens nach Import: $value");
    return value;
  }

  /// Erstellt den geheimen Ordner, falls er nicht existiert.
  /// Gibt den Pfad des geheimen Ordners zurück.
  static Future<String> getOrCreateSecretFolder() async {
    // Hole das externe Speicherverzeichnis
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception("Externer Speicher ist nicht verfügbar.");
    }

    // Definiere den Pfad des geheimen Ordners
    final secretFolderPath = "${directory.path}/MySecretVault";
    final secretFolder = Directory(secretFolderPath);

    // Prüfe, ob der Ordner existiert
    if (await secretFolder.exists()) {
      debugPrint("Geheimer Ordner existiert bereits: $secretFolderPath");
    } else {
      // Erstelle den Ordner und die .nomedia-Datei
      debugPrint("Geheimer Ordner existiert nicht, wird erstellt...");
      await secretFolder.create(recursive: true);
      await _createNoMediaFile(secretFolderPath);
      debugPrint("Geheimer Ordner wurde erstellt: $secretFolderPath");
    }

    // Rückgabe des Pfads
    return secretFolderPath;
  }

  /// Erstellt eine `.nomedia`-Datei im geheimen Ordner, um die Medienindexierung zu verhindern.
  static Future<void> _createNoMediaFile(String folderPath) async {
    final nomediaFile = File('$folderPath/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
      debugPrint(".nomedia-Datei wurde erstellt: $folderPath/.nomedia");
    } else {
      debugPrint(".nomedia-Datei existiert bereits: $folderPath/.nomedia");
    }
  }

  /// Speichert den Pfad des benutzerdefinierten Verzeichnisses.
  static Future<void> setDirectoryPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_directoryPathKey, path);
    debugPrint("Benutzerdefinierter Verzeichnispfad wurde gespeichert: $path");
  }

  /// Gibt den gespeicherten Pfad des benutzerdefinierten Verzeichnisses zurück.
  /// Gibt `null` zurück, wenn kein Pfad gespeichert ist.
  static Future<String?> getDirectoryPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_directoryPathKey);
    debugPrint("Gespeicherter Verzeichnispfad: $path");
    return path;
  }
}
