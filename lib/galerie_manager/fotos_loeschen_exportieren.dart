import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FotoBearbeiten {
  // Funktion, um ein oder mehrere Fotos zu löschen
  static Future<void> fotosLoeschen(List<File> fotos, BuildContext context) async {
    bool? confirm = await _confirmDialog(
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

  // Funktion, um ein oder mehrere Fotos zu exportieren
  static Future<void> fotosExportieren(List<File> fotos, BuildContext context) async {
    bool? confirm = await _confirmDialog(
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
      } catch (e) {
        if (!context.mounted) return; // mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Exportieren der Fotos: $e')),
        );
      }
    }
  }

  // Hilfsfunktion, um einen Bestätigungsdialog anzuzeigen
  static Future<bool?> _confirmDialog(BuildContext context, String title, String content) {
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
