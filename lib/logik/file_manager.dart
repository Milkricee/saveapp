import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class FileManager {
  static bool _isPickerActive = false;

  // Pfad zum lokalen Verzeichnis für importierte Fotos
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    // Debug
    return directory.path;
  }

  // Fotos importieren (unterstützt Mehrfachauswahl)
  static Future<void> importPhotos(BuildContext context, Function(List<File>) onPhotosImported) async {
    if (_isPickerActive) return; // Wenn bereits aktiv, nichts tun
    _isPickerActive = true;

    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); // Mehrfachauswahl

      if (pickedFiles.isNotEmpty) {
        final localPath = await getLocalPath();
        List<File> importedFiles = [];

        for (var pickedFile in pickedFiles) {
          final photoFile = File(pickedFile.path);
          final newFilePath = '$localPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Foto kopieren und speichern
          final newFile = await photoFile.copy(newFilePath);
          importedFiles.add(newFile);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${importedFiles.length} Foto(s) erfolgreich importiert!')),
          );
          onPhotosImported(importedFiles);
        }
      }
    } finally {
      _isPickerActive = false;
    }
  }
}
