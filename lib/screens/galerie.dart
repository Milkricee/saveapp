import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saveapp/galerie_manager/load_save_process.dart';
import 'package:saveapp/galerie_manager/photo_view_navigation.dart';
import 'package:saveapp/galerie_manager/bilder_anzeig_logik.dart';
import '../logik/file_manager.dart';
import 'package:saveapp/galerie_manager/fotos_loeschen_exportieren.dart'; // Importieren für Lösch- und Exportlogik

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  GalerieScreenState createState() => GalerieScreenState();
}

class GalerieScreenState extends State<GalerieScreen> {
  List<File> _importedPhotos = [];
  final List<File> _selectedPhotos = []; // Liste der ausgewählten Fotos
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

  // Foto zum Auswahlliste hinzufügen oder entfernen
  void _onPhotoLongPressed(File file) {
    setState(() {
      _isSelectionMode = true; // Schalte Auswahlmodus an
      if (_selectedPhotos.contains(file)) {
        _selectedPhotos.remove(file); // Wenn bereits ausgewählt, entfernen
      } else {
        _selectedPhotos.add(file); // Sonst hinzufügen
      }
    });
  }

  // Auswahl zurücksetzen
  void _clearSelection() {
    setState(() {
      _selectedPhotos.clear();
      _isSelectionMode = false; // Auswahlmodus ausschalten
    });
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _importedPhotos.length,
                  itemBuilder: (context, index) {
                    final file = _importedPhotos[index];

                    return GestureDetector(
                      onLongPress: () => _onPhotoLongPressed(file), // Langes Drücken, um Fotos auszuwählen
                      onTap: () async {
                        if (_isSelectionMode) {
                          _onPhotoLongPressed(file); // Bei Auswahlmodus kurzes Drücken für Auswahl
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
                      child: Stack(
                        children: [
                          ImageHelper.buildImage(file, context),
                          if (_selectedPhotos.contains(file))
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
                      await FotoBearbeiten.fotosLoeschen(_selectedPhotos, context);
                      _clearSelection();
                      await _loadPhotos(); // Galerie aktualisieren
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_upload, color: Colors.blue, size: 30),
                    onPressed: () async {
                      await FotoBearbeiten.fotosExportieren(_selectedPhotos, context);
                      _clearSelection(); // Auswahl zurücksetzen
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
