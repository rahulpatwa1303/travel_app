// lib/features/places/presentation/screens/city_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/networking/lat_lng_model.dart';
import 'package:travel_app/features/places/data/repositories/cities_time.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
// Import helpers and providers
import 'package:travel_app/features/places/presentation/controllers/helper.dart';
import 'package:travel_app/features/places/presentation/providers/places_provider.dart';
import 'package:travel_app/features/places/presentation/widget/best_time_to_travel.dart';
import 'package:travel_app/widget/sun_position_arc.dart';

// Widget buildCitySunDetailsContent(
//   BuildContext context,
//   CityDetail details,
//   List<TravelPeriod> parsedTravelPeriods,
//   String? rawBestTimeText,
// ) {
//   Widget bestTimeSection = buildBestTimeSection(
//     context,
//     parsedTravelPeriods,
//     rawBestTimeText,
//   );

//   // --- Extract Sunrise/Sunset Times (Example) ---
//   // IMPORTANT: Your DailyData time strings might need parsing!
//   // Assuming daily.time[0] is today, daily.sunrise[0] and daily.sunset[0] are ISO strings
//   DateTime? sunriseTime;
//   DateTime? sunsetTime;
//   final dailyData = details.weatherForecast?.daily;
//   if (dailyData?.sunrise != null && dailyData!.sunrise!.isNotEmpty) {
//     sunriseTime = DateTime.tryParse(dailyData.sunrise!.first);
//   }
//   if (dailyData?.sunset != null && dailyData!.sunset!.isNotEmpty) {
//     sunsetTime = DateTime.tryParse(dailyData.sunset!.first);
//   }
//   // --- End Time Extraction ---

//   // Get current time (can be passed in or fetched)
//   final DateTime now = DateTime.now(); // Use actual current time

//   final lat = details.weatherForecast?.latitude;
//   final lng = details.weatherForecast?.longitude;

//   if (lat == null || lng == null) {
//     return Text('Location not available');
//   }
//   final DateFormat localTimeFormatter = DateFormat.jm();
//   final DateFormat dateTimeParser = DateFormat(
//     "yyyy-MM-dd HH:mm",
//   ); // EXAMPLE PARSER - ADJUST TO YOUR API's RETURN FORMAT
//   late final Future currentDateTime = getCurrentTimeFromLatLng(lat, lng);

//   return FutureBuilder(
//     future: currentDateTime,
//     builder: (context, snapshot) {
//       if(snapshot.hasData){

//       }
//       else if (snapshot.connectionState == ConnectionState.waiting) {
//         return const CircularProgressIndicator();
//       } else if (snapshot.hasError) {
//         return Text('Error: ${snapshot.error}');
//       } else if (!snapshot.hasData) {
//         return const Text('No data received');
//       }

//       final String localTimeString = snapshot.data!;
//       DateTime? localTimeDateTime; // Keep it nullable initially
//       String displayLocalTime = "N/A";

//       try {
//         // *** IMPORTANT: ADJUST PARSING FORMAT HERE ***
//         // Example 1: If API returns ISO 8601 string (e.g., "2023-10-27T15:30:00Z" or "2023-10-27T10:30:00-05:00")
//         localTimeDateTime = DateTime.parse(localTimeString).toLocal();

//         // Example 2: If API returns "YYYY-MM-DD HH:MM" (adjust format string)
//         // localTimeDateTime = dateTimeParser.parse(localTimeString, true).toLocal();

//         // If parsing successful, format for display
//         displayLocalTime = localTimeFormatter.format(localTimeDateTime);
//       } catch (e) {
//         print(
//           "Error parsing fetched local time string '$localTimeString': $e",
//         );
//         displayLocalTime = localTimeString; // Show raw string as fallback
//       }
//       // --- End Time Processing ---

//       String sunMessage = "";
//       if (localTimeDateTime != null &&
//           sunriseTime != null &&
//           sunsetTime != null) {
//         final Duration timeUntilSunrise = sunriseTime.difference(
//           localTimeDateTime,
//         );
//         final Duration timeUntilSunset = sunsetTime.difference(
//           localTimeDateTime,
//         );

//         // Check if sunrise is upcoming (within next 90 mins)
//         if (timeUntilSunrise > Duration.zero &&
//             timeUntilSunrise <= const Duration(minutes: 90)) {
//           sunMessage = "Sunrise soon! Don't miss it.";
//         }
//         // Check if sunset is upcoming (within next 90 mins)
//         else if (timeUntilSunset > Duration.zero &&
//             timeUntilSunset <= const Duration(minutes: 90)) {
//           sunMessage = "Sunset approaching! Find a good spot.";
//         }
//       }

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 10,
//             ), // Space below time text
//             child: Text(
//               "Current time is $displayLocalTime",
//               style: Theme.of(
//                 context,
//               ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
//             ),
//           ),
//           if (sunMessage.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(
//                 right: 12,
//                 left: 12,
//                 bottom: 10,
//               ), // Space below message
//               child: Text(
//                 sunMessage,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context).primaryColor,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           // --- Add Sun Arc Widget ---
//           if (sunriseTime != null && sunsetTime != null)
//             Center(
//               // Center the Arc widget horizontally
//               child: SunPositionArc(
//                 sunrise: sunriseTime,
//                 sunset: sunsetTime,
//                 currentTime: localTimeDateTime,
//                 size: 180, // Adjust size
//                 arcColor: Colors.orange.shade300,
//                 sunColor: Colors.yellow.shade700,
//                 timeColor: Colors.black54,
//                 strokeWidth: 2,
//                 sunRadius: 8,
//               ),
//             )
//           else
//             const Text(
//               "Sunrise/sunset data unavailable.",
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),

//           // --- End Sun Arc ---
//           const SizedBox(height: 24), // Space after sun arc
//         ],
//       );
//     },
//   );
// }

// --- UPDATED Helper for Sun Details Section ---
Widget buildCitySunDetailsContent(
  BuildContext context,
  WidgetRef ref,
  CityDetail details,
) {
  // Get sunrise/sunset from details
  DateTime? sunriseTime;
  DateTime? sunsetTime;
  final dailyData = details.weatherForecast?.daily;
  try {
    if (dailyData?.sunrise != null && dailyData!.sunrise!.isNotEmpty)
      sunriseTime = DateTime.parse(dailyData.sunrise!.first).toLocal();
    if (dailyData?.sunset != null && dailyData!.sunset!.isNotEmpty)
      sunsetTime = DateTime.parse(dailyData.sunset!.first).toLocal();
  } catch (e) {
    print("Error parsing sunrise/sunset: $e");
  }

  // Get Lat/Lng for provider arg
  final lat = details.weatherForecast?.latitude;
  final lng = details.weatherForecast?.longitude;
  if (lat == null || lng == null) {
    return const Padding(
      padding: const EdgeInsets.only(right: 12, left: 12, bottom: 10),
    );
  }

  // --- Watch the Time Provider ---
  final AsyncValue<CachedLocalTime> localTimeAsync = ref.watch(
    currentLocalTimeProvider(LatLng(lat, lng)),
  );
  final DateFormat displayTimeFormatter =
      DateFormat.jm(); // Formatter for display time
  final DateFormat expiryTimeFormatter =
      DateFormat.Hm(); // Formatter for expiry time

  return localTimeAsync.when(
    data: (cachedTimeData) {
      // Process time string
      DateTime? localTimeDateTime;
      String displayLocalTime = "N/A";
      try {
        localTimeDateTime =
            DateTime.parse(
              cachedTimeData.timeString,
            ).toLocal(); // ADJUST PARSING
        displayLocalTime = displayTimeFormatter.format(localTimeDateTime);
      } catch (e) {
        displayLocalTime = "Error";
      }

      // Calculate sun message
      String sunMessage = "";
      if (localTimeDateTime != null &&
          sunriseTime != null &&
          sunsetTime != null) {
        final Duration timeUntilSunrise = sunriseTime.difference(
          localTimeDateTime,
        );
        final Duration timeUntilSunset = sunsetTime.difference(
          localTimeDateTime,
        );

        // Check if sunrise is upcoming (within next 90 mins)
        if (timeUntilSunrise > Duration.zero &&
            timeUntilSunrise <= const Duration(minutes: 90)) {
          sunMessage = "Sunrise soon! Don't miss it.";
        }
        // Check if sunset is upcoming (within next 90 mins)
        else if (timeUntilSunset > Duration.zero &&
            timeUntilSunset <= const Duration(minutes: 90)) {
          sunMessage = "Sunset approaching! Find a good spot.";
        }
      }

      // Calculate refresh info
      final String expiryFormatted = expiryTimeFormatter.format(
        cachedTimeData.expiresAt.toLocal(),
      );
      final bool isRefreshingSoon =
          cachedTimeData.expiresAt.difference(DateTime.now()) <
          const Duration(minutes: 1);

      // --- Build Sun Details UI ---
      return Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // Time + Refresh Info
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text("Current time is $displayLocalTime" /* Style */),
                ),
                const SizedBox(width: 8),
                Text(
                  isRefreshingSoon
                      ? "(Refreshing soon...)"
                      : "(Refreshes ~${expiryFormatted})" /* Style */,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sunMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 12, bottom: 10),
              ),
        
            // Sun Arc Widget
            if (sunriseTime != null &&
                sunsetTime != null &&
                localTimeDateTime != null)
              Center(
                child: SunPositionArc(
                  sunrise: sunriseTime,
                  sunset: sunsetTime,
                  currentTime: localTimeDateTime /*...*/,
                ),
              )
            else
              const Padding(
                padding: const EdgeInsets.only(right: 12, left: 12, bottom: 10),
              ),
            // Removed extra SizedBox here
          ],
        ),
      );
    },
    // --- Loading: Show previous data + indicator ---
    loading: () {
      // Get previous cached value if available
      final previousCached =
          ref.read(currentLocalTimeProvider(LatLng(lat, lng))).valueOrNull;
      DateTime? previousTimeDateTime;
      String displayPreviousTime = "Loading time...";
      if (previousCached != null) {
        try {
          previousTimeDateTime =
              DateTime.parse(previousCached.timeString).toLocal();
          displayPreviousTime = displayTimeFormatter.format(
            previousTimeDateTime,
          );
        } catch (_) {
          displayPreviousTime = "(loading)";
        }
      }

      // Display previous data + subtle loading indicator
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Current time is $displayPreviousTime" /* Style */),
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Still show arc based on previous time if available
          if (sunriseTime != null &&
              sunsetTime != null &&
              previousTimeDateTime != null)
            Center(
              child: SunPositionArc(
                sunrise: sunriseTime,
                sunset: sunsetTime,
                currentTime: previousTimeDateTime,
              ),
            )
          else
            const Padding(
              padding: const EdgeInsets.only(right: 12, left: 12, bottom: 10),
            ),
        ],
      );
    },
    // --- Error state ---
    error: (err, stack) {
      print(
        "Error in currentLocalTimeProvider: $err \n$stack",
      ); // Log full error
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Error loading time: $err",
            style: TextStyle(color: Colors.orange[800]),
          ),
        ),
      );
    },
  ); // End localTimeAsync.when
} // End _buildCitySunDetailsContent
