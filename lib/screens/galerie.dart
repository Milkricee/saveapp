import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saveapp/galerie_manager/load_save_process.dart'; // GalerieManager importieren
import 'package:saveapp/galerie_manager/photo_view_navigation.dart'; // PhotoViewNavigation importieren
import 'package:saveapp/galerie_manager/bilder_anzeig_logik.dart';
import '../logik/file_manager.dart'; // ImageHelper importieren

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  GalerieScreenState createState() => GalerieScreenState();
}

class GalerieScreenState extends State<GalerieScreen> {
  List<File> _importedPhotos = []; // Liste für importierte Fotos
  bool _isPickerActive = false; // Lokale Variable zur Verhinderung von Mehrfachaufrufen
  final GalerieManager _galerieManager = GalerieManager(); // GalerieManager Instanz

  @override
  void initState() {
    super.initState();
    _loadPhotos(); // Lade gespeicherte Fotos beim Start
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPhotos(); // Fotos jedes Mal laden, wenn die Seite neu angezeigt wird.
  }

  // Lädt gespeicherte Fotos aus dem lokalen Verzeichnis
  Future<void> _loadPhotos() async {
    final files = await _galerieManager.loadPhotos();
    setState(() {
      _importedPhotos = files;
    });

    if (kDebugMode) {
      print('Geladene Fotos: $_importedPhotos');
    }
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
                // Hier wird FileManager.importPhotos verwendet
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
                final file = _importedPhotos[index];

                // Tippen auf das Bild, um zur Vollbildansicht zu wechseln
                return GestureDetector(
                  onTap: () async {
                    // Auf das Ergebnis des Vollbildmodus warten
                    final result = await PhotoViewNavigation.navigateToPhotoView(
                      context,
                      _importedPhotos,
                      index,
                    );

                    // Wenn das Bild gelöscht wurde, die Galerie neu laden
                    if (result == true) {
                      await _loadPhotos();
                    }
                  },
                  child: ImageHelper.buildImage(file, context), // Bild über ImageHelper laden
                );
              },
            ),
    );
  }
}
