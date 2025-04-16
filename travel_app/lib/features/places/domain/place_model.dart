// TODO: Adjust this based on your actual API response for places
// Consider using freezed for immutability and boilerplate reduction

class Place {
  final int id;
  final String name;
  final String description;
  final String? imageURL;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURL,
  });

  bool get usesDefaultImage {
    final url = imageURL?.toLowerCase();
    return url == null || !(url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.webp'));
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url'] as String?;
    return Place(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'No description',
      imageURL: rawUrl,
    );
  }
}


// Example structure if the API returns a list under a key like 'items' or 'places'
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
    final placesList = (json['items'] as List<dynamic>?)
        ?.map((item) => Place.fromJson(item as Map<String, dynamic>))
        .toList() ?? <Place>[];

    return PlacesResponse(
      places: placesList,
      totalPages: json['pages'] as int? ?? 1,
      currentPage: json['page'] as int? ?? 1,
    );
  }
}