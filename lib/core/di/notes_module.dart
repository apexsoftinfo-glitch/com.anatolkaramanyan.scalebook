import 'package:get_it/get_it.dart';
import '../../features/notes/data/repositories/supabase_notes_repository.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/presentation/cubit/notes_cubit.dart';

void registerNotesModule(GetIt getIt) {
  // Repositories
  getIt.registerLazySingleton<NotesRepository>(() => SupabaseNotesRepository());

  // Cubits
  getIt.registerFactory(() => NotesCubit(getIt<NotesRepository>()));
}
