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
    // If it's a URL, return as is
    if (storedPath.startsWith('http')) return storedPath;

    // If it's an absolute path that is now invalid (iOS UUID issue), 
    // extract the relative part and rebuild it.
    final docs = await getApplicationDocumentsDirectory();
    
    // Find where scalebook_data starts in the stored path
    final marker = 'scalebook_data';
    if (storedPath.contains(marker)) {
      final relativePart = storedPath.substring(storedPath.indexOf(marker));
      return p.join(docs.path, relativePart);
    }
    
    // Fallback: if it's just a filename
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
