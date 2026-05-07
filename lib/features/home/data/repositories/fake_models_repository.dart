import '../../domain/models/model_project.dart';
import '../../domain/repositories/models_repository.dart';

class FakeModelsRepository implements ModelsRepository {
  final List<ModelProject> _projects = [
    ModelProject(
      id: '1',
      title: 'Nissan Skyline R34',
      scale: '1/24',
      progress: 0.45,
      status: 'Painting',
      mainImageUrl: 'https://images.unsplash.com/photo-1611003228941-98a5216832db?auto=format&fit=crop&q=80&w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    ModelProject(
      id: '2',
      title: 'Ferrari F40',
      scale: '1/24',
      progress: 0.90,
      status: 'Detailing',
      mainImageUrl: 'https://images.unsplash.com/photo-1592198084033-aade902d1aae?auto=format&fit=crop&q=80&w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  @override
  Future<List<ModelProject>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _projects;
  }

  @override
  Future<void> addProject(ModelProject project) async {
    _projects.add(project);
  }

  @override
  Future<void> updateProject(ModelProject project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
  }

  @override
  Future<ModelProject?> getProjectById(String id) async {
    return _projects.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> deleteBuildStep(String stepId) async {
    // Fake implementation
  }
}
