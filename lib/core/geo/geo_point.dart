import 'dart:math';

import 'package:equatable/equatable.dart';

/// A WGS84 position. The backend speaks GeoJSON, whose coordinate order is
/// `[longitude, latitude]` — the reverse of how people (and maps) say it.
/// This is the only place that knows the order.
class GeoPoint extends Equatable {
  const GeoPoint({required this.latitude, required this.longitude});

  /// `{ "type": "Point", "coordinates": [lng, lat] }`; null if malformed.
  static GeoPoint? tryFromGeoJson(Object? json) {
    if (json is! Map) return null;
    final c = json['coordinates'];
    if (c is! List || c.length < 2 || c[0] is! num || c[1] is! num) return null;
    return GeoPoint(latitude: (c[1] as num).toDouble(), longitude: (c[0] as num).toDouble());
  }

  final double latitude;
  final double longitude;

  /// Great-circle distance in kilometres.
  double distanceKmTo(GeoPoint other) {
    const earthRadiusKm = 6371.0;
    double rad(double deg) => deg * pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLng = rad(other.longitude - longitude);
    final a = pow(sin(dLat / 2), 2) + cos(rad(latitude)) * cos(rad(other.latitude)) * pow(sin(dLng / 2), 2);
    return 2 * earthRadiusKm * asin(sqrt(a));
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
