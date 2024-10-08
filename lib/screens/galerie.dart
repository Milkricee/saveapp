import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saveapp/logik/file_manager.dart';
import 'photo_view_screen.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  GalerieScreenState createState() => GalerieScreenState();
}

class GalerieScreenState extends State<GalerieScreen> {
  List<File> _encryptedPhotos = [];
  List<File> _thumbnails = [];

  @override
  void initState() {
    super.initState();
    _loadEncryptedPhotos();
  }

  // Lädt die verschlüsselten Fotos aus dem lokalen Verzeichnis
  Future<void> _loadEncryptedPhotos() async {
    List<File> photos = await FileManager.loadEncryptedPhotos();
    if (!mounted) return; // Überprüfen, ob das Widget noch aktiv ist
    setState(() {
      _encryptedPhotos = photos;
      _thumbnails = _loadThumbnails(photos);
    });
  }

  // Lädt vorhandene Thumbnails
  List<File> _loadThumbnails(List<File> encryptedPhotos) {
    return encryptedPhotos.map((photo) {
      final thumbnailPath = photo.path.replaceAll('.enc', '_thumbnail.enc');
      return File(thumbnailPath);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => FileManager.importPhotos(context, (files, thumbnails) {
              if (!mounted) return;
              setState(() {
                _encryptedPhotos.addAll(files);
                _thumbnails.addAll(thumbnails);
              });
            }),
          ),
        ],
      ),
      body: _thumbnails.isEmpty
          ? const Center(child: Text('Keine Fotos verfügbar'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _thumbnails.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () => _showOptionsMenu(context, index),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(
                          imageFiles: _encryptedPhotos,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: FutureBuilder<Image>(
                    future: FileManager.loadThumbnail(_thumbnails[index]), // Thumbnail laden
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Icon(Icons.error));
                      }
                      return snapshot.data ?? const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
    );
  }

  // Optionsmenü für Löschen und Export anzeigen
  void _showOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Löschen'),
              onTap: () async {
                await FileManager.deletePhoto(_encryptedPhotos[index], _thumbnails[index]);

                // Überprüfen, ob das Widget noch gemounted ist, bevor der `context` verwendet wird
                if (!mounted) return;

                setState(() {
                  _encryptedPhotos.removeAt(index);
                  _thumbnails.removeAt(index);
                });

                if (context.mounted) {
                  Navigator.pop(context); // Schließt das Optionsmenü
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Exportieren'),
              onTap: () async {
                await FileManager.exportPhoto(context, _encryptedPhotos[index]);

                // Überprüfen, ob das Widget noch gemounted ist, bevor der `context` verwendet wird
                if (context.mounted) {
                  Navigator.pop(context); // Schließt das Optionsmenü
                }
              },
            ),
          ],
        );
      },
    );
  }
}
