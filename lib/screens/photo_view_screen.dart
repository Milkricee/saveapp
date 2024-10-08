import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:saveapp/logik/encryption.dart';

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
    );
  }

  // Entschlüsselt alle Bilddateien und gibt sie als Liste von Uint8List zurück
  Future<List<Uint8List>> _loadDecryptedImages() async {
    List<Uint8List> decryptedImages = [];
    for (var file in imageFiles) {
      final decryptedBytes = await Encryption.decryptFile(file);
      decryptedImages.add(decryptedBytes);
    }
    return decryptedImages;
  }
}
