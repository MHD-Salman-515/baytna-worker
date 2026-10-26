// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baytna for Workers';

  @override
  String get appTagline => 'Work with confidence, on your terms';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get retry => 'Try again';

  @override
  String get continueAction => 'Continue';

  @override
  String get serverWakingUp =>
      'The server is waking up — this can take a minute…';

  @override
  String get countrySelectTitle => 'Choose your country';

  @override
  String get countrySelectSubtitle =>
      'We show services and prices for your country';

  @override
  String get countriesEmpty => 'No countries are available right now';

  @override
  String get phoneTitle => 'Phone number';

  @override
  String get phoneSubtitle =>
      'Enter your mobile number and we\'ll text you a verification code';

  @override
  String get phoneFieldLabel => 'Mobile number';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get phoneRejected =>
      'This number isn\'t valid for the selected country';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpVerify => 'Verify';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'You can resend in $_temp0';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpResent => 'A new code has been sent';

  @override
  String get otpInvalid => 'The code is incorrect or has expired';

  @override
  String get otpTooManyAttempts =>
      'Too many incorrect attempts. Request a new code to continue.';

  @override
  String get changeNumber => 'Change number';

  @override
  String get logout => 'Log out';

  @override
  String get sessionExpired => 'Your session has ended. Please log in again.';

  @override
  String get errorNetwork =>
      'Couldn\'t connect. Check your internet connection.';

  @override
  String get errorTimeout =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try later.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorValidation => 'Some of the details you entered are invalid.';

  @override
  String get errorUnauthorized => 'You don\'t have permission to do that.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorUnknown => 'Something unexpected happened.';

  @override
  String get splashLoadFailed => 'We couldn\'t load your account';

  @override
  String get applyTitle => 'Join Baytna';

  @override
  String get applySubtitle =>
      'Apply to work with Baytna. We review every application carefully to protect workers and families.';

  @override
  String get applyStepProfile =>
      'Complete your profile: experience, languages and the cities you work in';

  @override
  String get applyStepDocuments =>
      'Upload your ID and your criminal-record certificate';

  @override
  String get applyStepReview =>
      'The Baytna team reviews your application; you can start once approved';

  @override
  String get applyAction => 'Apply to join';

  @override
  String get applyRoleNotGranted =>
      'Your application was received but your access wasn\'t updated yet. Please try again.';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileSubtitle => 'This helps families choose you';

  @override
  String get profileBioAr => 'About you (Arabic)';

  @override
  String get profileBioEn => 'About you (English) — optional';

  @override
  String get profileBioHint => 'e.g. 5 years of home cleaning and cooking';

  @override
  String get profileYears => 'Years of experience';

  @override
  String get profileYearsInvalid => 'Enter a whole number between 0 and 60';

  @override
  String get profileLanguages => 'Languages you speak';

  @override
  String get profileLanguagesRequired => 'Choose at least one language';

  @override
  String get profileCity => 'Your city';

  @override
  String get profileCityRequired => 'Choose your city';

  @override
  String get profileAreas => 'Cities you work in';

  @override
  String get profileAreasRequired => 'Choose at least one city';

  @override
  String get profileNoCities => 'No cities are available in your country yet';

  @override
  String get profileSave => 'Save and continue';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get languageAr => 'Arabic';

  @override
  String get languageKu => 'Kurdish';

  @override
  String get languageEn => 'English';

  @override
  String get languageTr => 'Turkish';

  @override
  String get languageFr => 'French';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsSubtitle =>
      'Photograph each document in full, in good light, so all the text is readable';

  @override
  String get documentsPrivacy =>
      'Your documents go straight to Baytna\'s review team and are not saved on your phone.';

  @override
  String get documentNationalIdFront => 'National ID — front';

  @override
  String get documentNationalIdBack => 'National ID — back';

  @override
  String get documentCriminalRecord => 'Criminal-record certificate';

  @override
  String get documentOther => 'Other document';

  @override
  String get documentStateMissing => 'Required';

  @override
  String get documentStatePending => 'Pending review';

  @override
  String get documentStateApproved => 'Approved';

  @override
  String get documentStateRejected => 'Rejected';

  @override
  String get documentStateExpired => 'Expired';

  @override
  String get documentStateReady => 'Ready to upload';

  @override
  String documentRejectedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String documentExpiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get documentSourceCamera => 'Camera';

  @override
  String get documentSourceGallery => 'Gallery';

  @override
  String get documentSourceFile => 'PDF file';

  @override
  String get documentChoose => 'Choose';

  @override
  String get documentReplace => 'Replace';

  @override
  String get documentUpload => 'Upload';

  @override
  String get documentDiscard => 'Discard';

  @override
  String get documentExpiryLabel => 'Expiry date';

  @override
  String get documentExpiryPick =>
      'Pick the expiry date printed on the certificate';

  @override
  String documentUploading(int percent) {
    return 'Uploading… $percent%';
  }

  @override
  String get documentUploadingUnknown => 'Uploading…';

  @override
  String get documentUploaded => 'Document uploaded';

  @override
  String get documentTooLarge =>
      'The file is over 5 MB. Take a new photo or choose a smaller file.';

  @override
  String get documentTypeNotAllowed =>
      'This file type isn\'t supported. Use a JPEG or PNG photo, or a PDF.';

  @override
  String get documentExpiryRequired => 'Enter an expiry date in the future';

  @override
  String get documentDeletionLocked =>
      'Documents can\'t be changed while your application is under review';

  @override
  String documentPdfPreview(String size) {
    return 'PDF file · $size';
  }

  @override
  String get documentsDone => 'Done';

  @override
  String get documentsAllUploaded =>
      'All required documents are uploaded. You can now submit your application.';

  @override
  String get statusTitle => 'Your application';

  @override
  String get statusDraftTitle => 'Complete your application';

  @override
  String get statusDraftBody =>
      'A few steps left before you can submit for review.';

  @override
  String get statusPendingTitle => 'Your application is under review';

  @override
  String get statusPendingBody =>
      'You\'ll see the result here once the review is done. You can\'t receive work until you\'re approved.';

  @override
  String statusSubmittedAt(String date) {
    return 'Submitted on $date';
  }

  @override
  String statusWaitingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
      zero: 'less than a minute',
    );
    return 'Waiting for $_temp0';
  }

  @override
  String statusWaitingHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return 'Waiting for $_temp0';
  }

  @override
  String statusWaitingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Waiting for $_temp0';
  }

  @override
  String get statusRejectedTitle => 'Your application needs changes';

  @override
  String get statusRejectedBody => 'Fix the following, then submit again.';

  @override
  String get statusRejectedReason => 'Note from the review team';

  @override
  String get statusDocumentsToReplace => 'Documents to replace';

  @override
  String get statusSuspendedTitle => 'Your account is suspended';

  @override
  String get statusSuspendedBody =>
      'You can\'t work at the moment. Contact Baytna support to find out why and how to lift the suspension.';

  @override
  String get statusApprovedTitle => 'You\'re approved!';

  @override
  String get statusApprovedBody =>
      'Your account is verified and you can start working.';

  @override
  String get statusUnknownTitle =>
      'We couldn\'t determine your application status';

  @override
  String get statusUnknownBody =>
      'Refresh the page; if this persists, contact Baytna support.';

  @override
  String get statusChecklistTitle => 'Steps';

  @override
  String get statusStepProfile => 'Profile';

  @override
  String get statusStepDocuments => 'Required documents';

  @override
  String get statusStepDone => 'Done';

  @override
  String get statusStepTodo => 'To do';

  @override
  String get statusEditProfile => 'Edit profile';

  @override
  String get statusOpenDocuments => 'Documents';

  @override
  String get statusSubmit => 'Submit for review';

  @override
  String get statusResubmit => 'Submit again';

  @override
  String get statusSubmitBlocked => 'Complete the steps above first';

  @override
  String get statusSubmitted => 'Your application was submitted for review';

  @override
  String get statusMissingDocuments =>
      'Some required documents are missing, rejected or expired';

  @override
  String get statusTransitionConflict =>
      'Your application status changed. The page has been refreshed.';

  @override
  String get statusContinue => 'Continue';

  @override
  String get statusPullToRefresh => 'Pull down to refresh';

  @override
  String get statusRefresh => 'Refresh';

  @override
  String get accountSectionTitle => 'Your account';

  @override
  String get verificationLabel => 'Verification';

  @override
  String get verificationDraft => 'Incomplete';

  @override
  String get verificationPending => 'Under review';

  @override
  String get verificationApproved => 'Verified';

  @override
  String get verificationRejected => 'Needs changes';

  @override
  String get verificationSuspended => 'Suspended';

  @override
  String get verificationUnknown => 'Unknown';

  @override
  String get financialLabel => 'Financial standing';

  @override
  String get financialActive => 'In good standing';

  @override
  String get financialSuspended => 'Financially suspended';

  @override
  String get financialUnknown => 'Restricted';

  @override
  String get financialSuspendedBody =>
      'Your wallet balance is past the allowed limit. You won\'t receive work offers until it is settled — even though your account is verified.';

  @override
  String get financialUnknownBody =>
      'Your financial standing is unclear. Contact Baytna support.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeWelcome => 'Welcome — you\'re ready to work';

  @override
  String get homeComingSoon =>
      'Bookings, offers and your wallet are coming in the next update';

  @override
  String get homeSignedInAs => 'Signed in as';

  @override
  String get devFillOtp => 'Autofill code (dev mode)';

  @override
  String devOtpUnavailable(String reason) {
    return 'Couldn\'t fetch the code: $reason';
  }
}
