import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  // Statusvariable, um den mehrfachen Aufruf zu verhindern
  static bool _isPickerActive = false;

 // Überprüft und fordert die Berechtigungen an
  static Future<bool> checkAndRequestPermissions() async {
    final status = await Permission.storage.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    return status.isGranted;
  }
  
  // Pfad zum lokalen Verzeichnis für importierte Fotos
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
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

          // Überprüfe Dateiformat auf `.jpg` oder `.png`
          if (!photoFile.path.endsWith('.jpg') && !photoFile.path.endsWith('.png')) {
            continue; // Überspringe Dateien, die nicht im richtigen Format sind
          }

          final newFilePath = '$localPath/${DateTime.now().millisecondsSinceEpoch}${photoFile.path.endsWith('.jpg') ? '.jpg' : '.png'}';

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
