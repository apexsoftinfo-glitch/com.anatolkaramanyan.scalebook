part of 'notes_cubit.dart';

enum NotesStatus { initial, loading, loaded, error }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final String? errorMessage;

  const NotesState({
    required this.status,
    this.notes = const [],
    this.errorMessage,
  });

  const NotesState.initial() : this(status: NotesStatus.initial);

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? errorMessage,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
