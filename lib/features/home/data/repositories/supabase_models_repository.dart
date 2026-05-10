import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/model_project.dart';
import '../../domain/models/build_step.dart';
import '../../domain/repositories/models_repository.dart';

class SupabaseModelsRepository implements ModelsRepository {
  SupabaseClient get _client => Supabase.instance.client;
  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Użytkownik nie jest zalogowany'); // L10N
    return user.id;
  }

  @override
  Future<List<ModelProject>> getProjects() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('projects')
        .select('*, build_steps(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(json);
      
      // Map Supabase snake_case to Model camelCase
      if (data.containsKey('main_image_url')) data['mainImageUrl'] = data['main_image_url'];
      if (data.containsKey('gallery_urls')) data['galleryUrls'] = data['gallery_urls'];
      if (data.containsKey('finished_main_image_url')) data['finishedMainImageUrl'] = data['finished_main_image_url'];
      if (data.containsKey('finished_gallery_urls')) data['finishedGalleryUrls'] = data['finished_gallery_urls'];
      if (data.containsKey('final_notes')) data['finalNotes'] = data['final_notes'];
      if (data.containsKey('created_at')) data['createdAt'] = data['created_at'];

      final stepsData = data['build_steps'] as List;
      final steps = stepsData.map((s) {
        final Map<String, dynamic> stepData = Map<String, dynamic>.from(s as Map<String, dynamic>);
        if (stepData.containsKey('project_id')) stepData['projectId'] = stepData['project_id'];
        if (stepData.containsKey('image_url')) stepData['imageUrl'] = stepData['image_url'];
        return BuildStep.fromJson(stepData);
      }).toList();
      
      steps.sort((a, b) => b.date.compareTo(a.date));
      
      return ModelProject.fromJson(data).copyWith(steps: steps);
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
    // 1. Upsert project details (using upsert ensures restoration works for non-existent projects)
    await _client.from('projects').upsert({
      'id': project.id,
      'user_id': _userId,
      'title': project.title,
      'scale': project.scale,
      'progress': project.progress,
      'status': project.status,
      'main_image_url': project.mainImageUrl,
      'gallery_urls': project.galleryUrls,
      'finished_main_image_url': project.finishedMainImageUrl,
      'finished_gallery_urls': project.finishedGalleryUrls,
      'final_notes': project.finalNotes,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

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
    try {
      debugPrint('REPO: Rozpoczynam pobieranie projektu z Supabase: $id');
      final response = await _client
          .from('projects')
          .select('*, build_steps(*)')
          .eq('id', id)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));
      
      debugPrint('REPO: Otrzymano odpowiedź z Supabase');
      if (response == null) {
        debugPrint('REPO: Projekt nie został znaleziony w bazie');
        return null;
      }
      
      debugPrint('REPO: Przetwarzam JSON na obiekt ModelProject...');
      final Map<String, dynamic> data = Map<String, dynamic>.from(response);
      
      // Map Supabase snake_case to Model camelCase
      if (data.containsKey('main_image_url')) data['mainImageUrl'] = data['main_image_url'];
      if (data.containsKey('gallery_urls')) data['galleryUrls'] = data['gallery_urls'];
      if (data.containsKey('finished_main_image_url')) data['finishedMainImageUrl'] = data['finished_main_image_url'];
      if (data.containsKey('finished_gallery_urls')) data['finishedGalleryUrls'] = data['finished_gallery_urls'];
      if (data.containsKey('final_notes')) data['finalNotes'] = data['final_notes'];
      if (data.containsKey('created_at')) data['createdAt'] = data['created_at'];

      final stepsData = data['build_steps'] as List;
      final steps = stepsData.map((s) {
        final Map<String, dynamic> stepData = Map<String, dynamic>.from(s as Map<String, dynamic>);
        if (stepData.containsKey('project_id')) stepData['projectId'] = stepData['project_id'];
        if (stepData.containsKey('image_url')) stepData['imageUrl'] = stepData['image_url'];
        return BuildStep.fromJson(stepData);
      }).toList();

      steps.sort((a, b) => b.date.compareTo(a.date));

      final project = ModelProject.fromJson(data).copyWith(steps: steps);
      debugPrint('REPO: Sukces! Zwracam projekt: ${project.title}');
      return project;
    } catch (e, stack) {
      debugPrint('REPO: BŁĄD W getProjectById: $e');
      debugPrint('REPO: STACK: $stack');
      rethrow;
    }
  }
  @override
  Future<void> deleteBuildStep(String stepId) async {
    await _client.from('build_steps').delete().eq('id', stepId);
  }
}
