import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class Encryption {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32-Byte-Schlüssel für AES256
  static final _iv = encrypt.IV.fromLength(16); // Initialisierungsvektor (16 Byte)

  // Verschlüsselt die Datei und gibt die verschlüsselten Bytes zurück
  static Future<Uint8List> encryptFile(File file) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final fileBytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(fileBytes, iv: _iv);
    return encrypted.bytes;
  }

  // Entschlüsselt die Datei und gibt die entschlüsselten Bytes zurück
  static Future<Uint8List> decryptFile(File file) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final fileBytes = await file.readAsBytes();
    final decrypted = encrypter.decryptBytes(encrypt.Encrypted(fileBytes), iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  // Generiere ein Thumbnail aus einem Bild
  static Future<File> generateThumbnail(File photoFile, String localPath) async {
    final originalBytes = await photoFile.readAsBytes();
    final originalImage = img.decodeImage(originalBytes);

    // Thumbnail erstellen und auf maximale Größe beschränken
    final thumbnail = img.copyResize(originalImage!, width: 200, height: 200);

    // Thumbnail als separate Datei speichern
    final thumbnailPath = '$localPath/thumbnail_${DateTime.now().millisecondsSinceEpoch}.png';
    final thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(Uint8List.fromList(img.encodePng(thumbnail)));

    return thumbnailFile;
  }

  // Verschlüsselt das generierte Thumbnail
  static Future<File> encryptThumbnail(File thumbnailFile, String localPath) async {
    final encryptedThumbnailPath = '$localPath/thumbnail_${DateTime.now().millisecondsSinceEpoch}.enc';
    final encryptedThumbnailData = await encryptFile(thumbnailFile);
    final encryptedThumbnailFile = File(encryptedThumbnailPath);
    await encryptedThumbnailFile.writeAsBytes(encryptedThumbnailData);

    return encryptedThumbnailFile;
  }
}
