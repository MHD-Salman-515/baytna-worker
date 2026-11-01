import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/offerings/data/datasources/offering_remote_data_source.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/offering_failures.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OfferingRepository)
class OfferingRepositoryImpl implements OfferingRepository {
  OfferingRepositoryImpl(this._remote);

  final OfferingRemoteDataSource _remote;

  @override
  Future<Result<List<Service>>> getServices() => guard(_remote.services);

  @override
  Future<Result<List<PricingRule>>> getPricingRules(String countryId) =>
      guard(() => _remote.pricingRules(countryId));

  @override
  Future<Result<List<Offering>>> getOfferings() => guard(_remote.offerings);

  @override
  Future<Result<Offering>> create({required String serviceId, required OfferingPrice price}) async =>
      _mapped(await guard(() => _remote.create(serviceId, price)));

  @override
  Future<Result<Offering>> update(String id, {OfferingPrice? price, bool? isActive}) async =>
      _mapped(await guard(() => _remote.update(id, price: price, isActive: isActive)));

  @override
  Future<Result<void>> delete(String id) => guard(() => _remote.delete(id));

  static Result<Offering> _mapped(Result<Offering> result) => switch (result) {
    Err(failure: ServerFailure(statusCode: 409, :final debugMessage)) => Err(OfferingAlreadyExists(debugMessage)),
    Err(failure: final ValidationFailure f) => Err(_validation(f)),
    _ => result,
  };

  /// Observed: "price must be between 10000 and 50000 (inclusive)" (also
  /// "rate must be…") and "BY_SIZE is not an allowed pricing type for COOKING".
  static Failure _validation(ValidationFailure f) {
    final message = f.messages.join(' ');
    final range = RegExp(r'between (\d+) and (\d+)').firstMatch(message);
    if (range != null) {
      return PriceOutOfRange(int.parse(range[1]!), int.parse(range[2]!), f.debugMessage);
    }
    if (message.contains('not an allowed pricing type')) return PricingTypeNotAllowed(f.debugMessage);
    return f;
  }
}
