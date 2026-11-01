import 'package:baytna_worker/core/time/country_time.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/cities/domain/entities/city.dart';
import 'package:baytna_worker/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:injectable/injectable.dart';

/// Reference data every booking is read against: her country's clock and
/// wallet policy, and the names of cities and services.
class BookingContext {
  BookingContext({required this.country, required this.cities, required this.services})
    : time = CountryTime(country.timezone);

  final Country country;
  final CountryTime time;
  final List<City> cities;
  final List<Service> services;

  City? city(String id) => cities.where((c) => c.id == id).firstOrNull;

  Service? service(String id) => services.where((s) => s.id == id).firstOrNull;

  /// Straight-line km between two CITY CENTRES, or null within one city or
  /// when a centre is missing. Not her distance to the door: the pin is
  /// hidden until she accepts.
  int? kmBetweenCities(String? from, String to) {
    if (from == null || from == to) return null;
    final a = city(from)?.center;
    final b = city(to)?.center;
    return a == null || b == null ? null : a.distanceKmTo(b).round();
  }
}

/// Loads [BookingContext] once per country.
@lazySingleton
class BookingContextLoader {
  BookingContextLoader(this._countries, this._cities, this._offerings);

  final CountryRepository _countries;
  final CityRepository _cities;
  final OfferingRepository _offerings;

  final Map<String, BookingContext> _cache = {};

  Future<Result<BookingContext>> load(String countryId) async {
    final cached = _cache[countryId];
    if (cached != null) return Ok(cached);
    final (country, cities, services) = await (
      _countries.getById(countryId),
      _cities.getCities(countryId),
      _offerings.getServices(),
    ).wait;
    switch ((country, cities, services)) {
      case (Ok(value: final c), Ok(value: final ci), Ok(value: final s)):
        return Ok(_cache[countryId] = BookingContext(country: c, cities: ci, services: s));
      case (Err(:final failure), _, _) || (_, Err(:final failure), _) || (_, _, Err(:final failure)):
        return Err(failure);
    }
  }
}
