import 'package:dio/dio.dart';
import 'dart:async'; // For Future.delayed
import 'dart:developer' as developer;

class WikimediaApiService {
  final Dio _dio;

  static const String _baseUrl = "https://commons.wikimedia.org/w/";
  static const String _wikidataApiBaseUrl = "https://www.wikidata.org/w/"; // Added for Wikidata API
  static const String _userAgent = 'YourAppName/1.0 (YourContactURL or email)'; // PLEASE UPDATE
  // Optional delay between search and get-URL calls (milliseconds)
  static const int _apiCallDelayMs = 100; // e.g., 100ms

  WikimediaApiService()
      : _dio = Dio(BaseOptions(
          // Use default base URL for Commons API initially
          // We'll override for Wikidata calls
          headers: {
            'User-Agent': _userAgent,
          },
          connectTimeout: const Duration(seconds: 12), // Increased slightly
          receiveTimeout: const Duration(seconds: 12), // Increased slightly
        ));

  // --- Helper: Get Filename from Wikidata ID ---
  Future<String?> _getFilenameFromWikidata(String wikidataId) async {
    developer.log('Fetching filename from Wikidata ID: $wikidataId', name: 'WikimediaApiService');
    if (wikidataId.isEmpty) return null;

    try {
      final response = await _dio.get(
        'api.php',
        // options: Options(baseUrl: _wikidataApiBaseUrl), // Use Wikidata base URL
        queryParameters: {
          'action': 'wbgetclaims',
          'format': 'json',
          'entity': wikidataId,
          'property': 'P18', // P18 is the 'image' property
          'utf8': 1,
        },
      );

       if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
           final claimsData = response.data['claims'] as Map<String, dynamic>?;
           final p18Claims = claimsData?['P18'] as List<dynamic>?;

           if (p18Claims != null && p18Claims.isNotEmpty) {
               final firstClaim = p18Claims[0] as Map<String, dynamic>?;
               final mainSnak = firstClaim?['mainsnak'] as Map<String, dynamic>?;
               final dataValue = mainSnak?['datavalue'] as Map<String, dynamic>?;
               final filename = dataValue?['value'] as String?;
               if (filename != null) {
                   developer.log('Found filename via Wikidata: $filename', name: 'WikimediaApiService');
                   return filename.replaceAll(' ', '_');
               }
           }
       }
       developer.log('No P18 filename found for Wikidata ID: $wikidataId', name: 'WikimediaApiService');
       return null;
    } on DioException catch (e) {
       developer.log('DioError fetching Wikidata filename: ${e.message}', error: e, name: 'WikimediaApiService');
       return null;
    } catch (e) {
       developer.log('Error fetching Wikidata filename: $e', error: e, name: 'WikimediaApiService');
       return null;
    }
  }


  // --- Helper: Search Commons (returns List of filenames) ---
  Future<List<String>> _searchCommonsForFilenames(String query) async {
    developer.log('Searching Wikimedia Commons for: "$query"', name: 'WikimediaApiService');
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'api.php',
        //  options: Options(baseUrl: _baseUrl), // Use Commons base URL
        queryParameters: {
          'action': 'query',
          'format': 'json',
          'list': 'search',
          'srsearch': query,
          'srnamespace': 6, // File namespace
          'srlimit': 3, // Fetch top 3 results
          'utf8': 1,
        },
      );

      List<String> filenames = [];
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final queryData = response.data['query'] as Map<String, dynamic>?;
        final searchResults = queryData?['search'] as List<dynamic>?;

        if (searchResults != null && searchResults.isNotEmpty) {
          for (var result in searchResults) {
             if (result is Map<String, dynamic>) {
                final title = result['title'] as String?;
                 if (title != null && title.startsWith('File:')) {
                    final filename = title.substring(5).replaceAll(' ', '_');
                    filenames.add(filename);
                 }
             }
          }
        }
      }
       developer.log('Found ${filenames.length} potential filenames for query "$query": $filenames', name: 'WikimediaApiService');
      return filenames;
    } on DioException catch (e) {
      developer.log('DioError searching Commons: ${e.message}', error: e, name: 'WikimediaApiService');
      return []; // Return empty list on error
    } catch (e) {
       developer.log('Error searching Commons: $e', error: e, name: 'WikimediaApiService');
       return [];
    }
  }

  // --- Helper: Get Direct URL (remains largely the same) ---
  Future<String?> _getDirectImageUrl(String filename) async {
     developer.log('Attempting to get direct URL for filename: $filename', name: 'WikimediaApiService');
     if (filename.isEmpty) return null;
     if (filename.toLowerCase().startsWith("file:")) {
        filename = filename.substring(5);
     }

    // Optional slight delay before this call
    if (_apiCallDelayMs > 0) {
       await Future.delayed(Duration(milliseconds: _apiCallDelayMs));
    }

    try {
      final response = await _dio.get(
        'api.php',
        //  options: Options(baseUrl: _baseUrl), // Use Commons base URL
        queryParameters: {
          'action': 'query',
          'format': 'json',
          'titles': 'File:$filename',
          'prop': 'imageinfo',
          'iiprop': 'url',
          'utf8': 1,
        },
      );

       if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final queryData = response.data['query'] as Map<String, dynamic>?;
          final pagesData = queryData?['pages'] as Map<String, dynamic>?;

          if (pagesData != null && pagesData.isNotEmpty) {
             final pageEntry = pagesData.entries.firstWhere(
                (entry) => entry.key != "-1" && entry.value is Map,
                orElse: () => const MapEntry("", null),
             );

             if (pageEntry.value != null) {
                 final pageInfo = pageEntry.value as Map<String, dynamic>;
                 final imageInfoList = pageInfo['imageinfo'] as List<dynamic>?;
                 if (imageInfoList != null && imageInfoList.isNotEmpty) {
                    final imageInfo = imageInfoList[0] as Map<String, dynamic>?;
                    final imageUrl = imageInfo?['url'] as String?;
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                       developer.log('Success! Found direct URL: $imageUrl', name: 'WikimediaApiService');
                       return imageUrl;
                    } else {
                       developer.log('ImageInfo found but URL is null or empty for $filename', name: 'WikimediaApiService');
                    }
                 } else {
                     developer.log('No imageinfo list found for $filename', name: 'WikimediaApiService');
                 }
             } else {
                  developer.log('No valid page entry found for $filename', name: 'WikimediaApiService');
             }
          } else {
              developer.log('Pages data is null or empty for $filename', name: 'WikimediaApiService');
          }
      } else {
          developer.log('Non-200 status or invalid data for $filename. Status: ${response.statusCode}', name: 'WikimediaApiService');
      }
      return null; // Explicitly return null if no URL found
    } on DioException catch (e) {
       developer.log('DioError getting direct URL for $filename: ${e.message}', error: e, name: 'WikimediaApiService');
       return null;
    } catch (e) {
       developer.log('Error getting direct URL for $filename: $e', error: e, name: 'WikimediaApiService');
       return null;
    }
  }

  // --- PUBLIC METHOD: Enhanced fetch logic ---
  Future<String?> fetchImageUrlForPoi(String poiName, Map<String, dynamic>? tags) async {
    String? imageUrl;
    List<String> filenamesToTry = [];
    final String wikidataId = tags?['wikidata'] as String? ?? '';
    final String city = tags?['addr:city'] as String? ?? '';
    final String altName = tags?['alt_name'] as String? ?? ''; // Check for alt_name

    developer.log('Starting image fetch for "$poiName", City: "$city", Wikidata: "$wikidataId", AltName: "$altName"', name: 'WikimediaApiService');


    // --- Strategy 1: Try Wikidata First (most reliable if available) ---
    if (wikidataId.isNotEmpty) {
        final String? wikidataFilename = await _getFilenameFromWikidata(wikidataId);
        if (wikidataFilename != null) {
            filenamesToTry.add(wikidataFilename);
            // Attempt to get URL immediately for this high-confidence filename
            imageUrl = await _getDirectImageUrl(wikidataFilename);
            if (imageUrl != null) {
                developer.log('Image URL found via Wikidata ID.', name: 'WikimediaApiService');
                return imageUrl; // Success! Return early.
            } else {
                developer.log('Got filename from Wikidata but failed to get URL. Will proceed to search.', name: 'WikimediaApiService');
                // Clear filenamesToTry if we want search to be completely independent
                // filenamesToTry.clear();
                // Or keep it to potentially retry getting URL later (less efficient)
            }
        }
    }


    // --- Strategy 2: Search Commons with different queries ---
    if (imageUrl == null) { // Only search if Wikidata didn't yield a final URL
        // Query 1: Name + City
        List<String> searchResults = [];
        if (city.isNotEmpty) {
            searchResults = await _searchCommonsForFilenames('$poiName $city');
            filenamesToTry.addAll(searchResults);
        }

        // Query 2: Just Name (if Name+City yielded nothing or if no city)
        if (searchResults.isEmpty) {
             searchResults = await _searchCommonsForFilenames(poiName);
             filenamesToTry.addAll(searchResults);
        }

         // Query 3: Alt Name + City (if Alt Name exists and previous searches yielded nothing)
         if (filenamesToTry.isEmpty && altName.isNotEmpty && city.isNotEmpty) {
             searchResults = await _searchCommonsForFilenames('$altName $city');
             filenamesToTry.addAll(searchResults);
         }

         // Query 4: Just Alt Name (if Alt Name exists and previous searches yielded nothing)
          if (filenamesToTry.isEmpty && altName.isNotEmpty) {
             searchResults = await _searchCommonsForFilenames(altName);
             filenamesToTry.addAll(searchResults);
         }
    }

    // Remove duplicates just in case
    filenamesToTry = filenamesToTry.toSet().toList();
    developer.log('Total unique filenames to try getting URLs for: $filenamesToTry', name: 'WikimediaApiService');


    // --- Strategy 3: Try getting Direct URL for found filenames ---
    if (imageUrl == null && filenamesToTry.isNotEmpty) {
        for (String filename in filenamesToTry) {
            imageUrl = await _getDirectImageUrl(filename);
            if (imageUrl != null) {
                 developer.log('Image URL found via Commons search for filename: $filename', name: 'WikimediaApiService');
                break; // Stop as soon as we find a working URL
            } else {
                 developer.log('Failed to get direct URL for filename: $filename', name: 'WikimediaApiService');
            }
        }
    }

    // --- Final Result ---
    if (imageUrl == null) {
       developer.log('Failed to find any image URL for "$poiName"', name: 'WikimediaApiService');
    }
    return imageUrl;
  }
}