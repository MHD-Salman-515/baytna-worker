/// Every path in one place. Auth-flow screens take their inputs from the
/// query string (not `extra`), so a restart mid-flow still works.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const authPrefix = '/auth';
  static const country = '/auth/country';
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';

  /// Signed in, never applied: "become a Baytna worker".
  static const apply = '/apply';

  /// Her home until she is APPROVED: where she stands and what's next.
  static const status = '/status';

  /// Onboarding steps, stacked on top of the status screen. Reachable only
  /// while her profile is editable (DRAFT / REJECTED).
  static const profile = '/status/profile';
  static const documents = '/status/documents';

  /// APPROVED only, like every path below: anything not on the status
  /// allow-lists in app_redirect.dart is closed until she is approved.
  static const home = '/home';
  static const work = '/work';
  static const availability = '/work/availability';
  static const offeringNew = '/work/services/new';
  static const wallet = '/wallet';
  static const bookingPrefix = '/bookings';

  static String offeringFor(String id) => '/work/services/$id';

  static String bookingFor(String id) => '$bookingPrefix/$id';

  static String phoneFor(String countryId) =>
      Uri(path: phone, queryParameters: {'countryId': countryId}).toString();

  static String otpFor({required String countryId, required String phoneE164}) => Uri(
    path: otp,
    queryParameters: {'countryId': countryId, 'phone': phoneE164},
  ).toString();
}
