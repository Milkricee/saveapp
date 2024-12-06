import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FotoBearbeiten {
  // Methode zum Löschen mit Bestätigungsdialog
  static Future<void> fotosLoeschenMitBestaetigung(List<File> fotos, BuildContext context) async {
    if (!context.mounted) return;

    bool? confirm = await confirmDialog(
      context,
      'Löschen bestätigen',
      'Möchten Sie wirklich die ausgewählten Fotos löschen?',
    );

    if (confirm == true) {
      for (var foto in fotos) {
        try {
          if (await foto.exists()) {
            await foto.delete();
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Löschen des Fotos: ${foto.path}')),
          );
        }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotos erfolgreich gelöscht')),
      );
    }
  }

  // Funktion zum Exportieren von Fotos mit Benutzerpfadauswahl
  static Future<void> fotosExportieren(List<File> fotos, BuildContext context) async {
    if (!context.mounted) return;

    try {
      // Benutzer wählt den Zielordner für den Export aus
      String? exportPath = await FilePicker.platform.getDirectoryPath();
      if (exportPath == null || exportPath.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export abgebrochen')),
        );
        return;
      }

      for (var foto in fotos) {
        final zielPfad = '$exportPath/${foto.uri.pathSegments.last}';
        await foto.copy(zielPfad); // Kopiert das Foto in den Zielordner
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotos erfolgreich exportiert')),
      );

      // Optional: Nach dem Export fragen, ob die Fotos gelöscht werden sollen
      bool? deleteAfterExport = await confirmDialog(
        context,
        'Löschen nach Export',
        'Möchten Sie die Fotos nach dem Export aus der App löschen?',
      );

      if (deleteAfterExport == true && context.mounted) {
        await fotosLoeschenMitBestaetigung(fotos, context);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Exportieren der Fotos: $e')),
      );
    }
  }

  // Funktion zum Exportieren von Fotos mit Benutzerpfadauswahl
  static Future<bool> fotosExportierenMitPfadauswahl(List<File> fotos, BuildContext context) async {
    if (!context.mounted) return false;

    try {
      // Fordert den Benutzer auf, einen Zielordner auszuwählen
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null || directoryPath.isEmpty) {
        // Der Benutzer hat die Auswahl abgebrochen
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kein Zielordner ausgewählt. Export abgebrochen.')),
        );
        return false;
      }

      for (var foto in fotos) {
        final zielPfad = '$directoryPath/${foto.uri.pathSegments.last}';
        await foto.copy(zielPfad); // Kopiert das Foto in das Zielverzeichnis
      }

      // Erfolgreicher Export
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotos erfolgreich exportiert!')),
      );

      return true;
    } catch (e) {
      if (!context.mounted) return false;
      // Fehler beim Exportieren
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Exportieren der Fotos: $e')),
      );
      return false;
    }
  }

  // Funktion zum Exportieren von Fotos ohne Bestätigungsdialog
  static Future<void> fotosExportierenOhneBestaetigung(List<File> fotos, BuildContext context) async {
    if (!context.mounted) return;

    try {
      // Zielordner festlegen: Standardmäßig den Downloads-Ordner verwenden
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        // Kein Zielordner verfügbar
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kein Speicherort für den Export gefunden')),
        );
        return;
      }

      final exportPath = '${directory.path}/ExportedPhotos';
      final exportDirectory = Directory(exportPath);

      // Erstelle das Zielverzeichnis, falls es nicht existiert
      if (!await exportDirectory.exists()) {
        await exportDirectory.create(recursive: true);
      }

      // Fotos exportieren
      for (var foto in fotos) {
        final zielPfad = '$exportPath/${foto.uri.pathSegments.last}';
        await foto.copy(zielPfad);
      }

      // Erfolgsmeldung anzeigen
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${fotos.length} Foto(s) erfolgreich exportiert!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      // Fehlerbehandlung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Exportieren der Fotos: $e')),
      );
    }
  }

  // Hilfsfunktion für den Bestätigungsdialog
  static Future<bool?> confirmDialog(BuildContext context, String title, String content) async {
    if (!context.mounted) return null;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Bestätigen'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
