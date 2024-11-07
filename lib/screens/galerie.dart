import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saveapp/galerie_manager/load_save_process.dart';
import 'package:saveapp/galerie_manager/photo_view_navigation.dart';
import 'package:saveapp/galerie_manager/bilder_anzeig_logik.dart';
import '../logik/file_manager.dart';
import 'package:saveapp/galerie_manager/fotos_loeschen_exportieren.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  GalerieScreenState createState() => GalerieScreenState();
}

class GalerieScreenState extends State<GalerieScreen> {
  List<File> _importedPhotos = [];
  final ValueNotifier<List<File>> _selectedPhotos = ValueNotifier<List<File>>([]); // Benutze ValueNotifier
  bool _isPickerActive = false;
  bool _isSelectionMode = false; // Status für Auswahlmodus
  final GalerieManager _galerieManager = GalerieManager();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final files = await _galerieManager.loadPhotos();
    setState(() {
      _importedPhotos = files;
    });

    if (kDebugMode) {
      print('Geladene Fotos: $_importedPhotos');
    }
  }

  // Foto zur Auswahlliste hinzufügen oder entfernen
  void _togglePhotoSelection(File file) {
    if (_selectedPhotos.value.contains(file)) {
      _selectedPhotos.value = List.from(_selectedPhotos.value)..remove(file);
    } else {
      _selectedPhotos.value = List.from(_selectedPhotos.value)..add(file);
    }
    _isSelectionMode = _selectedPhotos.value.isNotEmpty;
  }

  // Auswahl zurücksetzen
  void _clearSelection() {
    _selectedPhotos.value = [];
    _isSelectionMode = false;
  }

  // Galerie aktualisieren, nachdem Fotos gelöscht oder exportiert wurden
  Future<void> _updateGallery() async {
    await _loadPhotos(); // Lade die Galerie neu
    _clearSelection(); // Setze die Auswahl zurück
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
              if (_isPickerActive) return;
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
                  _isPickerActive = false;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _importedPhotos.isEmpty
              ? const Center(child: Text('Keine Fotos verfügbar'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0), // Einheitliches Padding
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _importedPhotos.length,
                  itemBuilder: (context, index) {
                    final file = _importedPhotos[index];

                    return ValueListenableBuilder<List<File>>(
                      valueListenable: _selectedPhotos,
                      builder: (context, selectedPhotos, child) {
                        return GestureDetector(
                          onLongPress: () => _togglePhotoSelection(file), // Auswahl ein-/ausschalten
                          onTap: () async {
                            if (_isSelectionMode) {
                              _togglePhotoSelection(file); // Auswahlmodus aktivieren
                            } else {
                              final result = await PhotoViewNavigation.navigateToPhotoView(
                                context,
                                _importedPhotos,
                                index,
                              );
                              if (result == true) {
                                await _loadPhotos();
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: selectedPhotos.contains(file)
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null, // Rahmen für ausgewählte Fotos
                            ),
                            child: Stack(
                              children: [
                                ImageHelper.buildImage(file, context),
                                if (selectedPhotos.contains(file))
                                  const Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          if (_isSelectionMode)
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: () async {
                      await FotoBearbeiten.fotosLoeschenMitBestaetigung(_selectedPhotos.value, context);
                      await _updateGallery(); // Galerie nach dem Löschen aktualisieren
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_upload, color: Colors.blue, size: 30),
                    onPressed: () async {
                      await FotoBearbeiten.fotosExportierenMitBestaetigung(_selectedPhotos.value, context);
                      await _updateGallery(); // Galerie nach dem Export aktualisieren
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
