// lib/features/places/presentation/screens/city_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/networking/lat_lng_model.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/presentation/providers/places_provider.dart';
import 'package:travel_app/widget/sun_position_arc.dart';

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

      final dailyData = details.weatherForecast?.daily;
      final int? timeZoneOffsetSeconds =
          details?.weatherForecast?.utcOffsetSeconds;


      // Check if we have all necessary data
      if (dailyData?.sunrise?.isNotEmpty == true &&
          dailyData?.sunset?.isNotEmpty == true &&
          timeZoneOffsetSeconds != null) {
        String sunriseStr = dailyData!.sunrise!.first;
        String sunsetStr = dailyData!.sunset!.first;

        DateTime? sunriseTimeUtc;
        DateTime? sunsetTimeUtc;
        DateTime nowUtc = DateTime.now().toUtc(); // Get current time in UTC

        try {
          // Parse the date/time part (ignoring any potential offset IN the string, as ours don't have it)
          // DateTime.parse assumes local time if no offset is present in the string.
          DateTime parsedSunriseLocal = DateTime.parse(sunriseStr);
          DateTime parsedSunsetLocal = DateTime.parse(sunsetStr);

          // --- CRITICAL: Convert parsed times to UTC using the API's offset ---
          // We assume the parsed time represents the wall-clock time *at the location*.
          // To get the equivalent UTC instant, we SUBTRACT the location's offset from UTC.
          sunriseTimeUtc = DateTime.utc(
            parsedSunriseLocal.year,
            parsedSunriseLocal.month,
            parsedSunriseLocal.day,
            parsedSunriseLocal.hour,
            parsedSunriseLocal.minute,
            parsedSunriseLocal.second,
            parsedSunriseLocal.millisecond, // include milliseconds if needed
          ).subtract(Duration(seconds: timeZoneOffsetSeconds));

          sunsetTimeUtc = DateTime.utc(
            parsedSunsetLocal.year,
            parsedSunsetLocal.month,
            parsedSunsetLocal.day,
            parsedSunsetLocal.hour,
            parsedSunsetLocal.minute,
            parsedSunsetLocal.second,
            parsedSunsetLocal.millisecond, // include milliseconds if needed
          ).subtract(Duration(seconds: timeZoneOffsetSeconds));
          // --- End UTC Conversion ---

          if (sunriseTimeUtc != null && sunsetTimeUtc != null) {
            // Perform comparisons using UTC times
            final Duration timeUntilSunrise = sunriseTimeUtc.difference(nowUtc);
            final Duration timeUntilSunset = sunsetTimeUtc.difference(nowUtc);

            // Check if sunrise is upcoming (within next 90 mins AND hasn't passed)
            if (timeUntilSunrise.isNegative ==
                    false && // Check if it's zero or positive (not past)
                timeUntilSunrise <= const Duration(minutes: 90)) {
              final mins = timeUntilSunrise.inMinutes;
              if (mins <= 1) {
                sunMessage =
                    "Sunrise happening now. Hope you have a nice view!";
              } else {
                // Subtle message:
                sunMessage =
                    "Heads up: Sunrise in $mins minutes. Consider finding a nice spot to watch.";
              }
            }
            // Check if sunset is upcoming (within next 90 mins AND hasn't passed)
            else if (timeUntilSunset.isNegative ==
                    false && // Check if it's zero or positive (not past)
                timeUntilSunset <= const Duration(minutes: 90)) {
              final mins = timeUntilSunset.inMinutes;
              if (mins <= 1) {
                sunMessage = "Sunset happening now. Enjoy the colours!";
              } else {
                // Subtle message:
                sunMessage =
                    "Catch the sunset in $mins minutes. Find a clear view if you can.";
              }
            }
            // Optional: Log if it's daytime or nighttime for context
            else if (nowUtc.isAfter(sunriseTimeUtc) &&
                nowUtc.isBefore(sunsetTimeUtc)) {
              print("Debug: Currently daytime.");
            } else {
              print("Debug: Currently nighttime, or outside check window.");
            }
          } else {
            print(
              "Debug: Failed to establish valid UTC sunrise/sunset DateTime objects.",
            );
          }
        } catch (e, stackTrace) {
          print('Error parsing or processing sunrise/sunset times: $e');
          print(stackTrace);
          // Optionally set an error message: sunMessage = "Error getting sun times";
        }
      } else {
        print(
          "Debug: Missing required data for sun time calculation (daily data, sunrise/sunset lists, or UTC offset).",
        );
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
                //don't need to show the user this
                // Text(
                //   isRefreshingSoon
                //       ? "(Refreshing soon...)"
                //       : "(Refreshes ~${expiryFormatted})" /* Style */,
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 12, bottom: 10),
              child: Text(sunMessage,style: TextStyle(fontStyle: FontStyle.italic,color: Colors.blueAccent),),
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
