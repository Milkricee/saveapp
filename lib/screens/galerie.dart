import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saveapp/galerie_manager/photo_view_navigation.dart';
import '../logik/directory_selector.dart';
import '../logik/file_manager.dart';
import '../galerie_manager/bilder_anzeig_logik.dart';
import 'package:saveapp/galerie_manager/fotos_loeschen_exportieren.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  State<GalerieScreen> createState() => _GalerieScreenState();
}

class _GalerieScreenState extends State<GalerieScreen> {
  List<File> _importedPhotos = [];
  final List<File> _selectedPhotos = [];
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    _initializeGallery();
  }

  /// Initialisiert die Galerie, indem der geheime Ordner erstellt und Fotos geladen werden.
  Future<void> _initializeGallery() async {
    try {
      // Automatisch den geheimen Ordner erstellen
      final secretFolderPath = await DirectorySelector.createSecretFolder();
      debugPrint('Geheimer Ordner erstellt: $secretFolderPath');

      // Lade Fotos aus dem geheimen Ordner
      await _loadPhotos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler bei der Galerieinitialisierung: $e')),
      );
    }
  }

  Future<void> _loadPhotos() async {
    try {
      final files = await FileManager.loadPhotos();
      setState(() {
        _importedPhotos = files;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Fotos: $e')),
        );
      }
    }
  }

  void _togglePhotoSelection(File file) {
    setState(() {
      if (_selectedPhotos.contains(file)) {
        _selectedPhotos.remove(file);
      } else {
        _selectedPhotos.add(file);
      }
    });
  }

  Future<void> _importPhotos() async {
    if (_isPickerActive) return;

    setState(() {
      _isPickerActive = true;
    });

    try {
      await FileManager.importPhotos(context, (newPhotos) {
        setState(() {
          _importedPhotos.addAll(newPhotos);
        });
      });
    } finally {
      setState(() {
        _isPickerActive = false;
      });
    }
  }

  Future<void> _deleteSelectedPhotos() async {
    await FotoBearbeiten.fotosLoeschenMitBestaetigung(_selectedPhotos, context);
    await _loadPhotos();
    setState(() {
      _selectedPhotos.clear();
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
            onPressed: _importPhotos,
          ),
        ],
      ),
      body: _importedPhotos.isEmpty
          ? const Center(child: Text('Keine Fotos verfügbar'))
          : Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _importedPhotos.length,
                  itemBuilder: (context, index) {
                    final file = _importedPhotos[index];
                    final isSelected = _selectedPhotos.contains(file);

                    return GestureDetector(
                      onLongPress: () => _togglePhotoSelection(file),
                      onTap: () async {
                        if (_selectedPhotos.isNotEmpty) {
                          _togglePhotoSelection(file);
                        } else {
                          final result =
                              await PhotoViewNavigation.navigateToPhotoView(
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
                          border: isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: ImageHelper.buildImage(file, context),
                            ),
                            if (isSelected)
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
                ),
                if (_selectedPhotos.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 30),
                          onPressed: _deleteSelectedPhotos,
                        ),
                        // Export-Button entfernt oder deaktiviert
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
