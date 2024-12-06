import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Für Zugriff auf öffentliche Verzeichnisse
import '../screens/settings_manager.dart'; // Pfad zum SettingsManager anpassen, falls nötig

class DirectorySelector {
  /// Erstellt automatisch einen geheimen Ordner im öffentlichen Verzeichnis (z. B. Dokumente).
  /// Gibt den Pfad des erstellten Ordners zurück.
  static Future<String> createSecretFolder() async {
    // Hole das öffentliche Dokumentenverzeichnis
    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      throw Exception("Externer Speicher ist nicht verfügbar");
    }

    // Erstelle einen Unterordner für die App
    final secretFolderPath = "${directory.path}/MySecretVault";
    final secretFolder = Directory(secretFolderPath);

    if (!await secretFolder.exists()) {
      await secretFolder.create(recursive: true);
    }

    // Speichere den Pfad im SettingsManager
    await SettingsManager.setDirectoryPath(secretFolderPath);

    // Sicherstellen, dass eine .nomedia-Datei existiert
    final nomediaFile = File('$secretFolderPath/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
    }

    return secretFolderPath;
  }

  /// Lädt den zuvor gespeicherten Ordnerpfad aus den Einstellungen.
  /// Gibt null zurück, wenn noch kein Ordner gesetzt wurde.
  static Future<String?> loadSavedDirectoryPath() async {
    return await SettingsManager.getDirectoryPath();
  }
}
