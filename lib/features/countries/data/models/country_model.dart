import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:json_annotation/json_annotation.dart';

part 'country_model.g.dart';

/// Element of GET /countries `data` (shape verified against staging).
@JsonSerializable(createToJson: false)
class CountryModel {
  const CountryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phonePrefix,
    required this.currencyCode,
    required this.timezone,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => _$CountryModelFromJson(json);

  final String id;
  final String code;
  @JsonKey(fromJson: LocalizedText.fromJson)
  final LocalizedText name;
  final String phonePrefix;
  final String currencyCode;
  final String timezone;

  Country toEntity() => Country(
    id: id,
    code: code,
    name: name,
    phonePrefix: phonePrefix,
    currencyCode: currencyCode,
    timezone: timezone,
  );
}
