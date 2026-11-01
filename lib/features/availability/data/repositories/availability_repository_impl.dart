import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/availability/data/datasources/availability_remote_data_source.dart';
import 'package:baytna_worker/features/availability/domain/entities/availability.dart';
import 'package:baytna_worker/features/availability/domain/repositories/availability_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AvailabilityRepository)
class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._remote);

  final AvailabilityRemoteDataSource _remote;

  @override
  Future<Result<AvailabilitySchedule>> load() => guard(_remote.load);

  @override
  Future<Result<AvailabilitySchedule>> save(AvailabilitySchedule schedule) =>
      guard(() => _remote.save(schedule));
}
