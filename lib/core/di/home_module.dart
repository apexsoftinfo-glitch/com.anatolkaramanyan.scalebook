import 'package:get_it/get_it.dart';
import '../../features/home/domain/repositories/models_repository.dart';
import '../../features/home/data/repositories/local_models_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/model_detail/presentation/cubit/model_detail_cubit.dart';

void registerHomeModule(GetIt getIt) {
  // Repository
  getIt.registerLazySingleton<ModelsRepository>(() => LocalModelsRepository());

  // Cubits
  getIt.registerFactory(() => HomeCubit(getIt<ModelsRepository>()));
  getIt.registerFactory(() => ModelDetailCubit(getIt<ModelsRepository>()));
}
