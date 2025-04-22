// lib/features/places/domain/country_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart'; // Still needed for fromJson generation

part 'country_model.freezed.dart'; // Corresponds to THIS file
part 'country_model.g.dart';       // Corresponds to THIS file

@freezed
class Country with _$Country {
  // No @JsonSerializable needed here unless using specific options
  const factory Country({
    required int id,
    required String name,
  }) = _Country;

  // Factory constructor uses the generated function
  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
}