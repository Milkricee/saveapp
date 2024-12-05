import 'dart:io';
import 'package:saveapp/logik/encryption.dart';

class StorageManager {
  // Wir verwenden einen öffentlichen Pfad im externen Speicher.
  // Beispiel: DCIM-Verzeichnis.
  // Bitte beachten: Für Android 11+ ist MANAGE_EXTERNAL_STORAGE nötig, um hier direkt schreiben zu können.
  static Future<String> getSecretFolderPath() async {
    // Allgemeiner Pfad. Auf den meisten Android-Geräten ist dies gültig.
    final externalDir = Directory('/storage/emulated/0/DCIM/.geheimerOrdner');

    if (!await externalDir.exists()) {
      await externalDir.create(recursive: true);
    }

    // Erstelle eine .nomedia-Datei, damit Bilder nicht in der Galerie erscheinen
    final nomediaFile = File('${externalDir.path}/.nomedia');
    if (!await nomediaFile.exists()) {
      await nomediaFile.create();
    }

    return externalDir.path;
  }

  static Future<void> saveEncryptedPhoto(File photo) async {
    final secretPath = await getSecretFolderPath();
    final encryptedPath = '$secretPath/${DateTime.now().millisecondsSinceEpoch}.enc';

    final encryptedBytes = await Encryption.encryptFile(photo);
    final encryptedFile = File(encryptedPath);
    await encryptedFile.writeAsBytes(encryptedBytes);
  }

  static Future<File> decryptPhoto(String encryptedFilePath) async {
    final encryptedFile = File(encryptedFilePath);

    if (await encryptedFile.exists()) {
      final decryptedBytes = await Encryption.decryptFile(encryptedFile);

      // Entschlüsseltes Bild als temporäre Datei schreiben
      final secretPath = await getSecretFolderPath();
      final tempPath = '$secretPath/decrypted_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(decryptedBytes);
      return tempFile;
    } else {
      throw Exception('Datei nicht gefunden!');
    }
  }

  static Future<List<String>> getEncryptedFiles() async {
    final secretPath = await getSecretFolderPath();
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
