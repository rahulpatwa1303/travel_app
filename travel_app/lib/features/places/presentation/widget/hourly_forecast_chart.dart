// lib/features/places/presentation/widget/hourly_forecast_chart.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:intl/intl.dart'; // For formatting time
import 'package:travel_app/core/constants/weather_icons.dart'; // Your weather code map
import 'package:travel_app/features/places/domain/city_detail_model.dart'; // Import needed models

class HourlyForecastChart extends StatelessWidget {
  // Accept the whole forecast object now
  final WeatherForecast? weatherForecast;
  final String? locationKey;   // For unique ValueKey (e.g., placeId)
  final String? lastUpdated;   // For unique ValueKey

  const HourlyForecastChart({
    super.key,
    required this.weatherForecast, // Changed from hourlyData
    this.locationKey,
    this.lastUpdated,
  });

  // --- Access nested data ---
  // Convenience getters
  HourlyData? get hourlyData => weatherForecast?.hourly;
  ForecastCurrentData? get currentData => weatherForecast?.currentData;
  ForecastCurrentUnits? get currentUnits => weatherForecast?.currentUnits;

  // --- Data Processing Logic (For the chart - uses hourlyData getter) ---
    List<Map<String, dynamic>>? _prepareChartData() {
    final hourlyRaw = hourlyData; // Use the getter

    // --- More Robust Check ---
    // 1. Check if hourly data itself exists
    if (hourlyRaw == null) {
      print("Debug: hourlyRaw is null.");
      return null;
    }

    // 2. Check if all *required* lists for the chart exist
    final timeList = hourlyRaw.time;
    final tempList = hourlyRaw.temperature2m;
    final codeList = hourlyRaw.weathercode;
    final isDayList = hourlyRaw.isDay;

    if (timeList == null || tempList == null || codeList == null || isDayList == null) {
      print("Debug: One or more required hourly lists are null.");
      print("  timeList: ${timeList == null ? 'null' : 'exists'}");
      print("  tempList: ${tempList == null ? 'null' : 'exists'}");
      print("  codeList: ${codeList == null ? 'null' : 'exists'}");
      print("  isDayList: ${isDayList == null ? 'null' : 'exists'}");
      return null; // Cannot proceed if any essential list is missing
    }

    // 3. Check if the time list is empty (no data points)
    if (timeList.isEmpty) {
       print("Debug: timeList is empty.");
       return null; // No data to chart
    }

    // 4. Check for length consistency (now safe because lists are not null)
    final int expectedLength = timeList.length;
    if (tempList.length != expectedLength ||
        codeList.length != expectedLength ||
        isDayList.length != expectedLength)
    {
      print("Debug: Hourly data lists have inconsistent lengths.");
      print("  timeList length: ${timeList.length}");
      print("  tempList length: ${tempList.length}");
      print("  codeList length: ${codeList.length}");
      print("  isDayList length: ${isDayList.length}");
      return null; // Data inconsistency
    }
    // --- End Robust Check ---

    // If we reach here, all required lists exist, are non-empty (time), and have the same length.
    print("Debug: Preparing chart data. Found ${expectedLength} hourly entries.");
    List<Map<String, dynamic>> chartData = [];
    try { // Add try-catch for safety during iteration, although checks should prevent errors
      for (int i = 0; i < expectedLength; i++) {
        String timeStr = timeList[i]; // No '!' needed now
        String displayTime = timeStr.split('T').last; // Keep HH:mm format
        double temperature = tempList[i]; // No '!' needed
        int weatherCode = codeList[i]; // No '!' needed
        int isDay = isDayList[i]; // No '!' needed

        // --- Icon/Description Lookup (Remains the same) ---
        final codeInfo = wmoWeatherCodes[weatherCode.toString()];
        String description = "Unknown";
        String iconUrl = "http://openweathermap.org/img/wn/01d@2x.png"; // Default

        if (codeInfo != null) {
          final dayNightKey = isDay == 1 ? 'day' : 'night';
          final Map<String, dynamic>? dayNightInfo = codeInfo[dayNightKey] as Map<String, dynamic>?; // Safer cast
          if (dayNightInfo != null) {
              description = dayNightInfo['description'] as String? ?? description;
              String? lookedUpUrl = dayNightInfo['image'] as String?;
              if (lookedUpUrl != null && lookedUpUrl.isNotEmpty) {
                iconUrl = lookedUpUrl;
              }
          }
        }
        // --- End Lookup ---

        chartData.add({
          'time': displayTime,
          'temperature': temperature, // Use the double value
          'weathercode': weatherCode,
          'description': description,
          'iconUrl': iconUrl
        });
      }
    } catch (e, stackTrace) {
        print("Error during chart data processing loop: $e");
        print(stackTrace);
        return null; // Return null if an error occurs during processing
    }

    return chartData;
  }
  // --- Chart Option Builder (Remains the same) ---
  String? _buildEchartsOption(List<Map<String, dynamic>> chartData) {
     // ... (Keep the existing Echarts option string generation logic) ...
      if (chartData.isEmpty) return null;

      final List<String> xAxisData = chartData.map((e) => e['time'] as String).toList();
      final List<Map<String, dynamic>> seriesData = chartData.map((e) => {
         'value': e['temperature'],
         'time': e['time'],
         'description': e['description'],
         'iconUrl': e['iconUrl'],
      }).toList();

      double maxTemp = chartData.map((e) => e['temperature'] as num).reduce(max).toDouble();
      double minTemp = chartData.map((e) => e['temperature'] as num).reduce(min).toDouble();
      // Adjust Y-axis slightly if needed, ensure min is not >= max
      double yAxisMax = (maxTemp + 6).ceilToDouble();
      double yAxisMin = (minTemp - 2).floorToDouble();
      if (yAxisMin >= yAxisMax) { yAxisMin = yAxisMax - 1; } // Basic safety check

      return '''
      {
        tooltip: {
          trigger: 'axis',
  formatter: function (params) {
    var param = params[0]; var data = param.data; if (!data) return '';
    var temp = data.value; var tempStr = (typeof temp === 'number') ? temp.toFixed(1) + '°C' : '--';
    var iconTag = '<img src="' + data.iconUrl + '" style="width:20px; height:20px; vertical-align: middle;" /> ';
    return param.axisValueLabel + '<br/>' + iconTag + data.description + '<br/>' + tempStr;
}
        },
        grid: { left: '8%', right: '8%', bottom: '15%', top: '28%', containLabel: false },
        xAxis: {
          type: 'category', boundaryGap: false, show: true, position: 'top',
          data: ${jsonEncode(xAxisData)},
          axisLabel: { interval: 0, rotate: 0, hideOverlap: true, fontSize: 9, color: '#666' },
          axisTick: { length: 3, alignWithLabel: true },
          axisLine: { show: true, lineStyle: { color: '#eee' } }
        },
        yAxis: { type: 'value', show: false, scale: true, max: $yAxisMax, min: $yAxisMin },
        dataZoom: [
          { type: 'inside', xAxisIndex: 0, filterMode: 'filter', zoomLock: true, start: 0, end: 30 },
          { type: 'slider', show: false, xAxisIndex: 0 }
        ],
        series: [{
          name: 'Temperature', type: 'line', smooth: true, symbol: 'circle', symbolSize: 4, sampling: 'lttb',
          data: ${jsonEncode(seriesData)},
          lineStyle: { width: 2 },
          areaStyle: { opacity: 0.1 },
          label: {
              show: true, position: 'top', distance: 8,
              formatter: function(params) {
                 var data = params.data; if (!data) return '';
                 var temp = data.value; var tempStr = (typeof temp === 'number') ? temp.toFixed(0) + '°' : '--';
                 // Ensure iconUrl exists and is valid before trying to use it
                 return [  '{tempStyle|' + tempStr + '}' ].join('\\n');
              },
              rich: {
                 // NOTE: Directly embedding the URL string in the formatter's rich text definition
                 // is simpler than using the backgroundColor.image function approach.
                 // The function approach might have context issues within the ECharts JS environment.
                 img: {
                    // backgroundColor: { image: function(params) { return params.value; } }, // Simpler to pass URL directly
                    height: 16, width: 16, align: 'center', padding: [0, 0, 1, 0]
                 },
                 
                 tempStyle: { color: '#333', fontSize: 9, fontWeight: 'bold', align: 'center', lineHeight: 11 }
              }
          }
        }]
      }
      ''';
  }

  // --- Helper to build the Current Weather Row ---
  Widget _buildCurrentWeatherInfo(BuildContext context) {
    final current = currentData; // Use getter
    final units = currentUnits; // Use getter

    if (current == null) {
      return const SizedBox.shrink(); // Don't show anything if no current data
    }

    // --- Get Weather Icon/Description ---
    String description = "Unknown";
    String iconUrl = "http://openweathermap.org/img/wn/01d@2x.png"; // Default
    int isDay = current.isDay ?? 1; // Default to day if null

    if (current.weathercode != null) {
      final codeInfo = wmoWeatherCodes[current.weathercode.toString()];
      if (codeInfo != null) {
        final dayNightKey = isDay == 1 ? 'day' : 'night';
         if (codeInfo[dayNightKey] != null && codeInfo[dayNightKey] is Map) {
           description = codeInfo[dayNightKey]['description'] as String? ?? description;
           String? lookedUpUrl = codeInfo[dayNightKey]['image'] as String?;
           if (lookedUpUrl != null && lookedUpUrl.isNotEmpty) {
              iconUrl = lookedUpUrl;
           }
        }
      }
    }
    // --- End Icon/Description ---

    // Format Temperature
    String tempStr = current.temperature2m != null
        ? '${current.temperature2m!.toStringAsFixed(0)}${units?.temperature2m ?? '°'}'
        : '--';

    // Format Wind (optional)
    String windStr = '';
    if (current.windspeed10m != null) {
      windStr = 'Wind: ${current.windspeed10m!.toStringAsFixed(1)}${units?.windspeed10m ?? 'km/h'}';
      if (current.winddirection10m != null) {
         // Could add direction (e.g., N, NE, E) based on degrees later
         windStr += ' (${current.winddirection10m}°)';
      }
    }

    // Format Time (optional - show when current data was recorded)
    String timeStr = '';
     if (current.time != null) {
        try {
           final dateTime = DateTime.parse(current.time!);
           // Adjust for timezone if needed, or assume local if API provides local time
           timeStr = ' (@ ${DateFormat.Hm().format(dateTime)})'; // Format as HH:mm
        } catch (e) { /* Ignore parsing error */ }
     }


    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Add space below current weather
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weather Icon
          Image.network(
            iconUrl,
            height: 40,
            width: 40,
            errorBuilder: (ctx, err, st) => const Icon(Icons.thermostat, size: 40), // Fallback icon
          ),
          const SizedBox(width: 12),
          // Weather Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$tempStr, $description$timeStr',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                 if (windStr.isNotEmpty) ...[
                   const SizedBox(height: 2),
                   Text(
                     windStr,
                     style: Theme.of(context).textTheme.bodySmall,
                   ),
                 ]
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // --- Prepare data for the chart ---
    final preparedChartData = _prepareChartData();
    final chartOption = (preparedChartData != null && preparedChartData.isNotEmpty)
        ? _buildEchartsOption(preparedChartData)
        : null;

    // --- Check if we have *any* data to show (either current or hourly) ---
    if (currentData == null && chartOption == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text("Weather data not available.")),
      );
    }

    // --- Render the combined section ---
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Display Current Weather ---
        Text(
          "Current Conditions", // Changed title
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildCurrentWeatherInfo(context), // Display the current weather row

        // --- Display Hourly Forecast Chart ---
        if (chartOption != null) ...[
          Text(
            "Hourly Forecast", // Changed title
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 230, // Keep fixed height for the chart
            width: double.infinity,
            child: Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Echarts(
                key: ValueKey('weather-chart-${locationKey ?? 'unknown'}-${lastUpdated ?? ''}'),
                option: chartOption,
                captureHorizontalGestures: true,
                captureAllGestures: true,
              ),
            ),
          ),
        ] else ...[
          // Optional: Message if only current weather is shown but no hourly
           if (currentData != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                   "Hourly forecast detail not available.",
                   style: Theme.of(context).textTheme.bodySmall,
                 ),
              ),
        ],
      ],
    );
  }
}