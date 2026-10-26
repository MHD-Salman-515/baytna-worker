/// `WorkerProfile.verificationStatus` — THE gate. Holding the WORKER role
/// confers no capability; only [approved] lets a worker work.
///
///   DRAFT ──submit──► PENDING_REVIEW ──admin──► APPROVED | REJECTED
///   REJECTED ──fix + submit──► PENDING_REVIEW;  any ──admin──► SUSPENDED
enum VerificationStatus {
  draft('DRAFT'),
  pendingReview('PENDING_REVIEW'),
  approved('APPROVED'),
  rejected('REJECTED'),
  suspended('SUSPENDED'),

  /// A value this build doesn't know. Treated as NOT approved.
  unknown('');

  VerificationStatus(this.apiValue);

  final String apiValue;

  static VerificationStatus fromApi(String? value) =>
      values.firstWhere((s) => s.apiValue == value && s != unknown, orElse: () => unknown);

  bool get isApproved => this == approved;

  /// Profile and documents can be changed (and documents deleted) only here.
  bool get isEditable => this == draft || this == rejected;
}

/// `WorkerProfile.financialStatus` — INDEPENDENT of [VerificationStatus]. A
/// verified worker can be financially suspended (e.g. wallet below the
/// country's negative floor) and vice versa; clearing one never clears the
/// other, so the UI always shows them separately.
enum FinancialStatus {
  active('ACTIVE'),
  suspended('SUSPENDED'),

  /// Unrecognized value: shown as "restricted", never as active.
  unknown('');

  FinancialStatus(this.apiValue);

  final String apiValue;

  static FinancialStatus fromApi(String? value) =>
      values.firstWhere((s) => s.apiValue == value && s != unknown, orElse: () => unknown);
}
