import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/sound_service.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/notes_repository.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _repository;

  NotesCubit(this._repository) : super(const NotesState.initial());

  Future<void> loadNotes() async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final notes = await _repository.getNotes();
      emit(state.copyWith(
        status: NotesStatus.loaded,
        notes: notes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _repository.addNote(note);
      await loadNotes();
      GetIt.I<SoundService>().playNewNote();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _repository.updateNote(note);
      await loadNotes();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes();
      GetIt.I<SoundService>().playDelete();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void clear() {
    emit(const NotesState.initial());
  }
}
