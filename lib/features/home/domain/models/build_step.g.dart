// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuildStep _$BuildStepFromJson(Map<String, dynamic> json) => _BuildStep(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  date: DateTime.parse(json['date'] as String),
  note: json['note'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$BuildStepToJson(_BuildStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
      'imageUrl': instance.imageUrl,
    };
