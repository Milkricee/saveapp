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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => FileManager.importPhoto(context),
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
                return GestureDetector(
                  onTap: () {
                    // Hier könnte die Vorschau eines verschlüsselten Fotos implementiert werden
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Foto ${index + 1} angeklickt')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Center(
                      child: Text(
                        'Foto ${index + 1}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
