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
    final savedFile = await sourceFile.copy(p.join(directory.path, fileName));
    return savedFile.path;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
