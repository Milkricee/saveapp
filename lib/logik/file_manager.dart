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

        // Generiere und verschlüssele das Thumbnail
        final thumbnailFile = await Encryption.generateThumbnail(photoFile, localPath);
        final encryptedThumbnailFile = await Encryption.encryptThumbnail(thumbnailFile, localPath);

        // Originaldatei nach Verschlüsselung löschen
        await photoFile.delete();
        await thumbnailFile.delete(); // Unverschlüsseltes Thumbnail löschen

        // Verschlüsseltes Thumbnail und Foto zur Galerie hinzufügen
        importedFiles.add(encryptedFile);
        importedThumbnails.add(encryptedThumbnailFile);
      }

      // Überprüfen, ob das Widget noch im Baum ist, bevor der Kontext verwendet wird
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${importedFiles.length} Foto(s) erfolgreich importiert und verschlüsselt!')),
        );

        // Aktualisiere die Galerie mit den neuen Fotos und Thumbnails
        onPhotosImported(importedFiles, importedThumbnails);
      }
    }
  }

  // Verschlüsselte Fotos aus dem lokalen Verzeichnis laden
  static Future<List<File>> loadEncryptedPhotos() async {
    final localPath = await _getLocalPath();
    final directory = Directory(localPath);
    final files = directory.listSync().whereType<File>().toList();
    return files.where((file) => file.path.endsWith('.enc')).toList();
  }

  // Entschlüsselt ein Foto für die Vorschau (Miniaturansicht)
  static Future<Image> loadThumbnail(File encryptedFile) async {
    final decryptedBytes = await Encryption.decryptFile(encryptedFile);
    return Image.memory(
      Uint8List.fromList(decryptedBytes),
      fit: BoxFit.cover,
    );
  }

  // Foto entschlüsseln und exportieren
  static Future<void> exportPhoto(BuildContext context, File encryptedFile) async {
    final decryptedData = await Encryption.decryptFile(encryptedFile);
    final localPath = await _getLocalPath();
    final exportPath = '$localPath/export_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Entschlüsseltes Foto speichern
    final exportFile = File(exportPath);
    await exportFile.writeAsBytes(decryptedData);

    // Überprüfen, ob das Widget noch im Baum ist, bevor der Kontext verwendet wird
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto erfolgreich exportiert!')),
      );
    }
  }
}
