import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

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

    try {
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(fileBytes), iv: _iv);
      if (kDebugMode) {
        print('Entschlüsselte Datenlänge: ${decrypted.length}');
      }
      return Uint8List.fromList(decrypted);
    } catch (e) {
      if (kDebugMode) {
        print('Fehler bei der Entschlüsselung: $e');
      }
      return Uint8List(0); // Rückgabe eines leeren Arrays bei Fehler
    }
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

   // Verschlüsselt eine beliebige Byte-Liste und gibt die verschlüsselten Bytes zurück
  static Future<Uint8List> encryptBytes(Uint8List data) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }
}
