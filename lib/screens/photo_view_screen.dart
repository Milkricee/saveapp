import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:saveapp/logik/encryption.dart';
import 'package:saveapp/galerie_manager/fotos_loeschen_exportieren.dart';

class PhotoViewScreen extends StatefulWidget {
  final List<File> imageFiles;
  final int initialIndex;

  const PhotoViewScreen({
    super.key,
    required this.imageFiles,
    required this.initialIndex,
  });

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late Future<List<Uint8List>> _decryptedImagesFuture;

  @override
  void initState() {
    super.initState();
    _decryptedImagesFuture = _loadDecryptedImages();
  }

  Future<List<Uint8List>> _loadDecryptedImages() async {
    List<Uint8List> decryptedImages = [];
    for (var file in widget.imageFiles) {
      Uint8List bytes = file.path.endsWith('.enc')
          ? await Encryption.decryptFile(file)
          : await file.readAsBytes();
      decryptedImages.add(bytes);
    }
    return decryptedImages;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Vollbildvorschau'),
    ),
    body: FutureBuilder<List<Uint8List>>(
      future: _decryptedImagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Fehler beim Laden der Bilder: ${snapshot.error}'));
        }

        final decryptedImages = snapshot.data!;
        return Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: decryptedImages.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(decryptedImages[index]),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                );
              },
              pageController: PageController(initialPage: widget.initialIndex),
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
              ),
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
                      final imageFile = widget.imageFiles[widget.initialIndex];

                      // Löschen im isolierten Kontext, um BuildContext sicher zu verwenden
                      await FotoBearbeiten.fotosLoeschenMitBestaetigung([imageFile], context);

                      if (mounted) {
                        if (context.mounted) Navigator.pop(context, true);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_upload, color: Colors.blue, size: 30),
                    onPressed: () {
                      _exportPhotoSafe(widget.imageFiles[widget.initialIndex]);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// Sicheres Exportieren des Fotos
Future<void> _exportPhotoSafe(File file) async {
  if (!mounted) return; // Check, ob State noch gültig ist

  // Exportprozess ohne direkten BuildContext-Nutzung über await
  final exportSuccess = await FotoBearbeiten.fotosExportierenMitPfadauswahl([file], context);

  if (exportSuccess && mounted) {
    final shouldDelete = await FotoBearbeiten.confirmDialog(
      context,
      'Löschen nach Export',
      'Möchten Sie das Foto nach dem Export löschen?',
    );

    if (shouldDelete == true && mounted) {
      await FotoBearbeiten.fotosLoeschenMitBestaetigung([file], context);
      if (mounted && context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
}
