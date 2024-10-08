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

  @override
  void initState() {
    super.initState();
    _loadEncryptedPhotos();
  }

  // Lädt die verschlüsselten Fotos aus dem lokalen Verzeichnis
  Future<void> _loadEncryptedPhotos() async {
    List<File> photos = await FileManager.loadEncryptedPhotos();
    setState(() {
      _encryptedPhotos = photos;
    });
  }

  // Aktualisiert die Galerie nach dem Import neuer Fotos
  void _onPhotosImported(List<File> newPhotos) {
    setState(() {
      _encryptedPhotos.addAll(newPhotos); // Neue Fotos zur Galerie hinzufügen
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
            onPressed: () => FileManager.importPhotos(context, _onPhotosImported),
          ),
        ],
      ),
      body: _encryptedPhotos.isEmpty
          ? const Center(child: Text('Keine Fotos verfügbar'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Anzahl der Spalten in der Grid-Ansicht
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _encryptedPhotos.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Image>(
                  future: FileManager.loadThumbnail(_encryptedPhotos[index]), // Thumbnails laden
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Icon(Icons.error));
                    }
                    return snapshot.data ?? const SizedBox.shrink();
                  },
                );
              },
            ),
    );
  }
}
