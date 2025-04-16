import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/places_repository.dart';
import '../../domain/top_place_model.dart';

part 'places_provider.g.dart'; // <--- Ensure this line exists

// ... other existing providers ...

@riverpod // <--- Ensure the annotation exists
Future<List<TopPlace>> topPlaces(TopPlacesRef ref) async {
  print("topPlaces provider executing...");
  final placesRepository = ref.watch(placesRepositoryProvider);
  final topPlacesData = await placesRepository.getTopPlaces();
  print("topPlaces provider received ${topPlacesData.length} items.");
  return topPlacesData;
}
// Function that retrieves data
@riverpod
Future<List<PlacesCategories>> placesCategories(AutoDisposeFutureProviderRef<List<PlacesCategories>> ref) async {
  final placesRepository = ref.watch(placesRepositoryProvider);  // Adjust your repository provider if needed.
  final categoriesData = await placesRepository.getCategories();  // Ensure `getCategories` is a function in your repository
  return categoriesData;
}
