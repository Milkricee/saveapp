import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'encryption.dart';

class FileManager {
  // Pfad zum lokalen Verzeichnis für verschlüsselte Fotos
  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Fotos importieren und verschlüsseln (unterstützt Mehrfachauswahl)
  static Future<void> importPhotos(BuildContext context, Function(List<File>, List<File>) onPhotosImported) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // Mehrfachauswahl

    if (pickedFiles.isNotEmpty) {
      final localPath = await _getLocalPath();
      List<File> importedFiles = [];
      List<File> importedThumbnails = [];

      for (var pickedFile in pickedFiles) {
        final photoFile = File(pickedFile.path);
        final encryptedFilePath = '$localPath/${DateTime.now().millisecondsSinceEpoch}.enc';

        // Foto verschlüsseln und speichern
        final encryptedData = await Encryption.encryptFile(photoFile);
        final encryptedFile = File(encryptedFilePath);
        await encryptedFile.writeAsBytes(encryptedData);

        // Generiere das Thumbnail und speichere es unverschlüsselt
        final thumbnailFile = await Encryption.generateThumbnail(photoFile, localPath);

        // Originaldatei nach Verschlüsselung löschen
        await photoFile.delete();

        // Verschlüsseltes Foto und unverschlüsseltes Thumbnail zur Galerie hinzufügen
        importedFiles.add(encryptedFile);
        importedThumbnails.add(thumbnailFile);
      }

      // Galerie aktualisieren
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${importedFiles.length} Foto(s) erfolgreich importiert und verschlüsselt!')),
        );

        // Aktualisiere die Galerie mit den neuen Fotos und Thumbnails
        onPhotosImported(importedFiles, importedThumbnails);
      }
    }
  }

  // Foto löschen (sowohl verschlüsselte Datei als auch unverschlüsseltes Thumbnail)
  static Future<void> deletePhoto(File encryptedFile, File? thumbnailFile) async {
    if (await encryptedFile.exists()) {
      await encryptedFile.delete();
    }
    if (thumbnailFile != null && await thumbnailFile.exists()) {
      await thumbnailFile.delete();
    }
  }

  // Verschlüsselte Fotos und unverschlüsselte Thumbnails aus dem lokalen Verzeichnis laden
  static Future<Map<String, List<File>>> loadEncryptedFiles() async {
    final localPath = await _getLocalPath();
    final directory = Directory(localPath);
    final files = directory.listSync().whereType<File>().toList();

    List<File> encryptedPhotos = [];
    List<File> thumbnails = [];

    for (var file in files) {
      if (file.path.endsWith('.enc')) {
        encryptedPhotos.add(file); // Normale verschlüsselte Foto-Datei
      } else if (file.path.contains('thumbnail_')) {
        thumbnails.add(file); // Unverschlüsseltes Thumbnail
      }
    }

    return {
      'photos': encryptedPhotos,
      'thumbnails': thumbnails,
    };
  }
}
