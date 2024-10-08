import 'package:flutter/material.dart';

class GalerieScreen extends StatelessWidget {
  const GalerieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
      ),
      body: const Center(
        child: Text(
          'Hier wird die Galerie der verschlüsselten Fotos angezeigt.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
