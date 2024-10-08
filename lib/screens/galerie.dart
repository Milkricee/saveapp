import 'package:flutter/material.dart';
import 'dart:io';
import 'package:saveapp/logik/file_manager.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key});

  @override
  GalerieScreenState createState() => GalerieScreenState();
}

class GalerieScreenState extends State<GalerieScreen> {
  List<File> _encryptedPhotos = [];
  bool _isPickerActive = false; // Lokale Variable zur Verhinderung von Mehrfachaufrufen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (_isPickerActive) return; // Prüfen, ob Picker bereits aktiv ist
              setState(() {
                _isPickerActive = true;
              });

              try {
                await FileManager.importPhotos(context, (files, _) {
                  setState(() {
                    _encryptedPhotos.addAll(files);
                  });
                });
              } finally {
                setState(() {
                  _isPickerActive = false; // Status zurücksetzen
                });
              }
            },
          ),
        ],
      ),
      body: _encryptedPhotos.isEmpty
          ? const Center(child: Text('Keine Fotos verfügbar'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _encryptedPhotos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Vollbildansicht
                  },
                  child: Image.file(
                    _encryptedPhotos[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
