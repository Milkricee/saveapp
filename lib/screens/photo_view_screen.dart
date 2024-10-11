import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:saveapp/logik/encryption.dart';
import 'package:saveapp/galerie_manager/fotos_loeschen_exportieren.dart'; // Importiere die Lösch-Logik

class PhotoViewScreen extends StatelessWidget {
  final List<File> imageFiles;
  final int initialIndex;

  const PhotoViewScreen({
    super.key,
    required this.imageFiles,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vollbildvorschau'),
      ),
      body: FutureBuilder<List<Uint8List>>(
        future: _loadDecryptedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Bilder: ${snapshot.error}'));
          }

          final decryptedImages = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: PhotoViewGallery.builder(
                  itemCount: decryptedImages.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: MemoryImage(decryptedImages[index]),
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 2.0,
                    );
                  },
                  pageController: PageController(initialPage: initialIndex),
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Bestätigungsdialog anzeigen
                      await FotoBearbeiten.fotosLoeschen([imageFiles[initialIndex]], context);
                      Navigator.pop(context, true); // Rückgabe von `true`, um anzugeben, dass gelöscht wurde
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () async {
                      await FotoBearbeiten.fotosExportieren([imageFiles[initialIndex]], context);
                      // Keine Rückgabe erforderlich, da nur Export
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Entschlüsselt alle Bilddateien und gibt sie als Liste von Uint8List zurück
  Future<List<Uint8List>> _loadDecryptedImages() async {
    List<Uint8List> decryptedImages = [];
    for (var file in imageFiles) {
      Uint8List bytes;

      if (file.path.endsWith('.enc')) {
        bytes = await Encryption.decryptFile(file);
      } else {
        bytes = await file.readAsBytes(); // Für unverschlüsselte Dateien
      }

      decryptedImages.add(bytes);
    }
    return decryptedImages;
  }
}
