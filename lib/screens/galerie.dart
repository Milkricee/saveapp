import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saveapp/logik/file_manager.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  GalerieScreenState createState() => GalerieScreenState();
}

class GalerieScreenState extends State<GalerieScreen> {
  List<File> _importedPhotos = []; // Liste für importierte Fotos
  bool _isPickerActive = false; // Lokale Variable zur Verhinderung von Mehrfachaufrufen

  @override
  void initState() {
    super.initState();
    _loadPhotos(); // Lade gespeicherte Fotos beim Start
  }

  // Lädt gespeicherte Fotos aus dem lokalen Verzeichnis
  Future<void> _loadPhotos() async {
    final localPath = await FileManager.getLocalPath();
    final directory = Directory(localPath);

    // Liste der Dateien im lokalen Verzeichnis laden und nur `.jpg` und `.png` akzeptieren
    final files = directory.listSync().whereType<File>().toList();
    setState(() {
      _importedPhotos = files.where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png')).toList();
    });
    if (kDebugMode) {
      print('Geladene Fotos: $_importedPhotos');
    } // Debug-Ausgabe
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (_isPickerActive) return; // Prüfen, ob Picker bereits aktiv ist
              setState(() {
                _isPickerActive = true;
              });

              try {
                await FileManager.importPhotos(context, (files) {
                  setState(() {
                    _importedPhotos.addAll(files);
                  });
                  if (kDebugMode) {
                    print('Fotos erfolgreich importiert und zur Galerie hinzugefügt: ${_importedPhotos.length}');
                  }
                });
              } finally {
                setState(() {
                  _isPickerActive = false; // Status zurücksetzen
                });
              }
            },
          ),
        ],
      ),
      body: _importedPhotos.isEmpty
          ? const Center(child: Text('Keine Fotos verfügbar'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _importedPhotos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Vollbildansicht
                  },
                  child: Image.file(
                    _importedPhotos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      if (kDebugMode) {
                        print('Fehler beim Laden des Bildes: $error');
                      }
                      return const Center(child: Text('Fehler beim Laden des Bildes'));
                    },
                  ),
                );
              },
            ),
    );
  }
}
