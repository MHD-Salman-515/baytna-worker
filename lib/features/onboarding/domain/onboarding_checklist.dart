import 'package:baytna_worker/features/documents/domain/document_requirements.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:equatable/equatable.dart';

/// What still stands between her and "Submit for review".
class OnboardingChecklist extends Equatable {
  const OnboardingChecklist({required this.profileComplete, required this.outstandingDocuments});

  factory OnboardingChecklist.of(WorkerProfile profile, List<WorkerDocument> documents, DateTime now) =>
      OnboardingChecklist(
        profileComplete: profile.isProfileComplete,
        outstandingDocuments: DocumentRequirements.outstanding(documents, now),
      );

  final bool profileComplete;

  /// Required types that are missing, rejected or expired.
  final List<DocumentType> outstandingDocuments;

  bool get documentsComplete => outstandingDocuments.isEmpty;
  bool get canSubmit => profileComplete && documentsComplete;

  @override
  List<Object?> get props => [profileComplete, outstandingDocuments];
}
