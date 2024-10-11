import 'package:flutter/material.dart';
import 'package:saveapp/screens/photo_view_screen.dart';
import 'dart:io';

class PhotoViewNavigation {
  static Future<bool?> navigateToPhotoView(BuildContext context, List<File> images, int index) {
    // Rückgabewert `bool` erwartet, um anzugeben, ob ein Bild gelöscht wurde
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(
          imageFiles: images,
          initialIndex: index,
        ),
      ),
    );
  }
}
