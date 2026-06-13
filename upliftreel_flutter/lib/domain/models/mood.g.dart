// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoodInput _$MoodInputFromJson(Map<String, dynamic> json) => _MoodInput(
  mood: $enumDecode(_$MoodEnumMap, json['mood']),
  intensity: (json['intensity'] as num).toInt(),
  seriousness: (json['seriousness'] as num).toInt(),
);

Map<String, dynamic> _$MoodInputToJson(_MoodInput instance) =>
    <String, dynamic>{
      'mood': _$MoodEnumMap[instance.mood]!,
      'intensity': instance.intensity,
      'seriousness': instance.seriousness,
    };

const _$MoodEnumMap = {
  Mood.happy: 'happy',
  Mood.suspense: 'suspense',
  Mood.introspective: 'introspective',
  Mood.excited: 'excited',
  Mood.romantic: 'romantic',
  Mood.adventurous: 'adventurous',
  Mood.relaxed: 'relaxed',
  Mood.curious: 'curious',
};
