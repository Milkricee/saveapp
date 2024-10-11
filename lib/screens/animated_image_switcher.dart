import 'dart:async';
import 'package:flutter/material.dart';

class ImageAnimation extends StatefulWidget {
  const ImageAnimation({super.key});

  @override
  ImageAnimationState createState() => ImageAnimationState();
}

class ImageAnimationState extends State<ImageAnimation> {
  int _currentImageIndex = 0;
  final List<String> _images = [
    'assets/cat_1.png',
    'assets/cat_2.png',
    'assets/cat_3.png',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startImageRotation();
  }

  void _startImageRotation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer stoppen, wenn der State zerstört wird
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _images[_currentImageIndex],
      height: 50,
      fit: BoxFit.contain,
    );
  }
}
