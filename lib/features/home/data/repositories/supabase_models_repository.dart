import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/model_project.dart';
import '../../domain/models/build_step.dart';
import '../../domain/repositories/models_repository.dart';

class SupabaseModelsRepository implements ModelsRepository {
  SupabaseClient get _client => Supabase.instance.client;
  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<ModelProject>> getProjects() async {
    final response = await _client
        .from('projects')
        .select('*, build_steps(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final stepsData = json['build_steps'] as List;
      final steps = stepsData.map((s) => BuildStep.fromJson(s)).toList();
      // Sort steps by date descending
      steps.sort((a, b) => b.date.compareTo(a.date));
      
      return ModelProject.fromJson({
        ...json,
        'steps': steps,
      });
    }).toList();
  }

  @override
  Future<void> addProject(ModelProject project) async {
    await _client.from('projects').insert({
      ...project.toJson()..remove('steps'),
      'user_id': _userId,
    });
    
    if (project.steps.isNotEmpty) {
      await _client.from('build_steps').insert(
        project.steps.map((s) => {
          ...s.toJson(),
          'user_id': _userId,
        }).toList()
      );
    }
  }

  @override
  Future<void> updateProject(ModelProject project) async {
    // 1. Update project details
    await _client.from('projects').update({
      'title': project.title,
      'scale': project.scale,
      'progress': project.progress,
      'status': project.status,
      'main_image_url': project.mainImageUrl,
      'gallery_urls': project.galleryUrls,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', project.id);

    // 2. Sync build steps (naive approach: upsert)
    if (project.steps.isNotEmpty) {
      await _client.from('build_steps').upsert(
        project.steps.map((s) => {
          ...s.toJson(),
          'user_id': _userId,
          'project_id': project.id,
        }).toList()
      );
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }

  @override
  Future<ModelProject?> getProjectById(String id) async {
    final response = await _client
        .from('projects')
        .select('*, build_steps(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final stepsData = response['build_steps'] as List;
    final steps = stepsData.map((s) => BuildStep.fromJson(s)).toList();
    steps.sort((a, b) => b.date.compareTo(a.date));

    return ModelProject.fromJson({
      ...response,
      'steps': steps,
    });
  }
}
