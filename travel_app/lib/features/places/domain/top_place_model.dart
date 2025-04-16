import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_place_model.freezed.dart'; // Will be generated
part 'top_place_model.g.dart'; // Will be generated

@freezed
class TopPlace with _$TopPlace {
  const TopPlace._();

  const factory TopPlace({
    required int id,
    required String name,
    required double latitude,
    required double longitude,

    String? website,
    String? description,
    int? osm_id,
    Map<String, dynamic>? tags,
    String? category,
    double? relevance_score,
    List<String>? reason,
    double? distance_km,

    @JsonKey(name: 'image_url') String? imageUrl, // ✅ Correct mapping here
  }) = _TopPlace;

  factory TopPlace.fromJson(Map<String, dynamic> json) =>
      _$TopPlaceFromJson(json);

  bool get usesDefaultImage {
    if (imageUrl == null || imageUrl!.isEmpty) return true;
    final url = imageUrl!.toLowerCase();
    return !(url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp'));
  }
}

@freezed
class PlacesCategories with _$PlacesCategories {
  const factory PlacesCategories({
    // Required fields
    required String name,
    required String display_name,
    required String osm_key,
    required String osm_value,
  }) = _PlacesCategories;

  factory PlacesCategories.fromJson(Map<String, dynamic> json) =>
      _$PlacesCategoriesFromJson(json);
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
