import 'package:dio/dio.dart';
import 'package:exam_calendar/domain/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:exam_calendar/.env.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
    String language = 'en',
    String key = googleApiKey,
  }) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': mode,
      'language': language,
      'key': key,
    });

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
