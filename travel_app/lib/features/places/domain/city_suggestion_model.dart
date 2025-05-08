// lib/features/cities/domain/city_suggestion_model.dart
class CitySearchSuggestion {
  final int id;
  final String name;
  final String countryName; // Changed from countryCode
  final List<String>? images; // Optional: if you want to use images

  CitySearchSuggestion({
    required this.id,
    required this.name,
    required this.countryName,
    this.images,
  });

  factory CitySearchSuggestion.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for the nested country object
    String countryNameValue = "N/A"; // Default if country info is missing or malformed
    if (json['country'] != null && json['country'] is Map<String, dynamic>) {
      final countryMap = json['country'] as Map<String, dynamic>;
      if (countryMap['name'] != null && countryMap['name'] is String) {
        countryNameValue = countryMap['name'] as String;
      }
    }

    List<String>? imageList;
    if (json['images'] != null && json['images'] is List) {
      // Ensure all items in the list are strings
      imageList = List<String>.from(
        (json['images'] as List).whereType<String>()
      );
    }


    return CitySearchSuggestion(
      id: json['id'] as int,
      name: json['name'] as String,
      countryName: countryNameValue,
      images: imageList,
    );
  }

  @override
  String toString() => '$name, $countryName'; // More informative for display
}