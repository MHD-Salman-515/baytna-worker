// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryModel _$CountryModelFromJson(Map<String, dynamic> json) => CountryModel(
  id: json['id'] as String,
  code: json['code'] as String,
  name: LocalizedText.fromJson(json['name']),
  phonePrefix: json['phonePrefix'] as String,
  currencyCode: json['currencyCode'] as String,
  timezone: json['timezone'] as String,
);
