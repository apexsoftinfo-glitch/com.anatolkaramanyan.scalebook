import 'dart:io';
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

  Future<String> resolvePath(String storedPath) async {
    final docs = await getApplicationDocumentsDirectory();
    final marker = 'scalebook_data';
    
    // If it's a URL, extract the filename to check for a local copy
    if (storedPath.startsWith('http')) {
      try {
        final uri = Uri.parse(storedPath);
        String fileName = p.basename(uri.path);
        final imagesDir = p.join(docs.path, 'scalebook_data', 'images');
        
        // 1. Try exact match
        final exactPath = p.join(imagesDir, fileName);
        if (await File(exactPath).exists()) return exactPath;
        
        // 2. Try matching without the timestamp prefix (e.g. "1715340000_uuid.jpg" -> "uuid.jpg")
        if (fileName.contains('_')) {
          final parts = fileName.split('_');
          // Check if first part is a timestamp (digits only and looks like a timestamp)
          if (parts.length > 1 && int.tryParse(parts[0]) != null && parts[0].length > 8) {
            final strippedName = parts.sublist(1).join('_');
            final strippedPath = p.join(imagesDir, strippedName);
            if (await File(strippedPath).exists()) return strippedPath;
          }
        }
        
        return p.join(imagesDir, fileName); // Default fallback (won't exist)
      } catch (e) {
        return storedPath; // Fallback
      }
    }

    if (storedPath.contains(marker)) {
      final relativePart = storedPath.substring(storedPath.indexOf(marker));
      return p.join(docs.path, relativePart);
    }
    
    return p.join(docs.path, 'scalebook_data', 'images', storedPath);
  }

  Future<void> deleteImage(String storedPath) async {
    final absolutePath = await resolvePath(storedPath);
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
