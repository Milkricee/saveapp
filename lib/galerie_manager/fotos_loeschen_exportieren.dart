import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FotoBearbeiten {
  // Methode zum Löschen mit Bestätigungsdialog
  static Future<void> fotosLoeschenMitBestaetigung(List<File> fotos, BuildContext context) async {
    // Fragt nach einer Bestätigung, bevor die Fotos gelöscht werden
    bool? confirm = await confirmDialog(
      context,
      'Löschen bestätigen',
      'Möchten Sie wirklich die ausgewählten Fotos löschen?',
    );

    if (confirm == true) {
      for (var foto in fotos) {
        try {
          if (await foto.exists()) {
            await foto.delete(); // Löscht das Foto
          }
        } catch (e) {
          if (!context.mounted) return; // mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Löschen des Fotos: ${foto.path}')),
          );
        }
      }

      if (!context.mounted) return; // mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotos erfolgreich gelöscht')),
      );
    }
  }

  // Methode zum Löschen ohne Bestätigungsdialog
  static Future<void> fotosLoeschenOhneBestaetigung(List<File> fotos, BuildContext context) async {
    // Löscht die Fotos direkt ohne Bestätigung
    for (var foto in fotos) {
      try {
        if (await foto.exists()) {
          await foto.delete(); // Löscht das Foto
        }
      } catch (e) {
        if (!context.mounted) return; // mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen des Fotos: ${foto.path}')),
        );
      }
    }

    if (!context.mounted) return; // mounted check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fotos erfolgreich gelöscht')),
    );
  }

  // Funktion, um ein oder mehrere Fotos zu exportieren ohne Bestätigungsdialog
  static Future<void> fotosExportierenMitBestaetigung(List<File> fotos, BuildContext context) async {
    bool? confirm = await confirmDialog(
      context,
      'Export bestätigen',
      'Möchten Sie wirklich die ausgewählten Fotos exportieren?',
    );

    if (confirm == true) {
      try {
        final exportDirectory = await getExternalStorageDirectory(); // Verzeichnis auf dem Gerät
        if (exportDirectory == null) {
          if (!context.mounted) return; // mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kein Speicherort für den Export gefunden')),
          );
          return;
        }

        for (var foto in fotos) {
          final zielPfad = '${exportDirectory.path}/${foto.uri.pathSegments.last}';
          await foto.copy(zielPfad); // Kopiert das Foto in das Exportverzeichnis
        }

        if (!context.mounted) return; // mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotos erfolgreich exportiert')),
        );

        // Frage, ob die Fotos nach dem Export gelöscht werden sollen
        bool? deleteAfterExport = await confirmDialog(
          context,
          'Löschen nach Export',
          'Möchten Sie die Fotos nach dem Export aus der App löschen?',
        );

        if (deleteAfterExport == true) {
          if (!context.mounted) return; // mounted check
          // Fotos ohne erneute Bestätigung löschen
          await fotosLoeschenOhneBestaetigung(fotos, context);
        }
      } catch (e) {
        if (!context.mounted) return; // mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Exportieren der Fotos: $e')),
        );
      }
    }
  }

    // Methode zum Exportieren von Fotos ohne Bestätigungsdialog
  static Future<void> fotosExportierenOhneBestaetigung(List<File> fotos, BuildContext context) async {
    try {
      final exportDirectory = await getExternalStorageDirectory(); // Verzeichnis auf dem Gerät
      if (exportDirectory == null) {
        if (!context.mounted) return; // mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kein Speicherort für den Export gefunden')),
        );
        return;
      }

      for (var foto in fotos) {
        final zielPfad = '${exportDirectory.path}/${foto.uri.pathSegments.last}';
        await foto.copy(zielPfad); // Kopiert das Foto in das Exportverzeichnis
      }

      if (!context.mounted) return; // mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotos erfolgreich exportiert')),
      );
    } catch (e) {
      if (!context.mounted) return; // mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Exportieren der Fotos: $e')),
      );
    }
  }


  // Hilfsfunktion für den Bestätigungsdialog
  static Future<bool?> confirmDialog(BuildContext context, String title, String content) async {
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
                Navigator.of(dialogContext).pop(false); // Aktion abbrechen
              },
            ),
            TextButton(
              child: const Text('Bestätigen'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Aktion bestätigen
              },
            ),
          ],
        );
      },
    );
  }
}
