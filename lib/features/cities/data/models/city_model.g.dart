// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityModel _$CityModelFromJson(Map<String, dynamic> json) => CityModel(
  id: json['id'] as String,
  countryId: json['countryId'] as String,
  name: LocalizedText.fromJson(json['name']),
  center: GeoPoint.tryFromGeoJson(json['center']),
);
