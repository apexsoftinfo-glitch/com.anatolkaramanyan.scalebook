import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:json_annotation/json_annotation.dart'; // Removed as unnecessary

part 'build_step.freezed.dart';
part 'build_step.g.dart';

@freezed
abstract class BuildStep with _$BuildStep {
  const factory BuildStep({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    required DateTime date,
    required String note,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
  }) = _BuildStep;

  const BuildStep._();

  factory BuildStep.fromJson(Map<String, dynamic> json) => _$BuildStepFromJson(json);
}
