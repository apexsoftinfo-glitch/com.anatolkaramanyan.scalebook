import 'package:freezed_annotation/freezed_annotation.dart';

part 'build_step.freezed.dart';
part 'build_step.g.dart';

@freezed
abstract class BuildStep with _$BuildStep {
  const factory BuildStep({
    required String id,
    required String projectId,
    required DateTime date,
    required String note,
    String? imageUrl,
  }) = _BuildStep;

  const BuildStep._();

  factory BuildStep.fromJson(Map<String, dynamic> json) => _$BuildStepFromJson(json);
}
