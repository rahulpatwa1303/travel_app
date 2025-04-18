import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_place_model.freezed.dart'; // Will be generated
part 'top_place_model.g.dart'; // Will be generated
@freezed
class TopPlace with _$TopPlace {
  const TopPlace._();

  const factory TopPlace({
    required int id,
    required String name,
    required Country country,
    List<String>? images,
  }) = _TopPlace;

  factory TopPlace.fromJson(Map<String, dynamic> json) =>
      _$TopPlaceFromJson(json);

  String? get imageUrl => (images != null && images!.isNotEmpty) ? images!.first : null;

  bool get usesDefaultImage {
    if (imageUrl == null || imageUrl!.isEmpty) return true;
    final url = imageUrl!.toLowerCase();
    return !(url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp'));
  }
}

@freezed
class Country with _$Country {
  const factory Country({
    required int id,
    required String name,
  }) = _Country;

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
}

@freezed
class PlacesCategory with _$PlacesCategory {
  const factory PlacesCategory({
    // `name` is the raw category string coming from the API
    required String name,
    // `displayName` is the value to be shown to users, computed automatically
    required String displayName,
  }) = _PlacesCategory;

  // Custom factory to handle both String and Map<String, dynamic> JSON inputs.
  factory PlacesCategory.fromJson(dynamic json) {
    if (json is String) {
      // Convert snake_case to title case for displayName.
      final displayName = json
          .split('_')
          .map((word) => word.isNotEmpty 
              ? '${word[0].toUpperCase()}${word.substring(1)}' 
              : '')
          .join(' ');
      return PlacesCategory(name: json, displayName: displayName);
    }  else {
      throw Exception('Invalid JSON format for PlacesCategory');
    }
  }
}
// class PlacesByCategory with _$PlacesByCategory{
//   const factory PlacesByCategory({
//       required int id,
//       required String name,
//       required double latitude,
//       required double longitude,

//           // Optional/Dynamic fields (nullable)
//       String? website,
//       String? description,
//       int? osm_id, // Keep snake_case to match JSON, JsonKey handles it
//       Map<String, dynamic>? tags, // Handles the nested tags object
//       String? category,
//       double? relevance_score, // Assuming score could be double or null
//       List<String>? reason, // Handles the list of strings
//       double? distance_km,
//   }) = _PlacesByCategory;

//   factory PlacesByCategory.fromJson(Map<String, dynamic> json) =>  _$PlacesByCategory(json);
// }
