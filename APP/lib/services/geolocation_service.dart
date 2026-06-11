import 'package:geolocator/geolocator.dart';

/// Resultado de uma tentativa de obter a localização.
class GeoResult {
  final Position? position;
  final GeoError? error;
  const GeoResult.success(this.position) : error = null;
  const GeoResult.failure(this.error) : position = null;
  bool get ok => position != null;
}

enum GeoError { serviceDisabled, denied, deniedForever, unknown }

/// Wrapper sobre `geolocator` com tratamento de permissões.
class GeolocationService {
  GeolocationService._();
  static final GeolocationService instance = GeolocationService._();

  Future<GeoResult> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const GeoResult.failure(GeoError.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const GeoResult.failure(GeoError.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const GeoResult.failure(GeoError.deniedForever);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return GeoResult.success(position);
    } catch (_) {
      return const GeoResult.failure(GeoError.unknown);
    }
  }

  /// Calcula distância em metros entre dois pontos.
  double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Formata uma distância em metros para texto amigável ("800 m" / "1.2 km").
  String formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
