import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/models/build_step.dart';
import '../../../home/domain/repositories/models_repository.dart';
import 'model_detail_state.dart';

class ModelDetailCubit extends Cubit<ModelDetailState> {
  final ModelsRepository _repository;

  ModelDetailCubit(this._repository) : super(const ModelDetailState.initial());

  Future<void> loadProject(String id) async {
    debugPrint('CUBIT: Rozpoczynam loadProject dla ID: $id');
    emit(const ModelDetailState.loading());
    try {
      debugPrint('CUBIT: Wywołuję repository.getProjectById...');
      final project = await _repository.getProjectById(id);
      debugPrint('CUBIT: Otrzymano odpowiedź z repository: ${project != null ? 'PROJEKT ZNALEZIONY' : 'NULL'}');
      
      if (project != null) {
        debugPrint('CUBIT: Emituję stan LOADED dla projektu: ${project.title}');
        emit(ModelDetailState.loaded(project));
        debugPrint('CUBIT: Stan LOADED wyemitowany pomyślnie.');
      } else {
        debugPrint('CUBIT: Projekt nie znaleziony, emituję ERROR.');
        emit(const ModelDetailState.error('Project not found'));
      }
    } catch (e, stack) {
      debugPrint('CUBIT: BŁĄD PODCZAS ŁADOWANIA: $e');
      debugPrint('CUBIT: STACK: $stack');
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
        try {
          // 1. Delete from database
          await _repository.deleteBuildStep(stepId);
          
          // 2. Update local state
          final updatedSteps = s.project.steps.where((e) => e.id != stepId).toList();
          final updatedProject = s.project.copyWith(steps: updatedSteps);
          emit(ModelDetailState.loaded(updatedProject));
        } catch (e) {
          emit(ModelDetailState.error(e.toString()));
        }
      },
      orElse: () {},
    );
  }

  Future<void> updateStatus(String status) async {
    state.maybeMap(
      loaded: (s) async {
        final updatedProject = s.project.copyWith(status: status);
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
