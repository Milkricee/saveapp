import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saveapp/logik/file_manager.dart';

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

  // Lädt die verschlüsselten Fotos und zugehörigen Thumbnails
  Future<void> _loadEncryptedPhotos() async {
    List<File> photos = await FileManager.loadEncryptedPhotos();
    setState(() {
      _encryptedPhotos = photos;
      // Thumbnails laden oder erstellen
      _thumbnails = _loadThumbnails(photos);
    });
  }

  // Lädt vorhandene Thumbnails
  List<File> _loadThumbnails(List<File> encryptedPhotos) {
    return encryptedPhotos.map((photo) {
      final thumbnailPath = photo.path.replaceAll('.enc', '_thumbnail.png');
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
                return Image.file(_thumbnails[index]);
              },
            ),
    );
  }
}
