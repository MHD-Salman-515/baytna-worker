import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'offerings_event.dart';
part 'offerings_state.dart';

/// Her list of services, with the catalog that names them.
@injectable
class OfferingsBloc extends Bloc<OfferingsEvent, OfferingsState> {
  OfferingsBloc(this._repository) : super(const OfferingsLoading()) {
    on<OfferingsRequested>(_onRequested);
  }

  final OfferingRepository _repository;

  Future<void> _onRequested(OfferingsRequested event, Emitter<OfferingsState> emit) async {
    if (state is! OfferingsLoaded) emit(const OfferingsLoading());
    final (services, offerings) = await (_repository.getServices(), _repository.getOfferings()).wait;
    emit(switch ((services, offerings)) {
      (Ok(value: final s), Ok(value: final o)) => OfferingsLoaded(services: s, offerings: o),
      (Err(:final failure), _) || (_, Err(:final failure)) => OfferingsFailed(failure),
    });
  }
}
