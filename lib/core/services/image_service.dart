import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  Future<Directory> get _imageDir async {
    final docs = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(docs.path, 'scalebook_data', 'images'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<String> saveImage(File sourceFile) async {
    final directory = await _imageDir;
    final fileName = '${const Uuid().v4()}${p.extension(sourceFile.path)}';
    await sourceFile.copy(p.join(directory.path, fileName));
    // Store only the relative part: scalebook_data/images/filename.jpg
    return p.join('scalebook_data', 'images', fileName);
  }

  final Map<String, String> _pathCache = {};

  Future<String> resolvePath(String storedPath) async {
    if (storedPath.isEmpty) return storedPath;

    if (_pathCache.containsKey(storedPath)) {
      return _pathCache[storedPath]!;
    }

    // 1. Instant check if storedPath is already an existing absolute file path
    if (!storedPath.startsWith('http')) {
      final cleanPath = storedPath.startsWith('file://') ? storedPath.replaceFirst('file://', '') : storedPath;
      try {
        if (File(cleanPath).existsSync()) {
          _pathCache[storedPath] = cleanPath;
          return cleanPath;
        }
      } catch (_) {}
    }

    final docs = await getApplicationDocumentsDirectory();
    final marker = 'scalebook_data';
    String resolved = '';

    if (storedPath.startsWith('http')) {
      try {
        final uri = Uri.parse(storedPath);
        String fileName = p.basename(uri.path);
        final imagesDir = p.join(docs.path, 'scalebook_data', 'images');
        
        final exactPath = p.join(imagesDir, fileName);
        if (await File(exactPath).exists()) {
          resolved = exactPath;
        } else if (fileName.contains('_')) {
          final parts = fileName.split('_');
          if (parts.length > 1 && int.tryParse(parts[0]) != null && parts[0].length > 8) {
            final strippedName = parts.sublist(1).join('_');
            final strippedPath = p.join(imagesDir, strippedName);
            if (await File(strippedPath).exists()) {
              resolved = strippedPath;
            }
          }
        }
        if (resolved.isEmpty) {
          resolved = p.join(imagesDir, fileName);
        }
      } catch (e) {
        resolved = storedPath;
      }
    } else if (storedPath.contains(marker)) {
      final relativePart = storedPath.substring(storedPath.indexOf(marker));
      resolved = p.join(docs.path, relativePart);
    } else {
      resolved = p.join(docs.path, 'scalebook_data', 'images', storedPath);
    }

    _pathCache[storedPath] = resolved;
    return resolved;
  }

  Future<void> deleteImage(String storedPath) async {
    final absolutePath = await resolvePath(storedPath);
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> saveProjectPhotosToGallery({
    required dynamic project,
    Function(int current, int total)? onProgress,
  }) async {
    bool hasAccess = false;
    try {
      hasAccess = await Gal.hasAccess();
    } on MissingPluginException {
      throw Exception('Wtyczka systemowa wymaga przebudowania/zrestartowania aplikacji (Rebuild App).'); // L10N
    }

    if (!hasAccess) {
      bool granted = false;
      try {
        granted = await Gal.requestAccess();
      } on MissingPluginException {
        throw Exception('Wtyczka systemowa wymaga przebudowania/zrestartowania aplikacji (Rebuild App).'); // L10N
      }
      if (!granted) {
        throw Exception('Brak dostępu do galerii zdjęć'); // L10N
      }
    }

    final steps = project.steps as List? ?? [];
    final sortedSteps = List.of(steps)
      ..sort((a, b) => a.date.compareTo(b.date));

    final imageItems = <String>[];
    if (project.mainImageUrl != null && (project.mainImageUrl as String).isNotEmpty) {
      imageItems.add(project.mainImageUrl as String);
    }
    for (final step in sortedSteps) {
      if (step.imageUrl != null && (step.imageUrl as String).isNotEmpty) {
        imageItems.add(step.imageUrl as String);
      }
    }

    if (imageItems.isEmpty) return 0;

    int savedCount = 0;
    final tempDir = await getTemporaryDirectory();
    final baseTime = DateTime.now();

    for (int i = 0; i < imageItems.length; i++) {
      final itemPath = imageItems[i];
      String localFilePath = '';

      if (itemPath.startsWith('http')) {
        try {
          final client = HttpClient();
          final request = await client.getUrl(Uri.parse(itemPath)).timeout(const Duration(seconds: 10));
          final response = await request.close().timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            final bytes = await response.fold<List<int>>([], (acc, data) => acc..addAll(data));
            final tempFile = File(p.join(tempDir.path, 'gal_${const Uuid().v4()}.jpg'));
            await tempFile.writeAsBytes(bytes);
            localFilePath = tempFile.path;
          }
        } catch (e) {
          debugPrint('Error downloading image for gallery: $e');
        }
      } else {
        localFilePath = await resolvePath(itemPath);
      }

      if (localFilePath.isNotEmpty && await File(localFilePath).exists()) {
        try {
          final exportTime = baseTime.add(Duration(milliseconds: i * 500));
          String pathToSave = localFilePath;

          try {
            // Strip EXIF camera dates so iOS/Android gallery puts photo at top of Recents
            final bytes = await File(localFilePath).readAsBytes();
            final decoded = img.decodeImage(bytes);
            if (decoded != null) {
              decoded.exif.clear();
              final cleanBytes = img.encodeJpg(decoded, quality: 92);
              final cleanFile = File(p.join(tempDir.path, 'recents_${i}_${const Uuid().v4()}.jpg'));
              await cleanFile.writeAsBytes(cleanBytes);
              await cleanFile.setLastModified(exportTime);
              pathToSave = cleanFile.path;
            }
          } catch (_) {
            final file = File(localFilePath);
            await file.setLastModified(exportTime);
          }

          await Gal.putImage(pathToSave);
          savedCount++;
        } catch (e) {
          debugPrint('Gal save error for $localFilePath: $e');
        }
      }

      onProgress?.call(i + 1, imageItems.length);
    }

    return savedCount;
  }
}
