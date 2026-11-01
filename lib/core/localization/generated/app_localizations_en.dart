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
      'Your wallet balance is past the allowed limit. You won\'t get new requests until it\'s settled, but you can finish the jobs you already have.';

  @override
  String get financialUnknownBody =>
      'Your financial standing is unclear. Contact Baytna support.';

  @override
  String get tabJobs => 'Jobs';

  @override
  String get tabWork => 'My work';

  @override
  String get tabWallet => 'Wallet';

  @override
  String get loadMore => 'Load more';

  @override
  String get jobsTitle => 'My jobs';

  @override
  String jobsRequests(int count) {
    return 'Requests ($count)';
  }

  @override
  String jobsActive(int count) {
    return 'Current ($count)';
  }

  @override
  String get jobsHistory => 'Past';

  @override
  String get jobsRequestsEmpty =>
      'No requests waiting for you right now. They appear here as they arrive.';

  @override
  String get jobsActiveEmpty => 'You have no accepted jobs right now.';

  @override
  String get jobsHistoryEmpty => 'No past jobs yet.';

  @override
  String get jobsExpiredNote => 'The time to answer this request ran out.';

  @override
  String get jobsBannerFinancial =>
      'You are financially suspended: no new requests until your wallet is settled. Your current jobs carry on.';

  @override
  String get jobsBannerUnavailable =>
      'You\'re set as unavailable, so you won\'t get new requests.';

  @override
  String get bookingStatusSearching => 'Searching';

  @override
  String get bookingStatusPending => 'Awaiting your answer';

  @override
  String get bookingStatusAccepted => 'Accepted';

  @override
  String get bookingStatusOnTheWay => 'On the way';

  @override
  String get bookingStatusArrived => 'Arrived';

  @override
  String get bookingStatusInProgress => 'Working';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusRejected => 'Rejected';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingStatusExpired => 'Expired';

  @override
  String get bookingStatusNoShow => 'No-show';

  @override
  String get bookingStatusUnknown => 'Unknown';

  @override
  String bookingAnswerWithin(String time) {
    return 'Answer within $time';
  }

  @override
  String get bookingDeadlinePassed => 'The time to answer has run out';

  @override
  String bookingPlaceYourCity(String city) {
    return '$city — in your city';
  }

  @override
  String bookingPlaceOtherCity(String city, int km) {
    return '$city — about $km km between the city centres';
  }

  @override
  String get bookingHiddenUntilAccepted =>
      'This is all that can be shown about the location for now. The exact address, distance and customer\'s number appear only after you accept.';

  @override
  String bookingFloor(String floor) {
    return 'Floor: $floor';
  }

  @override
  String get bookingOpenMap => 'Open map';

  @override
  String get bookingCannotOpen => 'Could not open that app';

  @override
  String bookingDuration(String duration) {
    return 'Expected length: $duration';
  }

  @override
  String get bookingCustomerNote => 'Note from the customer';

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String durationHours(int count) {
    return '$count h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get bookingWorkingFor => 'Time worked so far';

  @override
  String get bookingEstimatedEarnings => 'Your estimated earnings';

  @override
  String get bookingEstimateFixed => 'After Baytna\'s commission.';

  @override
  String bookingEstimateHourly(String hours) {
    return 'An estimate for $hours hours, after commission. The final figure is worked out from your actual time when you finish.';
  }

  @override
  String get bookingEstimateHourlyNoHours =>
      'An estimate after commission. The final figure is worked out from your actual time when you finish.';

  @override
  String bookingMinimumHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'The minimum is $_temp0.';
  }

  @override
  String get bookingFinalEarnings => 'Your final earnings';

  @override
  String get bookingEstimateWas => 'The estimate was';

  @override
  String get bookingTimeWorked => 'Actual time worked';

  @override
  String get bookingHoursCharged => 'Hours charged';

  @override
  String get bookingCommissionCharged => 'Commission charged to your wallet';

  @override
  String bookingDifferenceMinimum(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'You worked less than your minimum, so your minimum ($_temp0) was charged instead of the estimated hours. This difference is expected; nothing was taken from you.';
  }

  @override
  String get bookingDifferenceActualTime =>
      'Hourly pay is worked out from the time you actually worked, not the length estimated at booking, which is why it differs from the estimate.';

  @override
  String get bookingDifferenceGeneric =>
      'The final figure was set when the job finished, which is why it differs from the estimate.';

  @override
  String get bookingSeeWallet => 'See my wallet';

  @override
  String get bookingCancelledByCustomer =>
      'The customer cancelled this booking';

  @override
  String get bookingCancelledByYou => 'You cancelled this booking';

  @override
  String get bookingAccept => 'Accept';

  @override
  String get bookingReject => 'Reject';

  @override
  String get bookingCannotAcceptSuspended =>
      'You can\'t accept new requests until your wallet is settled.';

  @override
  String get bookingRejectTitle => 'Why are you rejecting this request?';

  @override
  String get bookingRejectConfirm => 'Reject request';

  @override
  String get reasonRejectFar => 'Too far away';

  @override
  String get reasonRejectBusy => 'I\'m busy at that time';

  @override
  String get reasonRejectNotSuitable => 'This job isn\'t right for me';

  @override
  String get reasonOther => 'Another reason';

  @override
  String get bookingCancelAction => 'Cancel this booking';

  @override
  String get bookingCancelTitle => 'Why are you cancelling this booking?';

  @override
  String get bookingCancelConfirm => 'Confirm cancellation';

  @override
  String bookingCancelPenalty(String amount) {
    return '$amount will be charged to your wallet if you cancel.';
  }

  @override
  String get reasonCancelEmergency => 'An emergency';

  @override
  String get reasonCancelTransport => 'I can\'t get there';

  @override
  String get reasonCancelCustomerAsked => 'The customer asked me to cancel';

  @override
  String get bookingStepOnTheWay => 'I\'m on my way';

  @override
  String get bookingStepArrived => 'I have arrived';

  @override
  String get bookingStepStart => 'Start work';

  @override
  String get bookingSwipeComplete => 'Swipe to finish the job';

  @override
  String get bookingCompleteHint =>
      'Finishing sets your final pay and charges the commission to your wallet. This can\'t be undone.';

  @override
  String get bookingErrorExpired =>
      'This request has expired and can no longer be answered.';

  @override
  String get bookingErrorCancelled => 'This booking was cancelled.';

  @override
  String get bookingErrorCompleted => 'This job is already completed.';

  @override
  String get bookingErrorStale =>
      'This booking has changed, so the page has been updated to show where it stands now.';

  @override
  String get bookingErrorGate =>
      'You can\'t accept new requests right now. Check your account and wallet status.';

  @override
  String get bookingErrorClash =>
      'This time clashes with another of your jobs.';

  @override
  String get bookingErrorRefused =>
      'This step can\'t be done right now. Please try again shortly.';

  @override
  String get bookingErrorNotFound => 'We can\'t find this booking any more.';

  @override
  String get workTitle => 'My work';

  @override
  String get workSchedule => 'Weekly schedule';

  @override
  String get workScheduleHint => 'When you can be booked';

  @override
  String get workServices => 'My services and prices';

  @override
  String get workNoServices =>
      'You haven\'t added a service yet. Without one you can\'t be booked.';

  @override
  String get workAddService => 'Add a service';

  @override
  String get availabilityOn => 'I\'m available to work';

  @override
  String get availabilityOff => 'I\'m not available right now';

  @override
  String get availabilityIntentNote =>
      'This is your choice: it only says you want to work. It isn\'t approval from Baytna and gives you no permissions.';

  @override
  String get availabilityNoEffectNow =>
      'This setting has no effect right now, because your account can\'t receive new requests at the moment.';

  @override
  String get pricingHourly => 'Hourly';

  @override
  String get pricingBySize => 'By home size';

  @override
  String get pricingFixed => 'Fixed price';

  @override
  String get pricingHourlyExplain =>
      'A rate per hour with a minimum number of hours. Final pay comes from the actual time.';

  @override
  String get pricingBySizeExplain => 'A price by number of rooms, in tiers.';

  @override
  String get pricingFixedExplain => 'One price for the whole job.';

  @override
  String priceSummaryHourly(String rate, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '$rate an hour · $_temp0 minimum';
  }

  @override
  String priceSummaryFixed(String price) {
    return '$price fixed price';
  }

  @override
  String priceSummaryBySize(String from, String to, int rooms) {
    return '$from to $to · up to $rooms rooms';
  }

  @override
  String get offeringPaused => 'Paused';

  @override
  String get offeringAddTitle => 'Add a service';

  @override
  String get offeringEditTitle => 'Edit service';

  @override
  String get offeringService => 'Service';

  @override
  String get offeringPricingModel => 'Pricing model';

  @override
  String offeringRange(String min, String max, String unit) {
    return 'Allowed: $min to $max $unit';
  }

  @override
  String get offeringRangePerHour => 'per hour';

  @override
  String get offeringRangePerJob => 'per job';

  @override
  String get offeringRangePerTier => 'per tier';

  @override
  String get offeringNoRange => 'No price range is set for this service yet.';

  @override
  String get offeringHourlyRate => 'Hourly rate';

  @override
  String get offeringFixedPrice => 'Fixed price';

  @override
  String get offeringMinHours => 'Minimum hours';

  @override
  String get offeringMinHoursHint =>
      'If a job ends sooner, this minimum is charged.';

  @override
  String get offeringMinHoursInvalid => 'The minimum is at least 1 hour';

  @override
  String get offeringTierRooms => 'Up to (rooms)';

  @override
  String get offeringTierPrice => 'Price';

  @override
  String get offeringTierAdd => 'Add a tier';

  @override
  String get offeringTiersInvalid =>
      'Put tiers in ascending order: each must cover more rooms than the one before.';

  @override
  String get offeringPriceMissing => 'Enter the price as a whole number';

  @override
  String offeringOutOfRange(String min, String max) {
    return 'The price must be between $min and $max';
  }

  @override
  String offeringCurrencyFixed(String currency) {
    return 'Currency: $currency. It is set when the service is added and can\'t be changed.';
  }

  @override
  String get offeringActive => 'Service is active';

  @override
  String get offeringActiveHint => 'Pause it without losing your prices.';

  @override
  String get offeringDelete => 'Delete service';

  @override
  String get offeringDeleteTitle => 'Delete this service?';

  @override
  String get offeringDeleteBody => 'Customers will no longer see it.';

  @override
  String get offeringSave => 'Save';

  @override
  String get offeringTypeNotAllowed =>
      'This pricing model isn\'t available for this service.';

  @override
  String get offeringAlreadyExists =>
      'You already offer this service. Edit it instead of adding it again.';

  @override
  String get scheduleTitle => 'Work schedule';

  @override
  String scheduleTimezone(String zone, String now) {
    return 'All times are in your country\'s time ($zone), where it is now $now, whatever your phone is set to.';
  }

  @override
  String get scheduleDayOff => 'Day off';

  @override
  String get scheduleAddRange => 'Another period';

  @override
  String get scheduleExceptions => 'Exceptions';

  @override
  String get scheduleExceptionsHint =>
      'Days off or extra hours outside your usual week.';

  @override
  String get scheduleBlocked => 'Not working this day';

  @override
  String scheduleExtra(String range) {
    return 'Extra hours $range';
  }

  @override
  String get scheduleAddBlocked => 'Day off';

  @override
  String get scheduleAddExtra => 'Extra hours';

  @override
  String get scheduleOverlap => 'These periods overlap';

  @override
  String get scheduleRangeInvalid => 'A period must start before it ends';

  @override
  String get scheduleInvalid => 'Fix the marked times first';

  @override
  String get scheduleSave => 'Save schedule';

  @override
  String get scheduleSaved => 'Schedule saved';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletBalance => 'Your balance';

  @override
  String walletRoomToFloor(String room, String floor) {
    return '$room left before the floor ($floor). A negative balance is allowed down to that limit.';
  }

  @override
  String walletPastFloor(String over, String floor) {
    return 'You are $over past the floor ($floor).';
  }

  @override
  String walletLowWarning(String threshold) {
    return 'Your balance is low: $threshold or below. Top up before you reach the floor so requests don\'t stop.';
  }

  @override
  String get walletBelowFloor =>
      'Your balance is past the floor. New requests stop automatically until you top up, and resume automatically after.';

  @override
  String get walletTopupNote =>
      'You can\'t top up in the app yet: Baytna staff record top-ups by hand after you pay them directly. Contact support to top up.';

  @override
  String get walletLedger => 'Wallet activity';

  @override
  String get walletLedgerEmpty => 'No activity yet.';

  @override
  String get entryTopup => 'Top-up';

  @override
  String get entryCommission => 'Commission';

  @override
  String get entryCancellationFee => 'Cancellation fee';

  @override
  String get entryAdjustment => 'Adjustment';

  @override
  String get entryRefund => 'Refund';

  @override
  String get entryReversal => 'Reversal';

  @override
  String get entryOther => 'Entry';

  @override
  String entryBalanceAfter(String balance) {
    return 'Balance: $balance';
  }

  @override
  String get devFillOtp => 'Autofill code (dev mode)';

  @override
  String devOtpUnavailable(String reason) {
    return 'Couldn\'t fetch the code: $reason';
  }
}
