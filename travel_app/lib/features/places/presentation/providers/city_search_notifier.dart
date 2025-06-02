// lib/features/cities/presentation/providers/city_search_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/city_api_service.dart';
import 'package:travel_app/features/places/domain/place_suggestion_model.dart';
import '../../domain/city_suggestion_model.dart'; // Adjust import path

class CitySearchNotifier extends AsyncNotifier<List<CitySearchSuggestion>> {
  Timer? _debounce;
  bool _isDisposed = false;

  @override
  Future<List<CitySearchSuggestion>> build() async {
    // Setup cleanup logic
    ref.onDispose(() {
      _isDisposed = true;
      _debounce?.cancel();
    });

    return [];
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      _debounce?.cancel();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncValue.loading();
      try {
        final suggestions =
            await ref.read(cityRepositoryProvider).searchCities(query);
        if (!_isDisposed) {
          state = AsyncValue.data(suggestions);
        }
      } catch (e, s) {
        if (!_isDisposed) {
          state = AsyncValue.error(e, s);
        }
        print("Error in CitySearchNotifier: $e");
      }
    });
  }

  void clearSuggestions() {
    state = const AsyncValue.data([]);
    _debounce?.cancel();
  }
}

class PlaceSearchNotifier extends AsyncNotifier<List<PlaceSearchSuggestion>> {
  Timer? _debounce;
  bool _isDisposed = false;

  @override
  Future<List<PlaceSearchSuggestion>> build() async {
    // Setup cleanup logic
    ref.onDispose(() {
      _isDisposed = true;
      _debounce?.cancel();
    });

    return [];
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      _debounce?.cancel();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncValue.loading();
      try {
        final suggestions =
            await ref.read(cityRepositoryProvider).searchPlaces(query);
        if (!_isDisposed) {
          state = AsyncValue.data(suggestions);
        }
      } catch (e, s) {
        if (!_isDisposed) {
          state = AsyncValue.error(e, s);
        }
        print("Error in CitySearchNotifier: $e");
      }
    });
  }

  void clearSuggestions() {
    state = const AsyncValue.data([]);
    _debounce?.cancel();
  }
}




final citySearchProvider =
    AsyncNotifierProvider<CitySearchNotifier, List<CitySearchSuggestion>>(
  CitySearchNotifier.new,
);


final placeSearchProvider =
    AsyncNotifierProvider<PlaceSearchNotifier, List<PlaceSearchSuggestion>>(
  PlaceSearchNotifier.new,
);