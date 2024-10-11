import 'dart:io';
import 'package:saveapp/logik/file_manager.dart';

class GalerieManager {
  Future<List<File>> loadPhotos() async {
    final localPath = await FileManager.getLocalPath();
    final directory = Directory(localPath);

    final files = directory.listSync().whereType<File>().toList();
    return files.where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png') || file.path.endsWith('.enc')).toList();
  }
}
