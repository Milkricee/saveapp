import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saveapp/logik/encryption.dart';
import 'dart:typed_data';

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

  // Pfad zum lokalen Verzeichnis für importierte Fotos
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Fotos importieren
  static Future<void> importPhotos(BuildContext context, Function(List<File>) onPhotosImported) async {
    if (_isPickerActive) return; // Wenn bereits aktiv, nichts tun
    _isPickerActive = true;

    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); // Mehrfachauswahl

      // Lade den Status des automatischen Löschens aus den Einstellungen
      bool deleteAfterImport = await SettingsManager.getDeleteAfterImport();

      if (pickedFiles.isNotEmpty) {
        final localPath = await getLocalPath();
        List<File> encryptedFiles = [];

        for (var pickedFile in pickedFiles) {
          final photoFile = File(pickedFile.path);

          // Überprüfe Dateiformat auf `.jpg` oder `.png`
          if (!photoFile.path.endsWith('.jpg') && !photoFile.path.endsWith('.png')) {
            continue; // Überspringe Dateien, die nicht im richtigen Format sind
          }

          final encryptedFilePath = '$localPath/${DateTime.now().millisecondsSinceEpoch}.enc';

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
              '${encryptedFiles.length} Foto(s) erfolgreich importiert, verschlüsselt${deleteAfterImport ? " und Originale gelöscht" : ""}!'
            ),
          ),
        );
        onPhotosImported(encryptedFiles);
      }
    } finally {
      _isPickerActive = false;
    }
  }

  // Fügt Fotos zur Container-Datei hinzu
  static Future<void> addPhotosToContainer(BuildContext context, Function() onContainerUpdated) async {
    final containerPath = '${await getLocalPath()}/photo_container.enc';

    // Entschlüssel vorhandene Container-Datei, wenn sie existiert
    List<File> existingPhotos = [];
    if (File(containerPath).existsSync()) {
      final decryptedBytes = await Encryption.decryptFile(File(containerPath));
      existingPhotos = await _extractPhotosFromBytes(decryptedBytes);
    }

    // Füge neue Fotos hinzu
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        existingPhotos.add(File(pickedFile.path));
      }

      // Speichere alle Fotos in einer verschlüsselten Container-Datei
      final newEncryptedData = await _createEncryptedContainer(existingPhotos);
      await File(containerPath).writeAsBytes(newEncryptedData);

      if (!context.mounted) return; // mounted check

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotos erfolgreich zum Container hinzugefügt!')),
      );
      onContainerUpdated();
    }
  }

  // Lädt Fotos aus dem verschlüsselten Container
  static Future<List<File>> loadContainer() async {
    final containerPath = '${await getLocalPath()}/photo_container.enc';

    if (File(containerPath).existsSync()) {
      final decryptedBytes = await Encryption.decryptFile(File(containerPath));
      return _extractPhotosFromBytes(decryptedBytes);
    }
    return [];
  }

  // Konvertiert eine Liste von Fotos in eine verschlüsselte Byte-Liste
  static Future<Uint8List> _createEncryptedContainer(List<File> photos) async {
    final allBytes = <int>[];

    for (var photo in photos) {
      allBytes.addAll(await photo.readAsBytes());
    }

    final containerBytes = Uint8List.fromList(allBytes);
    return await Encryption.encryptBytes(containerBytes);
  }

  // Extrahiert einzelne Fotos aus einer entschlüsselten Byte-Liste
  static Future<List<File>> _extractPhotosFromBytes(Uint8List containerBytes) async {
    final tempPath = await getLocalPath();
    final extractedFiles = <File>[];
    int index = 0;

    while (index < containerBytes.length) {
      // Erstelle eine temporäre Datei für jedes Foto
      final photoBytes = containerBytes.sublist(index, index + 1024 * 100); // Beispielgröße
      final photoFile = File('$tempPath/extracted_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await photoFile.writeAsBytes(photoBytes);
      extractedFiles.add(photoFile);
      index += 1024 * 100; // Beispielgröße
    }

    return extractedFiles;
  }

  // Fotos aus dem lokalen Verzeichnis laden
  static Future<List<File>> loadPhotos() async {
    final localPath = await getLocalPath();
    final photoDirectory = Directory(localPath);

    if (!photoDirectory.existsSync()) {
      photoDirectory.createSync(); // Erstelle das Verzeichnis, falls es nicht existiert
    }

    // Lade alle Dateien mit den Endungen .jpg, .png oder .enc
    return photoDirectory
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('.jpg') ||
            file.path.endsWith('.png') ||
            file.path.endsWith('.enc'))
        .toList();
  }
}
