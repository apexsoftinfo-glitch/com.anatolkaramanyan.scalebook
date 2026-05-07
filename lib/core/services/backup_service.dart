import 'dart:io';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:convert';
import 'package:scalebook/features/home/domain/repositories/models_repository.dart';
import 'package:scalebook/features/home/domain/models/model_project.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  final ModelsRepository _modelsRepository;
  final SharedPreferences _prefs;

  BackupService(this._modelsRepository, this._prefs);

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
    
    // 1. Add images
    if (await dataDir.exists()) {
      encoder.addDirectory(dataDir);
    }

    // 2. Add Database (Projects + Build Steps)
    final projects = await _modelsRepository.getProjects();
    final projectsJson = projects.map((p) => p.toJson()).toList();
    final projectsFile = File(p.join(tempDir.path, 'projects_export.json'));
    await projectsFile.writeAsString(jsonEncode(projectsJson));
    encoder.addFile(projectsFile, 'projects_export.json');

    // 3. Add Settings
    final settings = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      settings[key] = _prefs.get(key);
    }
    final settingsFile = File(p.join(tempDir.path, 'settings_export.json'));
    await settingsFile.writeAsString(jsonEncode(settings));
    encoder.addFile(settingsFile, 'settings_export.json');

    encoder.close();

    return zipFile.path;
  }

  Future<void> shareBackup({Rect? sharePositionOrigin}) async {
    final path = await createBackup();
    await Share.shareXFiles(
      [XFile(path)],
      text: 'My ScaleBook Collection Backup',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<void> restoreBackup(File zipFile) async {
    final docs = await getApplicationDocumentsDirectory();

    // Extract ZIP
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 1. Extract all files to disk
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(p.join(docs.path, filename));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(p.join(docs.path, filename)).create(recursive: true);
      }
    }

    // 2. Restore Settings from settings_export.json
    final settingsFile = File(p.join(docs.path, 'settings_export.json'));
    if (await settingsFile.exists()) {
      try {
        final settingsJson = await settingsFile.readAsString();
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        for (final entry in settings.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value is String) {
            await _prefs.setString(key, value);
          } else if (value is bool) {
            await _prefs.setBool(key, value);
          } else if (value is int) {
            await _prefs.setInt(key, value);
          } else if (value is double) {
            await _prefs.setDouble(key, value);
          } else if (value is List) {
            await _prefs.setStringList(key, value.map((e) => e.toString()).toList());
          }
        }
      } catch (e) {
        // Silently fail or log properly in production
      }
    }

    // 3. Restore Projects into Repository
    final projectsFile = File(p.join(docs.path, 'projects_export.json'));
    if (await projectsFile.exists()) {
      try {
        final projectsJson = await projectsFile.readAsString();
        final List<dynamic> projectsList = jsonDecode(projectsJson);
        
        for (final item in projectsList) {
          final project = ModelProject.fromJson(item as Map<String, dynamic>);
          // This will either update existing or add new to the active repository (Local or Supabase)
          await _modelsRepository.updateProject(project);
        }
      } catch (e) {
        // Silently fail or log properly in production
      }
    }
  }
}
