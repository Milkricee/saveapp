import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:saveapp/logik/encryption.dart';
import 'package:saveapp/galerie_manager/fotos_loeschen_exportieren.dart';

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
      body: Stack(
        children: [
          FutureBuilder<List<Uint8List>>(
            future: _loadDecryptedImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Fehler beim Laden der Bilder: ${snapshot.error}'));
              }

              final decryptedImages = snapshot.data!;
              return PhotoViewGallery.builder(
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
              );
            },
          ),
          // Icons für Löschen und Exportieren
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () async {
                    // Löschen mit Bestätigung
                    await FotoBearbeiten.fotosLoeschenMitBestaetigung(
                      [imageFiles[initialIndex]],
                      context,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context, true); // Galerie neu laden nach Löschen
                  },
                ),
          IconButton(
  icon: const Icon(Icons.file_upload, color: Colors.blue, size: 30),
  onPressed: () async {
    // Konsistenter Exportprozess mit Pfadauswahl
    final success = await FotoBearbeiten.fotosExportierenMitPfadauswahl(
      [imageFiles[initialIndex]],
      context,
    );

    if (!context.mounted) return; // Überprüfen, ob das Widget noch aktiv ist

    // Optionales Löschen nach dem Export
    if (success) {
      await FotoBearbeiten.fotosLoeschenMitBestaetigung(
        [imageFiles[initialIndex]],
        context,
      );

      if (!context.mounted) return; // Noch einmal prüfen vor dem Navigator.pop
      Navigator.pop(context, true); // Galerie neu laden nach Export und Löschen
    }
  },
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Uint8List>> _loadDecryptedImages() async {
    List<Uint8List> decryptedImages = [];
    for (var file in imageFiles) {
      Uint8List bytes = file.path.endsWith('.enc')
          ? await Encryption.decryptFile(file)
          : await file.readAsBytes();
      decryptedImages.add(bytes);
    }
    return decryptedImages;
  }
}
