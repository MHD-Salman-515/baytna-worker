import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

enum DocumentType {
  nationalIdFront('NATIONAL_ID_FRONT'),
  nationalIdBack('NATIONAL_ID_BACK'),
  criminalRecord('CRIMINAL_RECORD'),
  profilePhoto('PROFILE_PHOTO'),
  other('OTHER'),
  unknown('');

  DocumentType(this.apiValue);

  final String apiValue;

  /// What POST /workers/me/submit checks for.
  static const List<DocumentType> required = [nationalIdFront, nationalIdBack, criminalRecord];

  static DocumentType fromApi(String? value) =>
      values.firstWhere((t) => t.apiValue == value && t != unknown, orElse: () => unknown);

  /// The backend rejects a CRIMINAL_RECORD upload without `expiresAt`, and an
  /// expired one counts as missing at submit time.
  bool get requiresExpiry => this == criminalRecord;
}

enum DocumentStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  unknown('');

  DocumentStatus(this.apiValue);

  final String apiValue;

  static DocumentStatus fromApi(String? value) =>
      values.firstWhere((s) => s.apiValue == value && s != unknown, orElse: () => unknown);
}

/// An element of GET /workers/me/documents. The file itself is never
/// downloaded by this app (only admins get a signed URL).
class WorkerDocument extends Equatable {
  const WorkerDocument({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.mimeType,
    this.sizeBytes,
    this.expiresAt,
    this.rejectionReason,
  });

  final String id;
  final DocumentType type;
  final DocumentStatus status;
  final DateTime createdAt;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? expiresAt;
  final LocalizedText? rejectionReason;

  bool isExpiredAt(DateTime now) => expiresAt != null && !expiresAt!.isAfter(now);

  @override
  List<Object?> get props => [id, type, status, createdAt, mimeType, sizeBytes, expiresAt, rejectionReason];
}
