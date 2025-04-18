// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopPlaceImpl _$$TopPlaceImplFromJson(Map<String, dynamic> json) =>
    _$TopPlaceImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: Country.fromJson(json['country'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$TopPlaceImplToJson(_$TopPlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'images': instance.images,
    };

_$CountryImpl _$$CountryImplFromJson(Map<String, dynamic> json) =>
    _$CountryImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CountryImplToJson(_$CountryImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
