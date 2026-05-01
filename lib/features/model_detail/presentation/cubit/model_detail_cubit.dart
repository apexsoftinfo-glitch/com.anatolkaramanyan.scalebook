import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/models/build_step.dart';
import '../../../home/domain/repositories/models_repository.dart';
import 'model_detail_state.dart';

class ModelDetailCubit extends Cubit<ModelDetailState> {
  final ModelsRepository _repository;

  ModelDetailCubit(this._repository) : super(const ModelDetailState.initial());

  Future<void> loadProject(String id) async {
    emit(const ModelDetailState.loading());
    try {
      final project = await _repository.getProjectById(id);
      if (project != null) {
        emit(ModelDetailState.loaded(project));
      } else {
        emit(const ModelDetailState.error('Project not found'));
      }
    } catch (e) {
      emit(ModelDetailState.error(e.toString()));
    }
  }

  Future<void> addBuildStep(BuildStep step) async {
    state.maybeMap(
      loaded: (s) async {
        final updatedProject = s.project.copyWith(
          steps: [step, ...s.project.steps],
        );
        try {
          await _repository.updateProject(updatedProject);
          emit(ModelDetailState.loaded(updatedProject));
        } catch (e) {
          emit(ModelDetailState.error(e.toString()));
        }
      },
      orElse: () {},
    );
  }

  Future<void> updateBuildStep(BuildStep step) async {
    state.maybeMap(
      loaded: (s) async {
        final updatedSteps = s.project.steps.map((e) => e.id == step.id ? step : e).toList();
        final updatedProject = s.project.copyWith(steps: updatedSteps);
        try {
          await _repository.updateProject(updatedProject);
          emit(ModelDetailState.loaded(updatedProject));
        } catch (e) {
          emit(ModelDetailState.error(e.toString()));
        }
      },
      orElse: () {},
    );
  }

  Future<void> deleteBuildStep(String stepId) async {
    state.maybeMap(
      loaded: (s) async {
        final updatedSteps = s.project.steps.where((e) => e.id != stepId).toList();
        final updatedProject = s.project.copyWith(steps: updatedSteps);
        try {
          await _repository.updateProject(updatedProject);
          emit(ModelDetailState.loaded(updatedProject));
        } catch (e) {
          emit(ModelDetailState.error(e.toString()));
        }
      },
      orElse: () {},
    );
  }
}
