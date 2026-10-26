import 'dart:typed_data';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/data/datasources/document_remote_data_source.dart';
import 'package:baytna_worker/features/documents/data/repositories/document_repository_impl.dart';
import 'package:baytna_worker/features/documents/domain/document_failures.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_harness.dart';
import '../../helpers/fake_backend.dart';

Map<String, Object?> _doc(String id, String type, {String createdAt = '2026-10-26T08:00:00.000Z'}) => {
  'id': id,
  'type': type,
  'status': 'PENDING',
  'mimeType': 'image/jpeg',
  'sizeBytes': 10,
  'checksum': 'x',
  'rejectionReason': null,
  'expiresAt': null,
  'createdAt': createdAt,
};

final _jpeg = DocumentFile(bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2]), mime: DocumentMime.jpeg, name: 'IMG_123.jpg');

/// Stores uploads like staging (no dedupe), with a switch to "lose" the
/// response after the upload was stored.
class _DocsBackend {
  final List<Map<String, Object?>> stored = [_doc('old', 'NATIONAL_ID_BACK')];
  bool dropResponse = false;
  final List<FormData> uploads = [];

  Map<String, Handler> get routes => {
    'GET /api/v1/workers/me/documents': (_, _) async => FakeBackend.ok(stored.reversed.toList()),
    'POST /api/v1/workers/me/documents': (o, body) async {
      final form = body! as FormData;
      uploads.add(form);
      final type = form.fields.firstWhere((f) => f.key == 'type').value;
      final doc = _doc('new${stored.length}', type, createdAt: '2026-10-26T09:00:00.000Z');
      stored.add(doc);
      if (dropResponse) {
        throw DioException.connectionError(requestOptions: o, reason: 'connection reset');
      }
      return (201, {'success': true, 'data': doc});
    },
  };
}

void main() {
  late _DocsBackend server;
  late DocumentRepositoryImpl repo;

  setUp(() {
    server = _DocsBackend();
    final h = ApiHarness(server.routes, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
    repo = DocumentRepositoryImpl(DocumentRemoteDataSource(h.api));
  });

  DocumentUpload upload({bool retry = false}) {
    final u = DocumentUpload(type: DocumentType.nationalIdFront, file: _jpeg, knownIdsBefore: const {'old'});
    return retry ? u.asRetry() : u;
  }

  test('uploads type + file under a neutral filename (never her original name)', () async {
    final result = await repo.upload(upload());
    expect(result, isA<Ok<WorkerDocument>>());
    final form = server.uploads.single;
    expect(Map.fromEntries(form.fields), {'type': 'NATIONAL_ID_FRONT'});
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'national_id_front.jpg');
    expect(form.files.single.value.contentType.toString(), 'image/jpeg');
  });

  test('response lost after the upload landed → adopts it, does not report failure', () async {
    server.dropResponse = true;
    final result = await repo.upload(upload());
    expect(result, isA<Ok<WorkerDocument>>().having((r) => r.value.id, 'id', 'new1'));
    expect(server.uploads, hasLength(1));
  });

  test('RETRY after an unknown outcome never uploads twice', () async {
    server.dropResponse = true;
    // Simulate: the first attempt landed but even the follow-up check failed,
    // so the user saw an error and taps retry.
    server.stored.add(_doc('landed', 'NATIONAL_ID_FRONT', createdAt: '2026-10-26T09:00:00.000Z'));
    final result = await repo.upload(upload(retry: true));
    expect(result, isA<Ok<WorkerDocument>>().having((r) => r.value.id, 'id', 'landed'));
    expect(server.uploads, isEmpty);
  });

  test('retry when nothing landed uploads exactly once', () async {
    final result = await repo.upload(upload(retry: true));
    expect(result, isA<Ok<WorkerDocument>>());
    expect(server.uploads, hasLength(1));
  });

  test('documents of OTHER types or from before the attempt are never adopted', () async {
    server
      ..stored.add(_doc('other-type', 'CRIMINAL_RECORD'))
      ..dropResponse = true;
    // knownIdsBefore excludes 'other-type', but it's the wrong type.
    final result = await repo.upload(upload(retry: true));
    expect(server.uploads, hasLength(1)); // nothing adoptable → it did upload
    expect(result, isA<Ok<WorkerDocument>>().having((r) => r.value.type, 'type', DocumentType.nationalIdFront));
  });

  group('server rejections map to document failures', () {
    Future<Failure> failWith(int status, Object message) async {
      final h = ApiHarness({
        'POST /api/v1/workers/me/documents': (_, _) async => FakeBackend.error(status, message),
      }, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
      final r = await DocumentRepositoryImpl(DocumentRemoteDataSource(h.api)).upload(upload());
      return (r as Err<WorkerDocument>).failure;
    }

    test('413 → DocumentTooLarge', () async {
      expect(await failWith(413, 'File too large'), isA<DocumentTooLarge>());
    });
    test('400 file type → DocumentTypeNotAllowed', () async {
      expect(await failWith(400, 'File type not recognized. Allowed: JPEG, PNG, PDF.'), isA<DocumentTypeNotAllowed>());
    });
    test('400 expiresAt → DocumentExpiryRequired', () async {
      expect(await failWith(400, 'expiresAt is required for CRIMINAL_RECORD documents'), isA<DocumentExpiryRequired>());
    });
  });

  test('delete while under review → DocumentDeletionLocked', () async {
    final h = ApiHarness({
      'DELETE /api/v1/workers/me/documents/d1': (_, _) async =>
          FakeBackend.error(400, 'Documents can only be deleted while the profile is DRAFT or REJECTED'),
    }, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
    final r = await DocumentRepositoryImpl(DocumentRemoteDataSource(h.api)).delete('d1');
    expect((r as Err<void>).failure, isA<DocumentDeletionLocked>());
  });
}
