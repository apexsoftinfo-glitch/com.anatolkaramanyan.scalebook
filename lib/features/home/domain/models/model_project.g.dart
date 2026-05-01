// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModelProject _$ModelProjectFromJson(Map<String, dynamic> json) =>
    _ModelProject(
      id: json['id'] as String,
      title: json['title'] as String,
      scale: json['scale'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      mainImageUrl: json['mainImageUrl'] as String?,
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((e) => BuildStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      galleryUrls:
          (json['galleryUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ModelProjectToJson(_ModelProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scale': instance.scale,
      'progress': instance.progress,
      'status': instance.status,
      'mainImageUrl': instance.mainImageUrl,
      'steps': instance.steps,
      'galleryUrls': instance.galleryUrls,
      'createdAt': instance.createdAt.toIso8601String(),
    };
