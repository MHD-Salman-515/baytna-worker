import 'package:baytna_worker/core/geo/geo_point.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A city within a country. [center] is the only geography available before
/// she accepts a booking (the customer's pin is hidden until then).
class City extends Equatable {
  const City({required this.id, required this.countryId, required this.name, this.center});

  final String id;
  final String countryId;
  final LocalizedText name;
  final GeoPoint? center;

  @override
  List<Object?> get props => [id, countryId, name, center];
}
