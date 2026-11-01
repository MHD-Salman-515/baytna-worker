import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/availability/domain/entities/availability.dart';

abstract interface class AvailabilityRepository {
  Future<Result<AvailabilitySchedule>> load();

  /// Replaces the whole schedule (PUT).
  Future<Result<AvailabilitySchedule>> save(AvailabilitySchedule schedule);
}
