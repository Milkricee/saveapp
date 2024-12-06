import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saveapp/logik/encryption.dart';
import 'directory_selector.dart';
import '../screens/settings_manager.dart';

class FileManager {
  // Statusvariable, um den mehrfachen Aufruf zu verhindern
  static bool _isPickerActive = false;

  // Überprüft und fordert die Berechtigungen an
  static Future<bool> checkAndRequestPermissions() async {
    final status = await Permission.storage.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  // Fotos importieren und im benutzerdefinierten Ordner speichern
  static Future<void> importPhotos(BuildContext context, Function(List<File>) onPhotosImported) async {
    if (_isPickerActive) return; // Wenn bereits aktiv, nichts tun
    _isPickerActive = true;

    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); // Mehrfachauswahl

      // Lade den Status des automatischen Löschens aus den Einstellungen
      bool deleteAfterImport = await SettingsManager.getDeleteAfterImport();

      // Lade den benutzerdefinierten Ordnerpfad
      final customPath = await DirectorySelector.loadSavedDirectoryPath();
      if (customPath == null || customPath.isEmpty) {
        throw Exception('Kein Zielordner ausgewählt. Bitte wählen Sie einen Ordner aus.');
      }

      // Sicherstellen, dass der Ordner existiert und eine .nomedia-Datei enthält
      await _ensureNoMediaFile(customPath);

      if (pickedFiles.isNotEmpty) {
        List<File> encryptedFiles = [];

        for (var pickedFile in pickedFiles) {
          final photoFile = File(pickedFile.path);

          // Überprüfe Dateiformat auf `.jpg` oder `.png`
          if (!photoFile.path.endsWith('.jpg') && !photoFile.path.endsWith('.png')) {
            continue; // Überspringe Dateien, die nicht im richtigen Format sind
          }

          final encryptedFilePath = '$customPath/${DateTime.now().millisecondsSinceEpoch}.enc';

          // Verschlüssele das Foto und speichere es
          final encryptedBytes = await Encryption.encryptFile(photoFile);
          final encryptedFile = File(encryptedFilePath);
          await encryptedFile.writeAsBytes(encryptedBytes);

          encryptedFiles.add(encryptedFile);

          // Wenn der automatische Löschmodus aktiviert ist, lösche das Originalfoto
          if (deleteAfterImport) {
            try {
              if (await photoFile.exists()) {
                await photoFile.delete();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler beim Löschen des Originalfotos: ${photoFile.path}')),
                );
              }
            }
          }
        }

        if (!context.mounted) return; // mounted check

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${encryptedFiles.length} Foto(s) erfolgreich importiert, verschlüsselt${deleteAfterImport ? " und Originale gelöscht" : ""}!',
            ),
          ),
        );
        onPhotosImported(encryptedFiles);
      }
    } finally {
      _isPickerActive = false;
    }
  }

  // Stellt sicher, dass der benutzerdefinierte Ordner existiert und eine .nomedia-Datei enthält
  static Future<void> _ensureNoMediaFile(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final nomediaFile = File('$folderPath/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
    }
  }

  // Fotos aus dem benutzerdefinierten Ordnerpfad laden
 static Future<List<File>> loadPhotos() async {
  final customPath = await DirectorySelector.loadSavedDirectoryPath();

  // Wenn kein Zielordner gesetzt ist, leere Liste zurückgeben
  if (customPath == null || customPath.isEmpty) {
    return [];
  }

  final directory = Directory(customPath);

  if (!await directory.exists()) {
    return [];
  }

  final files = directory.listSync().whereType<File>().toList();
  return files
      .where((file) =>
          file.path.endsWith('.jpg') ||
          file.path.endsWith('.png') ||
          file.path.endsWith('.enc'))
      .toList();
}

}
