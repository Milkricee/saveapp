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

  Future<void> _loadEncryptedPhotos() async {
    var loadedFiles = await FileManager.loadEncryptedFiles();

    setState(() {
      _encryptedPhotos = loadedFiles['photos'] ?? [];
      _thumbnails = loadedFiles['thumbnails'] ?? [];
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
                return GestureDetector(
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
                  child: Image.file(
                    _thumbnails[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
