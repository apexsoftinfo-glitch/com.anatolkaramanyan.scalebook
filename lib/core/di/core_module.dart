import 'package:get_it/get_it.dart';
import '../services/image_service.dart';
import '../services/backup_service.dart';

void registerCoreModule(GetIt getIt) {
  getIt.registerLazySingleton(() => ImageService());
  getIt.registerLazySingleton(() => BackupService());
}
