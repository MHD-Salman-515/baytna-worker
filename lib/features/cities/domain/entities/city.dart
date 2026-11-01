import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A city within a country: her home city, her service areas, and the one
/// place fact she gets about a booking before accepting it.
class City extends Equatable {
  const City({required this.id, required this.countryId, required this.name});

  final String id;
  final String countryId;
  final LocalizedText name;

  @override
  List<Object?> get props => [id, countryId, name];
}
