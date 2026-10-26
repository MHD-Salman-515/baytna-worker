import 'dart:typed_data';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/domain/document_failures.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:baytna_worker/features/documents/presentation/bloc/documents/documents_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DocumentRepository;

class _MockPicker extends Mock implements DocumentPicker;

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime(2026, 10, 26, 12);
}

final _jpeg = PickedBytes(bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]), name: 'IMG.jpg');
final _uploaded = WorkerDocument(
  id: 'new',
  type: DocumentType.nationalIdFront,
  status: DocumentStatus.pending,
  createdAt: DateTime.utc(2026, 10, 26, 9),
);
final _old = WorkerDocument(
  id: 'old',
  type: DocumentType.nationalIdFront,
  status: DocumentStatus.rejected,
  createdAt: DateTime.utc(2026, 10, 3),
);

void main() {
  late _MockRepo repo;
  late _MockPicker picker;

  setUpAll(() {
    registerFallbackValue(DocumentUpload(
      type: DocumentType.other,
      file: DocumentFile(bytes: Uint8List(1), mime: DocumentMime.pdf, name: ''),
      knownIdsBefore: const {},
    ));
  });

  setUp(() {
    repo = _MockRepo();
    picker = _MockPicker();
    when(() => repo.listDocuments()).thenAnswer((_) async => Ok([_old]));
    when(() => repo.delete(any())).thenAnswer((_) async => const Ok(null));
  });

  DocumentsBloc build() => DocumentsBloc(repo, picker, const _FixedClock());

  test('a picked non-image/PDF is rejected locally, nothing uploaded', () async {
    when(() => picker.pick(DocumentSource.gallery))
        .thenAnswer((_) async => PickedBytes(bytes: Uint8List.fromList('not an image'.codeUnits), name: 'x.jpg'));
    final bloc = build()..add(const DocumentPickRequested(DocumentType.nationalIdFront, DocumentSource.gallery));
    await Future<void>.delayed(Duration.zero);
    final draft = bloc.state.drafts[DocumentType.nationalIdFront]!;
    expect(draft.file, isNull);
    expect((draft.status as DraftError).failure, isA<DocumentTypeNotAllowed>());
    verifyNever(() => repo.upload(any(), onProgress: any(named: 'onProgress')));
    await bloc.close();
  });

  test('criminal record without an expiry date is not sent', () async {
    when(() => picker.pick(DocumentSource.file)).thenAnswer((_) async => PickedBytes(bytes: Uint8List.fromList('%PDF-1.4'.codeUnits), name: 'r.pdf'));
    final bloc = build()
      ..add(const DocumentPickRequested(DocumentType.criminalRecord, DocumentSource.file))
      ..add(const DocumentUploadRequested(DocumentType.criminalRecord));
    await Future<void>.delayed(Duration.zero);
    expect((bloc.state.drafts[DocumentType.criminalRecord]!.status as DraftError).failure, isA<DocumentExpiryRequired>());
    verifyNever(() => repo.upload(any(), onProgress: any(named: 'onProgress')));
    await bloc.close();
  });

  test('failed upload → the next tap is a RETRY of the same attempt', () async {
    when(() => picker.pick(DocumentSource.camera)).thenAnswer((_) async => _jpeg);
    final attempts = <DocumentUpload>[];
    var calls = 0;
    when(() => repo.upload(any(), onProgress: any(named: 'onProgress'))).thenAnswer((inv) async {
      attempts.add(inv.positionalArguments.first as DocumentUpload);
      return ++calls == 1 ? const Err(TimeoutFailure()) : Ok(_uploaded);
    });

    final bloc = build()..add(const DocumentPickRequested(DocumentType.nationalIdFront, DocumentSource.camera));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const DocumentUploadRequested(DocumentType.nationalIdFront));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.drafts[DocumentType.nationalIdFront]!.status, const DraftError(TimeoutFailure()));

    bloc.add(const DocumentUploadRequested(DocumentType.nationalIdFront));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(attempts.map((a) => a.isRetry), [false, true]);
    // The baseline came from a fresh server list and is kept across retries.
    expect(attempts.map((a) => a.knownIdsBefore), everyElement({'old'}));
    // Success: draft gone, new document shown, the superseded rejected copy deleted.
    expect(bloc.state.drafts, isEmpty);
    expect(bloc.state.documents.map((d) => d.id), ['new']);
    verify(() => repo.delete('old')).called(1);
    expect(bloc.state.notice, DocumentUploadedNotice(_uploaded));
    await bloc.close();
  });

  blocTest<DocumentsBloc, DocumentsState>(
    'progress is reported 0..1 while uploading',
    setUp: () {
      when(() => picker.pick(DocumentSource.camera)).thenAnswer((_) async => _jpeg);
      when(() => repo.upload(any(), onProgress: any(named: 'onProgress'))).thenAnswer((inv) async {
        final progress = inv.namedArguments[#onProgress] as void Function(int, int);
        progress(50, 100);
        await Future<void>.delayed(Duration.zero);
        return const Err(NetworkFailure());
      });
    },
    build: build,
    act: (b) async {
      b.add(const DocumentPickRequested(DocumentType.nationalIdFront, DocumentSource.camera));
      await Future<void>.delayed(Duration.zero);
      b.add(const DocumentUploadRequested(DocumentType.nationalIdFront));
    },
    wait: const Duration(milliseconds: 10),
    verify: (b) => expect(b.state.drafts[DocumentType.nationalIdFront]!.attempt!.isRetry, isTrue),
    expect: () => [
      isA<DocumentsState>().having((s) => s.drafts[DocumentType.nationalIdFront]!.status, 'status', const DraftReady()),
      isA<DocumentsState>().having((s) => s.drafts[DocumentType.nationalIdFront]!.status, 'status', const DraftUploading()),
      isA<DocumentsState>().having((s) => s.documents, 'baseline list', [_old]),
      isA<DocumentsState>().having((s) => s.drafts[DocumentType.nationalIdFront]!.status, 'status', const DraftUploading(0.5)),
      isA<DocumentsState>().having((s) => s.drafts[DocumentType.nationalIdFront]!.status, 'status', const DraftError(NetworkFailure())),
    ],
  );
}
