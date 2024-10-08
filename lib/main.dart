import 'package:flutter/material.dart';
import 'package:saveapp/screens/home.dart';

void main() {
  runApp(const SaveApp());
}

class SaveApp extends StatelessWidget {
  const SaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foto-Safe-App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

