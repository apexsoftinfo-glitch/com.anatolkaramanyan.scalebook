import 'package:get_it/get_it.dart';
import '../../features/home/domain/repositories/models_repository.dart';
import '../../features/home/data/repositories/local_models_repository.dart';
import '../../features/home/data/repositories/supabase_models_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/model_detail/presentation/cubit/model_detail_cubit.dart';
import '../config/api_keys.dart';

void registerHomeModule(GetIt getIt) {
  // Repository
  if (ApiKeys.isSupabaseConfigured) {
    getIt.registerLazySingleton<ModelsRepository>(() => SupabaseModelsRepository());
  } else {
    getIt.registerLazySingleton<ModelsRepository>(() => LocalModelsRepository());
  }

  // Cubits
  getIt.registerFactory(() => HomeCubit(getIt<ModelsRepository>()));
  getIt.registerFactory(() => ModelDetailCubit(getIt<ModelsRepository>()));
}
