import 'package:intl/intl.dart';
import 'package:travel_app/features/places/domain/city_detail_model.dart';
// You can put this in the same file as the details screen or a separate helper file
class TravelPeriod {
  final String when; // e.g., "Spring (Mar-May)" or "October to April"
  final String why;  // e.g., "Cherry blossoms in parks and temples."

  const TravelPeriod({required this.when, required this.why});
}

List<TravelPeriod> parseBestTimeToTravel(String? rawText) {
  if (rawText == null || rawText.trim().isEmpty) {
    return []; // Return empty list if input is null or empty
  }

  // --- Initial Cleaning ---
  // Remove leading/trailing single quotes and commas, then trim whitespace
  String cleanedText = rawText.trim();
  if (cleanedText.startsWith("'")) cleanedText = cleanedText.substring(1);
  if (cleanedText.endsWith("'")) cleanedText = cleanedText.substring(0, cleanedText.length - 1);
  if (cleanedText.endsWith(",")) cleanedText = cleanedText.substring(0, cleanedText.length - 1);
  cleanedText = cleanedText.trim();

  if (cleanedText.isEmpty) {
     return [];
  }

  final List<TravelPeriod> periods = [];
  // Split primarily by ". " which seems common for separating full period descriptions
  // Also consider splitting by ".' " if quotes are used around segments
  // Regex might be more robust but complex. Let's try simple splits first.
  // We use a regex that splits on ". " OR ".' " OR just "." followed by end of string
   final List<String> potentialSegments = cleanedText.split(RegExp(r"\.\s+|\.\'$|\.$"));

  for (String segment in potentialSegments) {
    segment = segment.trim();
    if (segment.isEmpty) continue; // Skip empty segments

    // Find the first colon, which typically separates time from reason
    final colonIndex = segment.indexOf(':');

    if (colonIndex != -1) {
      String whenPart = segment.substring(0, colonIndex).trim();
      String whyPart = segment.substring(colonIndex + 1).trim();

      // Capitalize the reason part for display
      if (whyPart.isNotEmpty) {
        whyPart = whyPart[0].toUpperCase() + whyPart.substring(1);
      }

      periods.add(TravelPeriod(when: whenPart, why: whyPart));
    } else {
      // --- Handle segments without a colon ---
      // This part is heuristic. We try to guess if it's a time range or a reason.
      // If it contains common season names or month patterns, maybe it's a "when".
      // Otherwise, treat it as a general "why" or note.
      // For simplicity now, let's add it as a 'why' with a generic 'when'.
      // You could refine this with more pattern matching if needed.
      // Example check: if it contains ' to ' and month/season names, treat as 'when'
       if (segment.contains(RegExp(r'\b(January|February|March|April|May|June|July|August|September|October|November|December|Spring|Summer|Autumn|Winter)\b', caseSensitive: false)) && segment.contains(' to ')) {
         periods.add(TravelPeriod(when: segment, why: '')); // Treat as a date range
       } else if (segment.length > 5){ // Arbitrary length check to avoid adding noise
         // Treat as a general reason/note if no colon and not clearly a date range
         periods.add(TravelPeriod(when: 'Note', why: segment));
       }
    }
  }

  // If parsing resulted in nothing structured, return an empty list
  // The UI can then decide to show the raw text as a fallback.
  if (periods.isEmpty && cleanedText.isNotEmpty) {
      // Fallback: Treat the whole cleaned text as a single reason if no structure found
      // periods.add(TravelPeriod(when: "Best Time", why: cleanedText));
      // Or return empty and let UI handle raw display:
      return [];
  }


  return periods;
}

class HourlyWeatherFormatted {
  final String time; // e.g., 2:00 PM
  final String date; // e.g., April 21, 2025
  final double temperature;

  HourlyWeatherFormatted({
    required this.time,
    required this.date,
    required this.temperature,
  });
}

extension HourlyDataFormatter on HourlyData {
  List<HourlyWeatherFormatted> get formattedHourlyWeather {
    final times = time;
    final temps = temperature2m;

    if (times == null || temps == null || times.length != temps.length) {
      return [];
    }

    return List.generate(times.length, (index) {
      final dateTime = DateTime.parse(times[index]);
      final formattedTime = DateFormat.jm().format(dateTime); // e.g., 2:00 PM
      final formattedDate = DateFormat.yMMMMd().format(dateTime); // e.g., April 21, 2025

      return HourlyWeatherFormatted(
        time: formattedTime,
        date: formattedDate,
        temperature: temps[index],
      );
    });
  }
}


Map<String, List<double>> groupTempsByDay(List<String> times, List<double> temps) {
  final Map<String, List<double>> dailyTemps = {};

  for (int i = 0; i < times.length; i++) {
    final time = DateTime.parse(times[i]);
    final dayKey = '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
    dailyTemps.putIfAbsent(dayKey, () => []).add(temps[i]);
  }

  return dailyTemps;
}

Map<String, TemperatureRange> calculateDailyTempRanges(List<String> times, List<double> temps) {
  final grouped = groupTempsByDay(times, temps);
  final Map<String, TemperatureRange> ranges = {};

  grouped.forEach((day, tempsForDay) {
    final min = tempsForDay.reduce((a, b) => a < b ? a : b);
    final max = tempsForDay.reduce((a, b) => a > b ? a : b);
    ranges[day] = TemperatureRange(min, max);
  });

  return ranges;
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}