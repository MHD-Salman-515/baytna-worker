import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A city within a country. Used for the worker's home city and her service
/// areas. (The backend also sends a GeoJSON `center`; added when maps need it.)
class City extends Equatable {
  const City({required this.id, required this.countryId, required this.name});

  final String id;
  final String countryId;
  final LocalizedText name;

  @override
  List<Object?> get props => [id, countryId, name];
}
