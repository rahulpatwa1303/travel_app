enum SearchType {
  city,
  place,
}

// Helper extension for display name (optional but nice)
extension SearchTypeExtension on SearchType {
  String get displayName {
    switch (this) {
      case SearchType.city:
        return 'City';
      case SearchType.place:
        return 'Place';
    }
  }
}