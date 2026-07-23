import 'package:get_it/get_it.dart';
import '../config/api_keys.dart';
import '../../features/notes/data/repositories/local_notes_repository.dart';
import '../../features/notes/data/repositories/supabase_notes_repository.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/presentation/cubit/notes_cubit.dart';

void registerNotesModule(GetIt getIt) {
  // Repositories
  if (ApiKeys.isSupabaseConfigured) {
    getIt.registerLazySingleton<NotesRepository>(() => SupabaseNotesRepository());
  } else {
    getIt.registerLazySingleton<NotesRepository>(() => LocalNotesRepository());
  }

  // Cubits
  getIt.registerFactory(() => NotesCubit(getIt<NotesRepository>()));
}
