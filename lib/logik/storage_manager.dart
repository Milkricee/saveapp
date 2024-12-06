import 'dart:io';
import 'package:saveapp/logik/encryption.dart';
import 'directory_selector.dart'; // Stelle sicher, dass dieser Importpfad korrekt ist

class StorageManager {
  // Ermittelt den von Nutzer gewählten geheimen Ordnerpfad.
  static Future<String?> getUserChosenFolderPath() async {
    final chosenPath = await DirectorySelector.loadSavedDirectoryPath();
    return chosenPath;
  }

  // Stellt sicher, dass im gewählten Ordner eine .nomedia-Datei existiert.
  // Dies verhindert, dass die Bilder in Galerie-Apps auftauchen.
  static Future<void> ensureNoMediaFile(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final nomediaFile = File('$folderPath/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
    }
  }

  // Speichert ein verschlüsseltes Foto im gewählten Ordner.
  static Future<void> saveEncryptedPhoto(File photo) async {
    final secretPath = await getUserChosenFolderPath();
    if (secretPath == null || secretPath.isEmpty) {
      // Kein Ordner ausgewählt
      throw Exception('Kein Zielordner ausgewählt. Bitte wähle einen Ordner aus.');
    }

    await ensureNoMediaFile(secretPath);

    final encryptedPath = '$secretPath/${DateTime.now().millisecondsSinceEpoch}.enc';
    final encryptedBytes = await Encryption.encryptFile(photo);

    final encryptedFile = File(encryptedPath);
    await encryptedFile.writeAsBytes(encryptedBytes);
  }

  // Entschlüsselt ein Foto aus dem gewählten Ordner.
  static Future<File> decryptPhoto(String encryptedFilePath) async {
    final encryptedFile = File(encryptedFilePath);

    if (await encryptedFile.exists()) {
      final decryptedBytes = await Encryption.decryptFile(encryptedFile);

      final secretPath = await getUserChosenFolderPath();
      if (secretPath == null || secretPath.isEmpty) {
        throw Exception('Kein Zielordner ausgewählt. Bitte wähle einen Ordner aus.');
      }

      await ensureNoMediaFile(secretPath);
      final tempPath = '$secretPath/decrypted_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(decryptedBytes);
      return tempFile;
    } else {
      throw Exception('Datei nicht gefunden!');
    }
  }

  // Listet alle verschlüsselten Dateien im gewählten Ordner auf.
  static Future<List<String>> getEncryptedFiles() async {
    final secretPath = await getUserChosenFolderPath();
    if (secretPath == null || secretPath.isEmpty) {
      // Kein Ordner ausgewählt
      return [];
    }

    final dir = Directory(secretPath);
    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>().toList();
      return files
          .where((file) => file.path.endsWith('.enc'))
          .map((file) => file.path)
          .toList();
    } else {
      return [];
    }
  }
}
