import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/review_service.dart';
import '../../domain/models/model_project.dart';
import '../../domain/repositories/models_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ModelsRepository _repository;

  HomeCubit(this._repository) : super(const HomeState.initial());

  Future<void> loadProjects() async {
    emit(const HomeState.loading());
    try {
      final projects = await _repository.getProjects();
      emit(HomeState.loaded(projects));
    } catch (e) {
      emit(HomeState.error(e.toString()));
    }
  }

  int get projectCount => state.maybeWhen(
        loaded: (projects) => projects.length,
        orElse: () => 0,
      );

  Future<void> addProject(ModelProject project) async {
    try {
      await _repository.addProject(project);
      await loadProjects(); // Refresh list
      
      // Track project creation for review prompt
      GetIt.I<ReviewService>().recordProjectCreated();
    } catch (e) {
      emit(HomeState.error(e.toString()));
      rethrow; // Allow UI to catch this
    }
  }

  Future<void> updateProject(ModelProject project) async {
    try {
      await _repository.updateProject(project);
      await loadProjects(); // Refresh list
    } catch (e) {
      emit(HomeState.error(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _repository.deleteProject(id);
      await loadProjects(); // Refresh list
    } catch (e) {
      emit(HomeState.error(e.toString()));
      rethrow;
    }
  }
}
