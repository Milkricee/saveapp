import 'dart:typed_data';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';

class Encryption {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32-Byte-Schlüssel für AES256
  static final _iv = IV.fromLength(16); // Initialisierungsvektor (16 Byte)

  // Verschlüsselt die Datei und gibt die verschlüsselten Bytes zurück
  static Future<Uint8List> encryptFile(File file) async {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc)); // AES mit CBC-Modus
    final fileBytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(fileBytes, iv: _iv);
    return encrypted.bytes;
  }

  // Entschlüsselt die Datei und gibt die entschlüsselten Bytes zurück
  static Future<Uint8List> decryptFile(File file) async {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final fileBytes = await file.readAsBytes();
    final decrypted = encrypter.decryptBytes(Encrypted(fileBytes), iv: _iv);
    return Uint8List.fromList(decrypted);
  }
}
