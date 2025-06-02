// lib/features/places/domain/place_suggestion_model.dart (or your chosen path)
class PlaceSearchSuggestion {
  final int id;
  final String name;
  final double? latitude; // Make nullable as per your example (though it has a value)
  final double? longitude; // Make nullable
  final String? category;
  final String? address; // address can be null
  final int? cityId; // city_id can be associated
  final List<String> images; // Assuming images is always a list, might be empty

  PlaceSearchSuggestion({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.category,
    this.address,
    this.cityId,
    required this.images,
  });

  factory PlaceSearchSuggestion.fromJson(Map<String, dynamic> json) {
    // Parse images, ensuring it's a list of strings
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = List<String>.from(
        (json['images'] as List).whereType<String>() // Filter out non-strings
      );
    }

    return PlaceSearchSuggestion(
      id: json['id'] as int,
      name: json['name'] as String,
      // Use safe casting for doubles, allowing null
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] as String?,
      address: json['address'] as String?,
      cityId: json['city_id'] as int?,
      images: parsedImages,
    );
  }

  @override
  String toString() {
    // A more informative string representation if needed for debugging or simple display
    return '$name ${category != null ? "($category)" : ""}'.trim();
  }

  // Helper to get a display subtitle, prioritizing address then category
  String get displaySubtitle {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (category != null && category!.isNotEmpty) {
      // Optional: Prettify category (e.g., "natural_wonder" -> "Natural Wonder")
      return category!.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
    return '';
  }
}