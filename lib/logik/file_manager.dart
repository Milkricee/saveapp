import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'encryption.dart';

class FileManager {
  // Pfad zum lokalen Verzeichnis für verschlüsselte Fotos
  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Fotos importieren und verschlüsseln
  static Future<void> importPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final localPath = await _getLocalPath();
      final photoFile = File(pickedFile.path);
      final encryptedFilePath = '$localPath/${DateTime.now().millisecondsSinceEpoch}.enc';

      // Foto verschlüsseln und speichern
      final encryptedData = await Encryption.encryptFile(photoFile);
      final encryptedFile = File(encryptedFilePath);
      await encryptedFile.writeAsBytes(encryptedData);

      // Originaldatei nach Verschlüsselung löschen
      await photoFile.delete();

      // Überprüfen, ob das Widget noch im Baum ist, bevor der Kontext verwendet wird
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto erfolgreich importiert und verschlüsselt!')),
        );
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
