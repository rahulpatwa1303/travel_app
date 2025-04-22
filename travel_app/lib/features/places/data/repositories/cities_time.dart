import 'package:dio/dio.dart';

Future<String> getCurrentTimeFromLatLng(double lat, double lng) async {
  final dio = Dio();
  const apiKey = 'HG3T8JYNWZ4D'; // Replace with your TimeZoneDB API key

  final url = 'http://api.timezonedb.com/v2.1/get-time-zone';
  final queryParams = {
    'key': apiKey,
    'format': 'json',
    'by': 'position',
    'lat': lat,
    'lng': lng,
  };

  try {
    final response = await dio.get(url, queryParameters: queryParams);
    final data = response.data;

    if (data['status'] == 'OK') {
      return data['formatted']; // Local time as string
    } else {
      throw Exception(data['message']);
    }
  } catch (e) {
    throw Exception('Failed to get time: $e');
  }
}