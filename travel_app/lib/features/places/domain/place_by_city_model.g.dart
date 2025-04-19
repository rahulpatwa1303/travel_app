// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_by_city_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceByCityImpl _$$PlaceByCityImplFromJson(Map<String, dynamic> json) =>
    _$PlaceByCityImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'] as String,
      address: json['address'] as String?,
      cityId: (json['city_id'] as num).toInt(),
      images: json['images'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$PlaceByCityImplToJson(_$PlaceByCityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'category': instance.category,
      'address': instance.address,
      'city_id': instance.cityId,
      'images': instance.images,
    };
