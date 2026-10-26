import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:baytna_worker/features/worker/domain/worker_failures.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'status_event.dart';
part 'status_state.dart';

/// The status screen's own data: her documents (for the checklist and the
/// per-document badges) and the submit action. Her profile — the status
/// itself — lives in the app-wide WorkerBloc; results that change it are
/// handed over by the screen (see StatusSubmitSucceeded).
@injectable
class StatusBloc extends Bloc<StatusEvent, StatusState> {
  StatusBloc(this._workers, this._documents) : super(const StatusState()) {
    on<StatusDocumentsRequested>(_onDocumentsRequested);
    on<StatusSubmitRequested>(_onSubmitRequested);
  }

  final WorkerRepository _workers;
  final DocumentRepository _documents;

  Future<void> _onDocumentsRequested(StatusDocumentsRequested event, Emitter<StatusState> emit) async {
    if (state.documents is! StatusDocumentsLoaded) emit(state.copyWith(documents: const StatusDocumentsLoading()));
    switch (await _documents.listDocuments()) {
      case Ok(:final value):
        emit(state.copyWith(documents: StatusDocumentsLoaded(value)));
      case Err(:final failure):
        // A background refresh failing keeps the list she can already see.
        if (state.documents is! StatusDocumentsLoaded) {
          emit(state.copyWith(documents: StatusDocumentsFailed(failure)));
        }
    }
  }

  Future<void> _onSubmitRequested(StatusSubmitRequested event, Emitter<StatusState> emit) async {
    if (state.submit is StatusSubmitting) return;
    emit(state.copyWith(submit: const StatusSubmitting()));
    switch (await _workers.submitForReview()) {
      case Ok(:final value):
        emit(state.copyWith(submit: StatusSubmitSucceeded(value)));
      case Err(failure: InvalidStatusTransition()):
        // Already submitted (double tap, another device): just catch up.
        emit(state.copyWith(submit: const StatusSubmitConflict()));
      case Err(:final failure):
        emit(state.copyWith(submit: StatusSubmitFailed(failure)));
        // "Missing documents" usually means our list is stale (or one expired).
        if (failure is MissingRequiredDocuments) add(const StatusDocumentsRequested());
    }
  }
}
