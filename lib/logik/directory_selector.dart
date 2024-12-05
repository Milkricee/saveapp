import 'package:file_selector/file_selector.dart'; // Stellt getDirectoryPath() bereit
import '../screens/settings_manager.dart'; // Pfad zum SettingsManager anpassen, falls nötig

class DirectorySelector {
  /// Öffnet den Ordner-Auswahldialog des Systems (SAF auf Android) und gibt den gewählten Pfad zurück.
  /// Gibt `null` zurück, wenn der Nutzer den Dialog abbricht.
  static Future<String?> selectDirectory() async {
    // Ruft den nativen Ordnerpicker auf.
    final selectedDirectory = await getDirectoryPath(); // Diese Funktion kommt aus file_selector

    // Wenn ein Ordner gewählt wurde, speichere den Pfad.
    if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
      await SettingsManager.setDirectoryPath(selectedDirectory);
    }

    return selectedDirectory;
  }

  /// Lädt den zuvor gespeicherten Ordnerpfad aus den Einstellungen.
  /// Gibt null zurück, wenn noch kein Ordner gesetzt wurde.
  static Future<String?> loadSavedDirectoryPath() async {
    return await SettingsManager.getDirectoryPath();
  }
}
