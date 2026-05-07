import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/session/presentation/cubit/locale_cubit.dart';
import '../services/image_service.dart';
import '../services/backup_service.dart';
import '../services/review_service.dart';

import '../../features/home/domain/repositories/models_repository.dart';

void registerCoreModule(GetIt getIt) {
  getIt.registerLazySingleton(() => ImageService());
  getIt.registerLazySingleton(() => BackupService(getIt<ModelsRepository>(), getIt<SharedPreferences>()));
  getIt.registerLazySingleton(() => ReviewService());
  getIt.registerLazySingleton(() => LocaleCubit(getIt<SharedPreferences>()));
}
