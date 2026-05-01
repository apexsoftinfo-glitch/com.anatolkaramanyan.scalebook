import '../models/model_project.dart';

abstract class ModelsRepository {
  Future<List<ModelProject>> getProjects();
  Future<void> addProject(ModelProject project);
  Future<void> updateProject(ModelProject project);
  Future<void> deleteProject(String id);
  Future<ModelProject?> getProjectById(String id);
}
