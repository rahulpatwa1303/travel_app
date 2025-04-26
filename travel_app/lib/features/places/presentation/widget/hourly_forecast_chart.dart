// lib/features/places/presentation/widget/hourly_forecast_chart.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:travel_app/core/constants/weather_icons.dart'; // Your weather code map
import 'package:travel_app/features/places/domain/city_detail_model.dart'; // Import needed models

class HourlyForecastChart extends StatelessWidget {
  final HourlyData? hourlyData; // Accept nullable hourly data
  final String? locationKey;   // For unique ValueKey (e.g., placeId)
  final String? lastUpdated;   // For unique ValueKey

  const HourlyForecastChart({
    super.key,
    required this.hourlyData,
    this.locationKey,
    this.lastUpdated,
  });

  // --- Data Processing Logic ---
  List<Map<String, dynamic>>? _prepareChartData() {
    final hourlyRaw = hourlyData;
    List<Map<String, dynamic>>? chartData;

    // --- Rigorous Check for valid data ---
    if (hourlyRaw?.time != null &&
        hourlyRaw?.temperature2m != null &&
        hourlyRaw?.weathercode != null &&
        hourlyRaw?.isDay != null &&
        hourlyRaw!.time!.isNotEmpty && // Check list not empty
        hourlyRaw.time!.length == hourlyRaw.temperature2m!.length &&
        hourlyRaw.time!.length == hourlyRaw.weathercode!.length &&
        hourlyRaw.time!.length == hourlyRaw.isDay!.length)
    {
        chartData = [];
        for (int i = 0; i < hourlyRaw.time!.length; i++) {
           String timeStr = hourlyRaw.time![i];
           String displayTime = timeStr.split('T').last;
           int weatherCode = hourlyRaw.weathercode![i];
           int isDay = hourlyRaw.isDay![i];

           final codeInfo = wmoWeatherCodes[weatherCode.toString()];
           String description = "Unknown";
           // --- Ensure iconUrl is non-empty or a valid placeholder ---
           String iconUrl = "http://openweathermap.org/img/wn/01d@2x.png"; // Default

           if (codeInfo != null) {
              final dayNightKey = isDay == 1 ? 'day' : 'night';
              if (codeInfo[dayNightKey] != null && codeInfo[dayNightKey] is Map) {
                 description = codeInfo[dayNightKey]['description'] as String? ?? description;
                 // Get URL, use default only if lookup fails AND returns null/empty
                 String? lookedUpUrl = codeInfo[dayNightKey]['image'] as String?;
                 if (lookedUpUrl != null && lookedUpUrl.isNotEmpty) {
                    iconUrl = lookedUpUrl;
                 }
              }
           }
           // --- End Lookup ---

           chartData.add({
              'time': displayTime,
              'temperature': hourlyRaw.temperature2m![i],
              'weathercode': weatherCode,
              'description': description,
              'iconUrl': iconUrl // Ensure this is always a valid URL string
           });
        }
    }
    return chartData;
  }



  String? _buildEchartsOption(List<Map<String, dynamic>> chartData) {
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
      double yAxisMax = (maxTemp + 6).ceilToDouble();
      double yAxisMin = (minTemp - 2).floorToDouble();

      return '''
      {
        tooltip: {
          trigger: 'axis',
          formatter: function (params) {
              var param = params[0]; var data = param.data; if (!data) return '';
              var temp = data.value; var tempStr = (typeof temp === 'number') ? temp.toFixed(1) + '°C' : '--';
              return param.axisValueLabel + '<br/>' + data.description + '<br/>' + tempStr;
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
                 return [ '{img|}', '{tempStyle|' + tempStr + '}' ].join('\\n');
              },
              rich: {
                 img: {
                    backgroundColor: { image: function(params) { return (params && params.data && params.data.iconUrl && params.data.iconUrl.length > 0) ? params.data.iconUrl : 'http://openweathermap.org/img/wn/01d@2x.png'; } }, // Added default here too
                    height: 16, width: 16, align: 'center', padding: [0, 0, 1, 0]
                 },
                 tempStyle: { color: '#333', fontSize: 9, fontWeight: 'bold', align: 'center', lineHeight: 11 }
              }
          }
        }]
      }
      ''';
  }


  @override
  Widget build(BuildContext context) {
    final preparedChartData = _prepareChartData();
    final option = (preparedChartData != null) ? _buildEchartsOption(preparedChartData) : null;

    if (option == null) {
      // Render placeholder if no data
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Hourly forecast data not available.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Render the chart section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hourly Forecast:",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 230, // Keep fixed height
          width: double.infinity,
          child: Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Echarts(
              // Use combined key for potential updates
              key: ValueKey('weather-chart-${locationKey ?? 'unknown'}-${lastUpdated ?? ''}'),
              option: option,
              captureHorizontalGestures: true,
              captureAllGestures: true,
            ),
          ),
        ),
      ],
    );
  }
}