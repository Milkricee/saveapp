import 'dart:io';
import 'package:file_selector/file_selector.dart'; // SAF-Unterstützung
import '../screens/settings_manager.dart';
import 'package:path_provider/path_provider.dart';


class GalerieManager {
  Future<List<File>> loadPhotos() async {
    // Lade den benutzerdefinierten Ordnerpfad
    final customPath = await SettingsManager.getDirectoryPath();

    if (customPath == null || customPath.isEmpty) {
      throw Exception('Kein Ordner ausgewählt. Bitte wählen Sie einen Speicherordner aus.');
    }

    // Prüfe, ob der Pfad ein `content://` URI (SAF) ist
    if (customPath.startsWith('content://')) {
      // SAF Pfad laden
      return _loadPhotosFromSaf();
    } else {
      // Klassischer Zugriff über `Directory`
      return _loadPhotosFromDirectory(customPath);
    }
  }

  /// Lädt Fotos aus einem klassischen Verzeichnis.
  Future<List<File>> _loadPhotosFromDirectory(String path) async {
    final directory = Directory(path);

    if (!await directory.exists()) {
      throw Exception('Der ausgewählte Ordner existiert nicht.');
    }

    // Lade Dateien mit bestimmten Endungen
    final files = directory.listSync().whereType<File>().toList();
    return files.where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png') || file.path.endsWith('.enc')).toList();
  }

  /// Lädt Fotos aus einem SAF-Ordner (für Android 11+).
  Future<List<File>> _loadPhotosFromSaf() async {
    final List<File> files = [];

    // SAF-Zugriff über `file_selector`
    final directoryPath = await getDirectoryPath(); // Benutzer wählt den Ordner
    if (directoryPath == null || directoryPath.isEmpty) {
      throw Exception('Kein Ordner ausgewählt oder Zugriff verweigert.');
    }

    // Inhalte des Verzeichnisses laden
    final directoryEntries = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(extensions: ['.jpg', '.png', '.enc']),
      ],
      initialDirectory: directoryPath,
    );

    for (var entry in directoryEntries) {
      // Temporäre Datei aus SAF-Inhalt erstellen
      final tempFile = await _createTempFileFromSafEntry(entry);
      files.add(tempFile);
    }
    return files;
  }

  /// Erstellt eine temporäre Datei aus einem SAF-Eintrag.
  Future<File> _createTempFileFromSafEntry(XFile entry) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/${entry.name}';
    final tempFile = File(tempFilePath);

    // Kopiert den Inhalt des SAF-Eintrags in die temporäre Datei
    final data = await entry.readAsBytes();
    await tempFile.writeAsBytes(data);
    return tempFile;
  }
}
