import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../home/domain/models/model_project.dart';

part 'model_detail_state.freezed.dart';

@freezed
abstract class ModelDetailState with _$ModelDetailState {
  const factory ModelDetailState.initial() = _Initial;
  const factory ModelDetailState.loading() = _Loading;
  const factory ModelDetailState.loaded(ModelProject project) = _Loaded;
  const factory ModelDetailState.error(String message) = _Error;
}
