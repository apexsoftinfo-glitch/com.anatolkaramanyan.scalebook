import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/models/model_project.dart';
import '../../domain/repositories/models_repository.dart';

class LocalModelsRepository implements ModelsRepository {
  Future<Directory> get _dataDir async {
    final docs = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(docs.path, 'scalebook_data', 'projects'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  @override
  Future<List<ModelProject>> getProjects() async {
    final directory = await _dataDir;
    final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
    
    final projects = <ModelProject>[];
    for (final file in files) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        projects.add(ModelProject.fromJson(json));
      } catch (e) {
        // Skip corrupted files
      }
    }
    
    // Sort by creation date descending
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  @override
  Future<void> addProject(ModelProject project) async {
    await updateProject(project);
  }

  @override
  Future<void> updateProject(ModelProject project) async {
    final directory = await _dataDir;
    final file = File(p.join(directory.path, '${project.id}.json'));
    await file.writeAsString(jsonEncode(project.toJson()));
  }

  @override
  Future<void> deleteProject(String id) async {
    final directory = await _dataDir;
    final file = File(p.join(directory.path, '$id.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<ModelProject?> getProjectById(String id) async {
    final directory = await _dataDir;
    final file = File(p.join(directory.path, '$id.json'));
    if (await file.exists()) {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return ModelProject.fromJson(json);
    }
    return null;
  }
  @override
  Future<void> deleteBuildStep(String stepId) async {
    // For local, build steps are part of the project json, 
    // so this is usually handled via updateProject.
    // But we implement it for consistency.
  }
}
