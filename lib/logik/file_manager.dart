import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'encryption.dart';

class FileManager {
  // Statusvariable, um den mehrfachen Aufruf zu verhindern
  static bool _isPickerActive = false;

  // Pfad zum lokalen Verzeichnis für verschlüsselte Fotos
  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Fotos importieren und verschlüsseln (unterstützt Mehrfachauswahl)
  static Future<void> importPhotos(BuildContext context, Function(List<File>, List<File>) onPhotosImported) async {
    if (_isPickerActive) return; // Wenn bereits aktiv, nichts tun
    _isPickerActive = true; // Setze den Status auf aktiv

    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); // Mehrfachauswahl

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final localPath = await _getLocalPath();
        List<File> importedFiles = [];

        for (var pickedFile in pickedFiles) {
          final photoFile = File(pickedFile.path);
          final encryptedFilePath = '$localPath/${DateTime.now().millisecondsSinceEpoch}.enc';

          // Foto verschlüsseln und speichern
          final encryptedData = await Encryption.encryptFile(photoFile);
          final encryptedFile = File(encryptedFilePath);
          await encryptedFile.writeAsBytes(encryptedData);

          // Originaldatei nach Verschlüsselung löschen
          await photoFile.delete();
          importedFiles.add(encryptedFile);
        }

        // Überprüfen, ob das Widget noch im Baum ist, bevor der Kontext verwendet wird
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${importedFiles.length} Foto(s) erfolgreich importiert und verschlüsselt!')),
          );

          // Aktualisiere die Galerie mit den neuen Fotos
          onPhotosImported(importedFiles, []);
        }
      }
    } finally {
      _isPickerActive = false; // Status zurücksetzen, nachdem der Picker fertig ist
    }
  }
}
