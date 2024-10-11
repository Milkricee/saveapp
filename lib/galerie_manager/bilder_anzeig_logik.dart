import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saveapp/logik/encryption.dart';

class ImageHelper {
  static Widget buildImage(File file, BuildContext context) {
    if (file.path.endsWith('.enc')) {
      return FutureBuilder<Uint8List>(
        future: Encryption.decryptFile(file),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Fehler beim Laden des Bildes'));
          }

          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Fehler beim Laden des Bildes'));
            },
          );
        },
      );
    } else {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Fehler beim Laden des Bildes'));
        },
      );
    }
  }
}
