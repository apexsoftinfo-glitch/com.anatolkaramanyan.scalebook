import 'dart:io';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:scalebook/core/services/sound_service.dart';

import 'dart:convert';
import 'package:scalebook/features/home/domain/repositories/models_repository.dart';
import 'package:scalebook/features/home/domain/models/model_project.dart';
import 'package:scalebook/features/session/domain/models/user_session.dart';
import 'package:scalebook/features/session/presentation/cubit/session_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

class BackupService {
  final ModelsRepository _modelsRepository;
  final SharedPreferences _prefs;

  BackupService(this._modelsRepository, this._prefs);

  Future<String> createBackup({Function(double)? onProgress}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dataDir = Directory(p.join(docs.path, 'scalebook_data'));
    
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final zipFile = File(p.join(tempDir.path, 'scalebook_backup_$timestamp.zip'));

    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);
    
    // 1. Add ALL local data files recursively (Photos, etc.)
    final List<FileSystemEntity> entities = await dataDir.list(recursive: true).toList();
    final List<File> allFiles = entities.whereType<File>().toList();
    
    final totalSteps = allFiles.length + 3; // +3 for Projects, Profile, Settings
    int currentStep = 0;

    for (final File entity in allFiles) {
      // We store with relative path from documents root (e.g. scalebook_data/images/xxx.jpg)
      final relativePath = p.relative(entity.path, from: docs.path);
      encoder.addFile(entity, relativePath);
      
      currentStep++;
      onProgress?.call(currentStep / totalSteps);
    }

    // 2. Add Database (Projects + Build Steps)
    final projects = await _modelsRepository.getProjects();
    final projectsJson = projects.map((p) => p.toJson()).toList();
    final projectsFile = File(p.join(tempDir.path, 'projects_export.json'));
    await projectsFile.writeAsString(jsonEncode(projectsJson));
    encoder.addFile(projectsFile, 'projects_export.json');
    currentStep++;
    onProgress?.call(currentStep / totalSteps);

    // 3. Add Profile Info (especially for Supabase users)
    final sessionCubit = GetIt.I<SessionCubit>();
    final profile = sessionCubit.state.mapOrNull(
      (s) => s.profile,
    );
    if (profile != null) {
      final profileFile = File(p.join(tempDir.path, 'profile_export.json'));
      await profileFile.writeAsString(jsonEncode(profile.toJson()));
      encoder.addFile(profileFile, 'profile_export.json');
    }
    currentStep++;
    onProgress?.call(currentStep / totalSteps);

    // 4. Add Settings (SharedPreferences)
    final settings = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      // Exclude session-specific keys if they shouldn't be moved
      if (key.contains('supabase')) continue; 
      settings[key] = _prefs.get(key);
    }
    final settingsFile = File(p.join(tempDir.path, 'settings_export.json'));
    await settingsFile.writeAsString(jsonEncode(settings));
    encoder.addFile(settingsFile, 'settings_export.json');
    currentStep++;
    onProgress?.call(currentStep / totalSteps);

    encoder.close();
    onProgress?.call(1.0);

    return zipFile.path;
  }

  Future<void> shareBackup({Rect? sharePositionOrigin, Function(double)? onProgress}) async {
    final path = await createBackup(onProgress: onProgress);
    
    // Play sound when backup is successfully created
    GetIt.I<SoundService>().playNewProject();

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: 'My ScaleBook Collection Backup',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<void> restoreBackup(File zipFile, {Function(double)? onProgress}) async {
    final docs = await getApplicationDocumentsDirectory();

    // Extract ZIP
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final total = archive.length;
    int count = 0;

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
      count++;
      onProgress?.call(count / total);
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
        debugPrint('Failed to restore settings: $e');
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
          
          try {
            // Try updating/inserting the project with its original ID
            await _modelsRepository.updateProject(project);
          } catch (e) {
            final errStr = e.toString();
            // Check for Supabase RLS violation (42501) or constraint violation (23505)
            if (errStr.contains('42501') || 
                errStr.contains('violates row-level security') || 
                errStr.contains('23505') ||
                errStr.contains('unique_conflict')) {
              debugPrint('Project ID conflict detected for project "${project.title}". Generating new IDs.');
              
              // Generate new project ID
              final newProjectId = const Uuid().v4();
              
              // Update steps with new IDs and new project ID
              final updatedSteps = project.steps.map((step) {
                return step.copyWith(
                  id: const Uuid().v4(),
                  projectId: newProjectId,
                );
              }).toList();
              
              // Copy project with new ID and updated steps
              final newProject = project.copyWith(
                id: newProjectId,
                steps: updatedSteps,
              );
              
              // Retry updating/inserting
              await _modelsRepository.updateProject(newProject);
            } else {
              rethrow;
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to restore projects: $e');
        rethrow;
      }
    }
  }
}
