// lib/features/places/domain/place_model.dart

// lib/features/places/domain/place_model.dart (or your Place model file)
// import 'package:html_unescape/html_unescape.dart'; // If you need HTML unescaping

class Place {
  final int id;
  final String name; // Will store cleaned name
  final double? latitude;
  final double? longitude;
  final String? category;
  final String? address; // This might be the top-level address if present
  final int? cityId;
  final List<String> images;
  final String? website;
  final String? description; // Make nullable
  final String? phone;
  final String? openingHoursRaw; // Store the raw opening hours string
  final List<String> cuisineTypes; // Parsed from attributes.cuisine
  final Map<String, dynamic> attributes; // Store the whole attributes map

  Place({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.category,
    this.address,
    this.cityId,
    required this.images,
    this.website,
    this.description,
    this.phone,
    this.openingHoursRaw,
    this.cuisineTypes = const [],
    required this.attributes,
  });

  String? get primaryImageUrl => images.isNotEmpty ? images.first : null;

  bool get usesDefaultImage {
    final url = primaryImageUrl?.toLowerCase();
    return url == null || url.isEmpty || !(url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp'));
  }

  // Helper to get a formatted address from attributes
  String get formattedAddress {
    final parts = [
      attributes['addr:housenumber'] as String?,
      attributes['addr:street'] as String?,
      attributes['addr:city'] as String?,
      attributes['addr:postcode'] as String?,
    ];
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }

  // Helper to get a displayable category name
  String get displayCategory {
    if (category == null || category!.isEmpty) return "Place";
    // Simple formatting, can be expanded
    return category!.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    String rawName = json['name'] as String? ?? 'Unnamed Place';
    String cleanedName = rawName.trim();
    if (cleanedName.length >= 2 && cleanedName.startsWith('"') && cleanedName.endsWith('"')) {
      cleanedName = cleanedName.substring(1, cleanedName.length - 1);
    }
    cleanedName = cleanedName.replaceAll(RegExp(r'\s+'), ' ');
    // final unescape = HtmlUnescape();
    // cleanedName = unescape.convert(cleanedName);

    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = List<String>.from((json['images'] as List).whereType<String>());
    }

    Map<String, dynamic> attrs = json['attributes'] is Map<String, dynamic>
        ? json['attributes'] as Map<String, dynamic>
        : {}; // Default to empty map

    List<String> cuisines = [];
    if (attrs['cuisine'] is String) {
      cuisines = (attrs['cuisine'] as String).split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }


    return Place(
      id: json['id'] as int,
      name: cleanedName,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] as String?,
      address: json['address'] as String?, // Top-level address
      cityId: json['city_id'] as int?,
      images: parsedImages,
      website: json['website'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      openingHoursRaw: json['opening_hours'] as String?,
      attributes: attrs,
      cuisineTypes: cuisines,
    );
  }
}

// Your PlacesResponse model should remain the same as it uses Place.fromJson internally.
class PlacesResponse {
  final List<Place> places;
  final int totalPages;
  final int currentPage;

  PlacesResponse({
    required this.places,
    required this.totalPages,
    required this.currentPage,
  });

  factory PlacesResponse.fromJson(Map<String, dynamic> json) {
    // This factory assumes the API response for a paginated list
    // is an OBJECT with 'items', 'pages', 'page' keys.
    // If your /api/v1/places endpoint returns a direct LIST,
    // then this PlacesResponse.fromJson isn't directly usable for that,
    // and you'd parse the list directly as shown in previous answers.

    final List<Place> placesList;
    if (json['items'] != null && json['items'] is List) {
      placesList =
          (json['items'] as List<dynamic>)
              .map((item) => Place.fromJson(item as Map<String, dynamic>))
              .toList();
    } else if (json['places'] != null && json['places'] is List) {
      // Alternative key for places list
      placesList =
          (json['places'] as List<dynamic>)
              .map((item) => Place.fromJson(item as Map<String, dynamic>))
              .toList();
    } else {
      placesList = <Place>[]; // Default to empty if no suitable key found
      print(
        "Warning: 'items' or 'places' key not found or not a list in PlacesResponse JSON.",
      );
    }

    return PlacesResponse(
      places: placesList,
      totalPages: json['pages'] as int? ?? 1, // Or json['total_pages']
      currentPage: json['page'] as int? ?? 1, // Or json['current_page']
    );
  }
}
