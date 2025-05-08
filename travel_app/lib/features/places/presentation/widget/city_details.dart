// lib/features/places/presentation/screens/city_details_screen.dart

import 'package:flutter/material.dart';
import 'package:travel_app/core/constants/weather_icons.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
// Import helpers and providers
import 'package:travel_app/features/places/presentation/controllers/helper.dart';
import 'package:travel_app/features/places/presentation/widget/best_time_to_travel.dart';

Widget buildCityDetailsContent(
  BuildContext context,
  CityDetail details,
  List<TravelPeriod> parsedTravelPeriods,
  String? rawBestTimeText,
) {
  Widget bestTimeSection = buildBestTimeSection(
    context,
    parsedTravelPeriods,
    rawBestTimeText,
  );
  // Remove 'formattedData' if not used elsewhere
  // final formattedData = details.weatherForecast?.hourly?.formattedHourlyWeather;
  final hourlyRaw = details.weatherForecast?.hourly;

  // --- Data Extraction for Chart ---
  List<Map<String, dynamic>>? chartData;
  if (hourlyRaw?.time != null &&
      hourlyRaw?.temperature2m != null &&
      hourlyRaw?.weathercode != null && // Check weathercode
      hourlyRaw?.isDay != null && // Check isDay
      hourlyRaw?.time!.length == hourlyRaw?.temperature2m!.length &&
      hourlyRaw?.time!.length == hourlyRaw?.weathercode!.length &&
      hourlyRaw?.time!.length == hourlyRaw?.isDay!.length) {
    chartData = [];
    for (int i = 0; i < hourlyRaw!.time!.length; i++) {
      String timeStr = hourlyRaw.time![i];
      String displayTime = timeStr.split('T').last; // "HH:MM"
      int weatherCode = hourlyRaw.weathercode![i];
      int isDay = hourlyRaw.isDay![i];

      // --- Look up Description and Icon ---
      final codeInfo = wmoWeatherCodes[weatherCode.toString()];
      String description = "Unknown";
      String iconUrl =
          "http://openweathermap.org/img/wn/01d@2x.png"; // Sensible default

      if (codeInfo != null) {
        final dayNightKey = isDay == 1 ? 'day' : 'night';
        if (codeInfo[dayNightKey] != null && codeInfo[dayNightKey] is Map) {
          description =
              codeInfo[dayNightKey]['description'] as String? ?? description;
          iconUrl = codeInfo[dayNightKey]['image'] as String? ?? iconUrl;
        }
      }
      // --- End Lookup ---

      chartData.add({
        'time': displayTime,
        'temperature': hourlyRaw.temperature2m![i],
        'weathercode': weatherCode,
        'description': description, // Include description
        'iconUrl': iconUrl, // Include correct icon URL
      });
    }
  }
  // --- End Data Extraction ---

  // --- Main return Column ---
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Display Description, Best Time, Famous For (as before)
      if (details.description != null && details.description!.isNotEmpty) ...[
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overview",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(details.description!, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 16),
                bestTimeSection, // Display best time section
                if (details.famousFor != null &&
                    details.famousFor!.isNotEmpty) ...[
                  Text(
                    "Famous For:",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(details.famousFor!),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],

      // --- End Chart ---
    ],
  );
}
