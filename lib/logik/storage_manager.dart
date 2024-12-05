import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'encryption.dart';

class StorageManager {
  // Methode zum Abrufen des geheimen Ordners
  static Future<String> getSecretFolderPath() async {
    final externalDir = await getExternalStorageDirectory(); // Zugriff auf externen Speicher
    final secretFolder = '${externalDir!.path}/.geheimerOrdner';

    // Ordner erstellen, falls er nicht existiert
    final dir = Directory(secretFolder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return secretFolder;
  }
  // Methode zum Speichern eines verschlüsselten Fotos
  static Future<void> saveEncryptedPhoto(File photo) async {
    final secretPath = await getSecretFolderPath(); // Geheimer Ordner
    final encryptedPath = '$secretPath/${DateTime.now().millisecondsSinceEpoch}.enc';

    // Verschlüsselung durchführen
    final encryptedBytes = await Encryption.encryptFile(photo);
    final encryptedFile = File(encryptedPath);
    await encryptedFile.writeAsBytes(encryptedBytes);
  }

   // Methode zum Entschlüsseln eines Fotos
  static Future<File> decryptPhoto(String encryptedFilePath) async {
    final encryptedFile = File(encryptedFilePath);

    if (await encryptedFile.exists()) {
      // Entschlüsselung durchführen
      final decryptedBytes = await Encryption.decryptFile(encryptedFile);
      final tempPath = '${(await getTemporaryDirectory()).path}/decrypted_photo.jpg';

      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(decryptedBytes);
      return tempFile;
    } else {
      throw Exception('Datei nicht gefunden!');
    }
  }


  // Methode zum Abrufen aller Dateien im geheimen Ordner
  static Future<List<String>> getEncryptedFiles() async {
    final secretPath = await getSecretFolderPath();
    final dir = Directory(secretPath);

    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>();
      return files.map((file) => file.path).toList();
    } else {
      return [];
    }
  }
}
