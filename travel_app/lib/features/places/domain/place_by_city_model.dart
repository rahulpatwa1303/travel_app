import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_by_city_model.freezed.dart';
part 'place_by_city_model.g.dart';


@freezed
class PlaceByCity with _$PlaceByCity {
   const factory PlaceByCity({
     required int id,
     required String name,
     // Make latitude and longitude required if they always exist
     required double latitude,
     required double longitude,
     // Category seems required
     required String category,
     // Address is nullable based on the JSON
     String? address,
     // city_id seems required
     @JsonKey(name: 'city_id') required int cityId,
     // Assuming images is a list, potentially dynamic or specific type
     // Default to empty list, make nullable if it can be absent
     @JsonKey(name: 'images') @Default([]) List<dynamic> images,
   }) = _PlaceByCity;

   // Private constructor for custom getters if needed later
   const PlaceByCity._();

   // Corrected factory constructor
   factory PlaceByCity.fromJson(Map<String, dynamic> json) => _$PlaceByCityFromJson(json);

   // Example helper for image URL (adapt if 'images' has structure)
   String? get primaryImageUrl {
      if (images.isNotEmpty) {
        var firstImage = images.first;
        if (firstImage is Map<String, dynamic> && firstImage.containsKey('url')) {
          return firstImage['url'] as String?;
        } else if (firstImage is String) {
          return firstImage; // If it's just a list of URLs
        }
      }
      return null;
    }

    // Determine if default image needed based on parsed image URL
    bool get usesDefaultImage => primaryImageUrl == null || primaryImageUrl!.isEmpty;
}