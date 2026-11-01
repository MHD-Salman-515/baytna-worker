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

  @override
  List<Object?> get props => [latitude, longitude];
}
