import 'dart:typed_data';

import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/domain/document_failures.dart';
import 'package:baytna_worker/features/documents/domain/document_file_validator.dart';
import 'package:baytna_worker/features/documents/domain/document_requirements.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:flutter_test/flutter_test.dart';

PickedBytes _bytes(List<int> head, {int size = 0, String name = 'x'}) {
  final b = Uint8List(size > head.length ? size : head.length)..setAll(0, head);
  return PickedBytes(bytes: b, name: name);
}

WorkerDocument _doc(String id, DocumentType type, DocumentStatus status, DateTime created, {DateTime? expires}) =>
    WorkerDocument(id: id, type: type, status: status, createdAt: created, expiresAt: expires);

void main() {
  group('DocumentFileValidator — by magic bytes, not by name', () {
    test('accepts real JPEG, PNG and PDF', () {
      expect(DocumentFileValidator.validate(_bytes([0xFF, 0xD8, 0xFF, 0xE0])), isA<Ok<DocumentFile>>().having((r) => r.value.mime, 'mime', DocumentMime.jpeg));
      expect(DocumentFileValidator.validate(_bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])), isA<Ok<DocumentFile>>().having((r) => r.value.mime, 'mime', DocumentMime.png));
      expect(DocumentFileValidator.validate(_bytes('%PDF-1.4'.codeUnits)), isA<Ok<DocumentFile>>().having((r) => r.value.mime, 'mime', DocumentMime.pdf));
    });

    test('rejects a text file renamed .jpg, HEIC, and empty files', () {
      expect((DocumentFileValidator.validate(_bytes('hello'.codeUnits, name: 'id.jpg')) as Err).failure, isA<DocumentTypeNotAllowed>());
      expect((DocumentFileValidator.validate(_bytes([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63])) as Err).failure, isA<DocumentTypeNotAllowed>());
      expect((DocumentFileValidator.validate(PickedBytes(bytes: Uint8List(0), name: 'e')) as Err).failure, isA<DocumentTypeNotAllowed>());
    });

    test('5 MB exactly is fine; one byte more is too large', () {
      const max = DocumentFileValidator.maxBytes;
      expect(DocumentFileValidator.validate(_bytes([0xFF, 0xD8, 0xFF], size: max)), isA<Ok<DocumentFile>>());
      expect((DocumentFileValidator.validate(_bytes([0xFF, 0xD8, 0xFF], size: max + 1)) as Err).failure, isA<DocumentTooLarge>());
    });

    test('expiry must be tomorrow or later', () {
      final today = DateTime(2026, 10, 26, 15);
      expect(DocumentFileValidator.validateExpiry(null, today), isA<DocumentExpiryRequired>());
      expect(DocumentFileValidator.validateExpiry(DateTime(2026, 10, 26), today), isA<DocumentExpiryRequired>());
      expect(DocumentFileValidator.validateExpiry(DateTime(2020), today), isA<DocumentExpiryRequired>());
      expect(DocumentFileValidator.validateExpiry(DateTime(2026, 10, 27), today), isNull);
    });
  });

  group('DocumentRequirements', () {
    final now = DateTime.utc(2026, 10, 26);
    final t1 = DateTime.utc(2026, 10, 3);
    final t2 = DateTime.utc(2026, 10, 4);

    test('the NEWEST upload of a type is the one that counts', () {
      final docs = [
        _doc('a', DocumentType.nationalIdFront, DocumentStatus.rejected, t1),
        _doc('b', DocumentType.nationalIdFront, DocumentStatus.pending, t2),
      ];
      expect(DocumentRequirements.current(docs, DocumentType.nationalIdFront)!.id, 'b');
      expect(DocumentRequirements.superseded(docs, docs[1]).map((d) => d.id), ['a']);
    });

    test('outstanding = missing, rejected or EXPIRED required types', () {
      final docs = [
        _doc('f', DocumentType.nationalIdFront, DocumentStatus.approved, t1),
        _doc('b', DocumentType.nationalIdBack, DocumentStatus.rejected, t1),
        _doc('c', DocumentType.criminalRecord, DocumentStatus.pending, t1, expires: DateTime.utc(2020)),
      ];
      expect(DocumentRequirements.outstanding(docs, now), [DocumentType.nationalIdBack, DocumentType.criminalRecord]);
      expect(DocumentRequirements.stateOf(docs[2], now), RequirementState.expired);
      expect(DocumentRequirements.outstanding(const [], now), DocumentType.required);
    });

    test('pending and approved satisfy the requirement', () {
      final docs = [
        _doc('f', DocumentType.nationalIdFront, DocumentStatus.pending, t1),
        _doc('b', DocumentType.nationalIdBack, DocumentStatus.approved, t1),
        _doc('c', DocumentType.criminalRecord, DocumentStatus.pending, t1, expires: DateTime.utc(2027)),
      ];
      expect(DocumentRequirements.outstanding(docs, now), isEmpty);
    });
  });
}
