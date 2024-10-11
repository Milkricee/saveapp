import 'package:flutter/material.dart';
import 'package:saveapp/screens/photo_view_screen.dart';
import 'dart:io';

class PhotoViewNavigation {
  static void navigateToPhotoView(BuildContext context, List<File> images, int index) {
    Navigator.push(
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
