// lib/core/networking/lat_lng_model.dart

import 'package:meta/meta.dart'; // For @immutable

@immutable // Indicates the class and its subclasses are immutable
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  // Override equality (==) operator
  // Two LatLng objects are equal if their latitude and longitude are equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Same instance
    return other is LatLng &&
           other.latitude == latitude &&
           other.longitude == longitude;
  }

  // Override hashCode
  // It's important that if two objects are equal (==), they must have the same hashCode.
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  // Optional: toString for easier debugging
  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';
}