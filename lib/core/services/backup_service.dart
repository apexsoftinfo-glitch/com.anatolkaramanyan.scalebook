import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  Future<String> createBackup() async {
    final docs = await getApplicationDocumentsDirectory();
    final dataDir = Directory(p.join(docs.path, 'scalebook_data'));
    
    if (!await dataDir.exists()) {
      throw Exception('No data to backup');
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final zipFile = File(p.join(tempDir.path, 'scalebook_backup_$timestamp.zip'));

    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);
    encoder.addDirectory(dataDir);
    encoder.close();

    return zipFile.path;
  }

  Future<void> shareBackup() async {
    final path = await createBackup();
    await Share.shareXFiles([XFile(path)], text: 'My ScaleBook Collection Backup');
  }

  Future<void> restoreBackup(File zipFile) async {
    final docs = await getApplicationDocumentsDirectory();

    // Extract ZIP
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(docs.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(p.join(docs.path, filename)).createSync(recursive: true);
      }
    }
  }
}
