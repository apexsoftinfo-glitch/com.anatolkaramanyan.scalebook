import 'package:freezed_annotation/freezed_annotation.dart';
import 'build_step.dart';

part 'model_project.freezed.dart';
part 'model_project.g.dart';

@freezed
abstract class ModelProject with _$ModelProject {
  const factory ModelProject({
    required String id,
    required String title,
    required String scale,
    @Default(0.0) double progress,
    required String status,
    @JsonKey(name: 'main_image_url') String? mainImageUrl,
    @Default([]) List<BuildStep> steps,
    @JsonKey(name: 'gallery_urls') @Default([]) List<String> galleryUrls,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ModelProject;

  const ModelProject._();

  factory ModelProject.fromJson(Map<String, dynamic> json) => _$ModelProjectFromJson(json);
}
