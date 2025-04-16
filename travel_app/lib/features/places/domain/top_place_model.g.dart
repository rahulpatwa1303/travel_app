// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopPlaceImpl _$$TopPlaceImplFromJson(Map<String, dynamic> json) =>
    _$TopPlaceImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      website: json['website'] as String?,
      description: json['description'] as String?,
      osm_id: (json['osm_id'] as num?)?.toInt(),
      tags: json['tags'] as Map<String, dynamic>?,
      category: json['category'] as String?,
      relevance_score: (json['relevance_score'] as num?)?.toDouble(),
      reason:
          (json['reason'] as List<dynamic>?)?.map((e) => e as String).toList(),
      distance_km: (json['distance_km'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$TopPlaceImplToJson(_$TopPlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'website': instance.website,
      'description': instance.description,
      'osm_id': instance.osm_id,
      'tags': instance.tags,
      'category': instance.category,
      'relevance_score': instance.relevance_score,
      'reason': instance.reason,
      'distance_km': instance.distance_km,
      'image_url': instance.imageUrl,
    };

_$PlacesCategoriesImpl _$$PlacesCategoriesImplFromJson(
  Map<String, dynamic> json,
) => _$PlacesCategoriesImpl(
  name: json['name'] as String,
  display_name: json['display_name'] as String,
  osm_key: json['osm_key'] as String,
  osm_value: json['osm_value'] as String,
);

Map<String, dynamic> _$$PlacesCategoriesImplToJson(
  _$PlacesCategoriesImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'display_name': instance.display_name,
  'osm_key': instance.osm_key,
  'osm_value': instance.osm_value,
};
