import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/features/cities/domain/entities/city.dart';
import 'package:json_annotation/json_annotation.dart';

part 'city_model.g.dart';

/// Element of GET /cities?countryId= `data` (shape verified against staging):
/// `{ countryId, name: {ar, en}, center: {type: "Point", coordinates}, isActive, id, … }`.
@JsonSerializable(createToJson: false)
class CityModel {
  const CityModel({required this.id, required this.countryId, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) => _$CityModelFromJson(json);

  final String id;
  final String countryId;
  @JsonKey(fromJson: LocalizedText.fromJson)
  final LocalizedText name;

  City toEntity() => City(id: id, countryId: countryId, name: name);
}
