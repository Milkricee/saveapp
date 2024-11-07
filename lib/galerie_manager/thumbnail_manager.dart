import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ThumbnailManager {
  static const String _thumbnailDirName = "thumbnails";

  // Generiert ein Thumbnail für eine verschlüsselte oder normale Bilddatei
  static Future<File> generateThumbnail(File photoFile) async {
    final localPath = await _getThumbnailDirectory();
    final thumbnailPath = '$localPath/thumbnail_${photoFile.hashCode}.png';

    // Wenn das Thumbnail bereits existiert, direkt zurückgeben
    final thumbnailFile = File(thumbnailPath);
    if (thumbnailFile.existsSync()) {
      return thumbnailFile;
    }

    Uint8List photoBytes;
    if (photoFile.path.endsWith('.enc')) {
      photoBytes = await photoFile.readAsBytes();
    } else {
      photoBytes = await photoFile.readAsBytes();
    }

    final originalImage = img.decodeImage(photoBytes);
    if (originalImage == null) {
      throw Exception("Fehler beim Decodieren des Bildes");
    }

    // Generiere ein verkleinertes Thumbnail
    final thumbnail = img.copyResize(originalImage, width: 200, height: 200);
    await thumbnailFile.writeAsBytes(Uint8List.fromList(img.encodePng(thumbnail)));
    return thumbnailFile;
  }

  // Lädt das Thumbnail, falls es existiert, oder generiert es bei Bedarf
  static Future<File> getOrCreateThumbnail(File photoFile) async {
    final localPath = await _getThumbnailDirectory();
    final thumbnailPath = '$localPath/thumbnail_${photoFile.hashCode}.png';

    final thumbnailFile = File(thumbnailPath);
    if (thumbnailFile.existsSync()) {
      return thumbnailFile;
    }

    return await generateThumbnail(photoFile);
  }

  // Bereinigt alle alten Thumbnails
  static Future<void> clearThumbnails() async {
    final thumbnailDir = Directory(await _getThumbnailDirectory());
    if (thumbnailDir.existsSync()) {
      for (var file in thumbnailDir.listSync()) {
        if (file is File && file.path.endsWith('.png')) {
          await file.delete();
        }
      }
    }
  }

  // Erstellt und gibt den Pfad für das Thumbnail-Verzeichnis zurück
  static Future<String> _getThumbnailDirectory() async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final thumbnailDirPath = '${appDocumentsDir.path}/$_thumbnailDirName';

    final thumbnailDir = Directory(thumbnailDirPath);
    if (!thumbnailDir.existsSync()) {
      thumbnailDir.createSync(recursive: true);
    }

    return thumbnailDirPath;
  }
}
