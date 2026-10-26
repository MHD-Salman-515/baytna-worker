import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/domain/document_file_validator.dart';
import 'package:baytna_worker/features/documents/domain/document_requirements.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'documents_event.dart';
part 'documents_state.dart';

/// Her documents and, per type, a local DRAFT: the file she picked (in
/// memory only) waiting to be uploaded, uploading, or failed.
///
/// Uploads never duplicate. The first attempt records which documents exist
/// (from a fresh list); every later attempt for the same draft is a retry,
/// and the repository checks whether an earlier attempt already landed
/// before sending the file again.
@injectable
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc(this._repository, this._picker, this._clock) : super(const DocumentsState()) {
    on<DocumentsStarted>(_onStarted);
    on<DocumentPickRequested>(_onPickRequested);
    on<DocumentExpiryChanged>(_onExpiryChanged);
    on<DocumentDraftDiscarded>((e, emit) => emit(state.withoutDraft(e.type)));
    on<DocumentUploadRequested>(_onUploadRequested);
    on<_DocumentUploadProgressed>(_onProgressed);
  }

  final DocumentRepository _repository;
  final DocumentPicker _picker;
  final Clock _clock;

  Future<void> _onStarted(DocumentsStarted event, Emitter<DocumentsState> emit) async {
    if (state.load is! DocumentsLoaded) emit(state.copyWith(load: const DocumentsLoading()));
    switch (await _repository.listDocuments()) {
      case Ok(:final value):
        emit(state.copyWith(documents: value, load: const DocumentsLoaded()));
      case Err(:final failure):
        // Keep showing a list we already have; only a first load fails hard.
        if (state.load is! DocumentsLoaded) emit(state.copyWith(load: DocumentsLoadFailed(failure)));
    }
  }

  Future<void> _onPickRequested(DocumentPickRequested event, Emitter<DocumentsState> emit) async {
    if (state.drafts[event.type]?.status is DraftUploading) return;
    final PickedBytes? picked;
    try {
      picked = await _picker.pick(event.source);
    } on PlatformException catch (e) {
      // e.g. camera permission denied.
      return emit(state.withDraft(event.type, DocumentDraft(status: DraftError(UnknownFailure(e.code)))));
    }
    if (picked == null) return; // cancelled: keep whatever was there

    final previous = state.drafts[event.type];
    emit(switch (DocumentFileValidator.validate(picked)) {
      // A new file starts a new upload: no previous attempt applies to it.
      Ok(value: final file) => state.withDraft(
        event.type,
        DocumentDraft(file: file, expiresAt: previous?.expiresAt),
      ),
      Err(:final failure) => state.withDraft(
        event.type,
        DocumentDraft(expiresAt: previous?.expiresAt, status: DraftError(failure)),
      ),
    });
  }

  void _onExpiryChanged(DocumentExpiryChanged event, Emitter<DocumentsState> emit) {
    final draft = state.drafts[event.type] ?? const DocumentDraft();
    if (draft.status is DraftUploading) return;
    emit(
      state.withDraft(
        event.type,
        // A different expiry is a different upload.
        DocumentDraft(file: draft.file, expiresAt: event.expiresAt),
      ),
    );
  }

  Future<void> _onUploadRequested(DocumentUploadRequested event, Emitter<DocumentsState> emit) async {
    final type = event.type;
    final draft = state.drafts[type];
    final file = draft?.file;
    if (draft == null || file == null || draft.status is DraftUploading) return;

    if (type.requiresExpiry) {
      final invalid = DocumentFileValidator.validateExpiry(draft.expiresAt, _clock.now());
      if (invalid != null) return emit(state.withDraft(type, draft.copyWith(status: DraftError(invalid))));
    }

    emit(state.withDraft(type, draft.copyWith(status: const DraftUploading())));

    var attempt = draft.attempt;
    if (attempt == null) {
      // Baseline from the SERVER, not from what this screen last saw.
      switch (await _repository.listDocuments()) {
        case Ok(:final value):
          emit(state.copyWith(documents: value));
          attempt = DocumentUpload(
            type: type,
            file: file,
            expiresAt: draft.expiresAt,
            knownIdsBefore: {for (final d in value) d.id},
          );
        case Err(:final failure):
          return emit(state.withDraft(type, draft.copyWith(status: DraftError(failure))));
      }
    }

    final result = await _repository.upload(
      attempt,
      onProgress: (sent, total) => add(_DocumentUploadProgressed(type, sent, total)),
    );

    switch (result) {
      case Ok(value: final uploaded):
        emit(
          state
              .withoutDraft(type)
              .copyWith(
                documents: [uploaded, ...state.documents.where((d) => d.id != uploaded.id)],
                notice: DocumentUploadedNotice(uploaded),
              ),
        );
        await _deleteSuperseded(uploaded, emit);
      case Err(:final failure):
        // Whatever happened, the next tap is a RETRY of this same attempt.
        emit(state.withDraft(type, draft.copyWith(status: DraftError(failure), attempt: () => attempt!.asRetry())));
    }
  }

  void _onProgressed(_DocumentUploadProgressed event, Emitter<DocumentsState> emit) {
    final draft = state.drafts[event.type];
    if (draft == null || draft.status is! DraftUploading) return;
    final progress = event.total > 0 ? (event.sent / event.total).clamp(0.0, 1.0) : null;
    emit(state.withDraft(event.type, draft.copyWith(status: DraftUploading(progress))));
  }

  /// After a replacement lands, remove older uploads of that type so a stale
  /// (e.g. rejected) copy can't sit next to it. Best effort: the newest
  /// document is the one that counts anyway.
  Future<void> _deleteSuperseded(WorkerDocument kept, Emitter<DocumentsState> emit) async {
    final stale = DocumentRequirements.superseded(state.documents, kept);
    for (final doc in stale) {
      final result = await _repository.delete(doc.id);
      if (result case Err(:final failure)) {
        debugPrint('[documents] could not delete superseded ${doc.id}: $failure');
        continue;
      }
      emit(state.copyWith(documents: state.documents.where((d) => d.id != doc.id).toList()));
    }
  }
}
