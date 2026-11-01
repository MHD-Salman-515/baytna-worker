// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بيتنا للعاملات';

  @override
  String get appTagline => 'اعملي بثقة، بشروطك';

  @override
  String get switchLanguage => 'English';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get continueAction => 'متابعة';

  @override
  String get serverWakingUp => 'الخادم يستيقظ، قد يستغرق ذلك دقيقة…';

  @override
  String get countrySelectTitle => 'اختر بلدك';

  @override
  String get countrySelectSubtitle => 'نعرض الخدمات والأسعار حسب بلدك';

  @override
  String get countriesEmpty => 'لا توجد دول متاحة حالياً';

  @override
  String get phoneTitle => 'رقم الهاتف';

  @override
  String get phoneSubtitle => 'أدخل رقم هاتفك المحمول وسنرسل لك رمز تحقق';

  @override
  String get phoneFieldLabel => 'رقم الهاتف المحمول';

  @override
  String get phoneInvalid => 'أدخل رقم هاتف صحيحاً';

  @override
  String get phoneRejected => 'هذا الرقم غير صالح للبلد المختار';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get otpVerify => 'تحقق';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds ثانية',
      few: '$seconds ثوانٍ',
      two: 'ثانيتين',
      one: 'ثانية واحدة',
    );
    return 'يمكنك إعادة الإرسال بعد $_temp0';
  }

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String get otpResent => 'تم إرسال رمز جديد';

  @override
  String get otpInvalid => 'الرمز غير صحيح أو منتهي الصلاحية';

  @override
  String get otpTooManyAttempts =>
      'محاولات خاطئة كثيرة. اطلب رمزاً جديداً للمتابعة.';

  @override
  String get changeNumber => 'تغيير الرقم';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get sessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مجدداً.';

  @override
  String get errorNetwork => 'تعذّر الاتصال. تحقق من اتصالك بالإنترنت.';

  @override
  String get errorTimeout => 'استغرق الخادم وقتاً طويلاً للرد. حاول مجدداً.';

  @override
  String get errorServer => 'حدث خطأ في الخادم. حاول لاحقاً.';

  @override
  String get errorRateLimited => 'طلبات كثيرة. انتظر قليلاً ثم حاول مجدداً.';

  @override
  String get errorValidation => 'البيانات المدخلة غير صحيحة.';

  @override
  String get errorUnauthorized => 'ليست لديك صلاحية للقيام بذلك.';

  @override
  String get errorNotFound => 'العنصر المطلوب غير موجود.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع.';

  @override
  String get splashLoadFailed => 'تعذّر تحميل حسابك';

  @override
  String get applyTitle => 'انضمي إلى بيتنا';

  @override
  String get applySubtitle =>
      'قدّمي طلبك للعمل مع بيتنا. نراجع كل طلب بعناية لحماية العاملات والعائلات.';

  @override
  String get applyStepProfile =>
      'أكملي ملفك المهني: خبرتك ولغاتك والمدن التي تعملين فيها';

  @override
  String get applyStepDocuments => 'ارفعي صور هويتك وشهادة عدم المحكومية';

  @override
  String get applyStepReview =>
      'يراجع فريق بيتنا طلبك، ثم تبدئين العمل بعد القبول';

  @override
  String get applyAction => 'تقديم طلب الانضمام';

  @override
  String get applyRoleNotGranted =>
      'تم تقديم طلبك لكن لم تُحدَّث صلاحياتك بعد. حاولي مجدداً.';

  @override
  String get profileTitle => 'ملفك المهني';

  @override
  String get profileSubtitle => 'هذه المعلومات تساعد العائلات على اختيارك';

  @override
  String get profileBioAr => 'نبذة عنك (بالعربية)';

  @override
  String get profileBioEn => 'نبذة عنك (بالإنجليزية) — اختياري';

  @override
  String get profileBioHint => 'مثال: خبرة 5 سنوات في تنظيف المنازل والطبخ';

  @override
  String get profileYears => 'سنوات الخبرة';

  @override
  String get profileYearsInvalid => 'أدخلي عدداً صحيحاً بين 0 و60';

  @override
  String get profileLanguages => 'اللغات التي تتحدثينها';

  @override
  String get profileLanguagesRequired => 'اختاري لغة واحدة على الأقل';

  @override
  String get profileCity => 'مدينتك';

  @override
  String get profileCityRequired => 'اختاري مدينتك';

  @override
  String get profileAreas => 'المدن التي تعملين فيها';

  @override
  String get profileAreasRequired => 'اختاري مدينة واحدة على الأقل';

  @override
  String get profileNoCities => 'لا توجد مدن متاحة في بلدك حالياً';

  @override
  String get profileSave => 'حفظ ومتابعة';

  @override
  String get profileSaved => 'تم حفظ ملفك';

  @override
  String get languageAr => 'العربية';

  @override
  String get languageKu => 'الكردية';

  @override
  String get languageEn => 'الإنجليزية';

  @override
  String get languageTr => 'التركية';

  @override
  String get languageFr => 'الفرنسية';

  @override
  String get documentsTitle => 'الوثائق';

  @override
  String get documentsSubtitle =>
      'صوّري الوثائق كاملة وبإضاءة جيدة حتى تكون كل الكتابة واضحة';

  @override
  String get documentsPrivacy =>
      'تُرسل وثائقك مباشرة إلى فريق المراجعة في بيتنا ولا تُحفظ على هاتفك.';

  @override
  String get documentNationalIdFront => 'الهوية — الوجه الأمامي';

  @override
  String get documentNationalIdBack => 'الهوية — الوجه الخلفي';

  @override
  String get documentCriminalRecord => 'شهادة عدم المحكومية';

  @override
  String get documentOther => 'وثيقة أخرى';

  @override
  String get documentStateMissing => 'مطلوبة';

  @override
  String get documentStatePending => 'قيد المراجعة';

  @override
  String get documentStateApproved => 'مقبولة';

  @override
  String get documentStateRejected => 'مرفوضة';

  @override
  String get documentStateExpired => 'منتهية الصلاحية';

  @override
  String get documentStateReady => 'جاهزة للرفع';

  @override
  String documentRejectedReason(String reason) {
    return 'سبب الرفض: $reason';
  }

  @override
  String documentExpiresOn(String date) {
    return 'تنتهي صلاحيتها في $date';
  }

  @override
  String get documentSourceCamera => 'الكاميرا';

  @override
  String get documentSourceGallery => 'المعرض';

  @override
  String get documentSourceFile => 'ملف PDF';

  @override
  String get documentChoose => 'اختيار';

  @override
  String get documentReplace => 'استبدال';

  @override
  String get documentUpload => 'رفع';

  @override
  String get documentDiscard => 'إلغاء';

  @override
  String get documentExpiryLabel => 'تاريخ انتهاء الصلاحية';

  @override
  String get documentExpiryPick => 'اختاري تاريخ الانتهاء المكتوب على الشهادة';

  @override
  String documentUploading(int percent) {
    return 'جارٍ الرفع… $percent٪';
  }

  @override
  String get documentUploadingUnknown => 'جارٍ الرفع…';

  @override
  String get documentUploaded => 'تم رفع الوثيقة';

  @override
  String get documentTooLarge =>
      'الملف أكبر من 5 ميغابايت. التقطي صورة جديدة أو اختاري ملفاً أصغر.';

  @override
  String get documentTypeNotAllowed =>
      'نوع الملف غير مدعوم. المسموح: صورة JPEG أو PNG، أو ملف PDF.';

  @override
  String get documentExpiryRequired => 'أدخلي تاريخ انتهاء صلاحية في المستقبل';

  @override
  String get documentDeletionLocked =>
      'لا يمكن تعديل الوثائق أثناء مراجعة طلبك';

  @override
  String documentPdfPreview(String size) {
    return 'ملف PDF · $size';
  }

  @override
  String get documentsDone => 'تم';

  @override
  String get documentsAllUploaded =>
      'رُفعت كل الوثائق المطلوبة. يمكنك الآن إرسال طلبك للمراجعة.';

  @override
  String get statusTitle => 'طلبك';

  @override
  String get statusDraftTitle => 'أكملي طلبك';

  @override
  String get statusDraftBody => 'بقيت خطوات قليلة قبل إرسال طلبك للمراجعة.';

  @override
  String get statusPendingTitle => 'طلبك قيد المراجعة';

  @override
  String get statusPendingBody =>
      'سنخبرك هنا فور انتهاء المراجعة. لا يمكنك استقبال طلبات عمل قبل القبول.';

  @override
  String statusSubmittedAt(String date) {
    return 'أُرسل في $date';
  }

  @override
  String statusWaitingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتين',
      one: 'دقيقة',
      zero: 'أقل من دقيقة',
    );
    return 'بانتظار المراجعة منذ $_temp0';
  }

  @override
  String statusWaitingHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ساعة',
      few: '$count ساعات',
      two: 'ساعتين',
      one: 'ساعة',
    );
    return 'بانتظار المراجعة منذ $_temp0';
  }

  @override
  String statusWaitingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوماً',
      few: '$count أيام',
      two: 'يومين',
      one: 'يوم',
    );
    return 'بانتظار المراجعة منذ $_temp0';
  }

  @override
  String get statusRejectedTitle => 'لم يُقبل طلبك بعد';

  @override
  String get statusRejectedBody => 'صحّحي ما يلي ثم أعيدي إرسال طلبك.';

  @override
  String get statusRejectedReason => 'ملاحظة فريق المراجعة';

  @override
  String get statusDocumentsToReplace => 'وثائق يجب استبدالها';

  @override
  String get statusSuspendedTitle => 'حسابك موقوف';

  @override
  String get statusSuspendedBody =>
      'لا يمكنك استقبال أعمال جديدة حالياً. تواصلي مع دعم بيتنا لمعرفة السبب وكيفية رفع الإيقاف.';

  @override
  String get statusApprovedTitle => 'تم قبولك!';

  @override
  String get statusApprovedBody => 'حسابك موثّق ويمكنك البدء بالعمل.';

  @override
  String get statusUnknownTitle => 'تعذّر تحديد حالة طلبك';

  @override
  String get statusUnknownBody =>
      'حدّثي الصفحة، وإن استمرت المشكلة تواصلي مع دعم بيتنا.';

  @override
  String get statusChecklistTitle => 'الخطوات';

  @override
  String get statusStepProfile => 'الملف المهني';

  @override
  String get statusStepDocuments => 'الوثائق المطلوبة';

  @override
  String get statusStepDone => 'مكتمل';

  @override
  String get statusStepTodo => 'غير مكتمل';

  @override
  String get statusEditProfile => 'تعديل الملف';

  @override
  String get statusOpenDocuments => 'الوثائق';

  @override
  String get statusSubmit => 'إرسال للمراجعة';

  @override
  String get statusResubmit => 'إعادة الإرسال للمراجعة';

  @override
  String get statusSubmitBlocked => 'أكملي الخطوات أعلاه أولاً';

  @override
  String get statusSubmitted => 'تم إرسال طلبك للمراجعة';

  @override
  String get statusMissingDocuments =>
      'بعض الوثائق المطلوبة ناقصة أو مرفوضة أو منتهية الصلاحية';

  @override
  String get statusTransitionConflict => 'تغيّرت حالة طلبك. تم تحديث الصفحة.';

  @override
  String get statusContinue => 'متابعة';

  @override
  String get statusPullToRefresh => 'اسحبي للأسفل للتحديث';

  @override
  String get statusRefresh => 'تحديث';

  @override
  String get accountSectionTitle => 'حسابك';

  @override
  String get verificationLabel => 'التوثيق';

  @override
  String get verificationDraft => 'غير مكتمل';

  @override
  String get verificationPending => 'قيد المراجعة';

  @override
  String get verificationApproved => 'موثّقة';

  @override
  String get verificationRejected => 'بحاجة لتعديل';

  @override
  String get verificationSuspended => 'موقوف';

  @override
  String get verificationUnknown => 'غير معروف';

  @override
  String get financialLabel => 'الوضع المالي';

  @override
  String get financialActive => 'سليم';

  @override
  String get financialSuspended => 'موقوف مالياً';

  @override
  String get financialUnknown => 'مقيّد';

  @override
  String get financialSuspendedBody =>
      'رصيد محفظتك تجاوز الحد المسموح. لن تصلك طلبات جديدة حتى تتم تسوية الرصيد، ويمكنك إكمال عملك الحالي.';

  @override
  String get financialUnknownBody =>
      'وضعك المالي غير واضح. تواصلي مع دعم بيتنا.';

  @override
  String get tabJobs => 'الأعمال';

  @override
  String get tabWork => 'عملي';

  @override
  String get tabWallet => 'المحفظة';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get jobsTitle => 'أعمالي';

  @override
  String jobsRequests(int count) {
    return 'الطلبات ($count)';
  }

  @override
  String jobsActive(int count) {
    return 'الحالية ($count)';
  }

  @override
  String get jobsHistory => 'السابقة';

  @override
  String get jobsRequestsEmpty =>
      'لا توجد طلبات بانتظار ردك الآن. ستظهر هنا فور وصولها.';

  @override
  String get jobsActiveEmpty => 'لا توجد أعمال مقبولة حالياً.';

  @override
  String get jobsHistoryEmpty => 'لا توجد أعمال سابقة بعد.';

  @override
  String get jobsExpiredNote => 'انتهت مهلة الرد على هذا الطلب.';

  @override
  String get jobsBannerFinancial =>
      'حسابك موقوف مالياً: لن تصلك طلبات جديدة حتى تتم تسوية محفظتك. أعمالك الحالية مستمرة.';

  @override
  String get jobsBannerUnavailable =>
      'أنتِ غير متاحة الآن، فلن تصلك طلبات جديدة.';

  @override
  String get bookingStatusSearching => 'بحث';

  @override
  String get bookingStatusPending => 'بانتظار ردك';

  @override
  String get bookingStatusAccepted => 'مقبول';

  @override
  String get bookingStatusOnTheWay => 'في الطريق';

  @override
  String get bookingStatusArrived => 'وصلتِ';

  @override
  String get bookingStatusInProgress => 'جارٍ العمل';

  @override
  String get bookingStatusCompleted => 'مكتمل';

  @override
  String get bookingStatusRejected => 'مرفوض';

  @override
  String get bookingStatusCancelled => 'ملغى';

  @override
  String get bookingStatusExpired => 'منتهي المهلة';

  @override
  String get bookingStatusNoShow => 'لم يتم الحضور';

  @override
  String get bookingStatusUnknown => 'غير معروف';

  @override
  String bookingAnswerWithin(String time) {
    return 'أجيبي خلال $time';
  }

  @override
  String get bookingDeadlinePassed => 'انتهت مهلة الرد';

  @override
  String get bookingHiddenUntilAccepted =>
      'هذا كل ما يمكن معرفته عن الموقع الآن. العنوان الدقيق ورقم العميل يظهران بعد القبول فقط.';

  @override
  String bookingFloor(String floor) {
    return 'الطابق: $floor';
  }

  @override
  String get bookingOpenMap => 'فتح الخريطة';

  @override
  String get bookingCannotOpen => 'تعذّر فتح التطبيق المطلوب';

  @override
  String bookingDuration(String duration) {
    return 'المدة المتوقعة: $duration';
  }

  @override
  String get bookingCustomerNote => 'ملاحظة من العميل';

  @override
  String durationMinutes(int count) {
    return '$count د';
  }

  @override
  String durationHours(int count) {
    return '$count س';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String get bookingWorkingFor => 'مدة العمل حتى الآن';

  @override
  String get bookingEstimatedEarnings => 'أرباحك المتوقعة (تقديرية)';

  @override
  String get bookingEstimateFixed => 'بعد خصم عمولة بيتنا.';

  @override
  String bookingEstimateHourly(String hours) {
    return 'تقدير لمدة $hours س بعد خصم العمولة. الرقم النهائي يُحسب من وقت عملك الفعلي عند الإنهاء.';
  }

  @override
  String get bookingEstimateHourlyNoHours =>
      'تقدير بعد خصم العمولة. الرقم النهائي يُحسب من وقت عملك الفعلي عند الإنهاء.';

  @override
  String bookingMinimumHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ساعة',
      few: '$hours ساعات',
      two: 'ساعتين',
      one: 'ساعة واحدة',
    );
    return 'الحد الأدنى $_temp0.';
  }

  @override
  String get bookingFinalEarnings => 'أرباحك النهائية';

  @override
  String get bookingEstimateWas => 'كان التقدير';

  @override
  String get bookingTimeWorked => 'وقت العمل الفعلي';

  @override
  String get bookingHoursCharged => 'الساعات المحتسبة';

  @override
  String get bookingCommissionCharged => 'العمولة المخصومة من محفظتك';

  @override
  String bookingDifferenceMinimum(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ساعة',
      few: '$hours ساعات',
      two: 'ساعتين',
      one: 'ساعة واحدة',
    );
    return 'عملتِ أقل من الحد الأدنى، فاحتُسب الحد الأدنى ($_temp0) بدل الساعات المقدّرة. هذا الفرق طبيعي وليس خصماً عليك.';
  }

  @override
  String get bookingDifferenceActualTime =>
      'الأجر بالساعة يُحسب من وقت عملك الفعلي، لا من المدة المقدّرة عند الحجز، لذلك اختلف الرقم عن التقدير.';

  @override
  String get bookingDifferenceGeneric =>
      'تحدد الرقم النهائي عند إنهاء العمل، لذلك اختلف عن التقدير.';

  @override
  String get bookingSeeWallet => 'عرض محفظتي';

  @override
  String get bookingCancelledByCustomer => 'ألغى العميل هذا الحجز';

  @override
  String get bookingCancelledByYou => 'ألغيتِ هذا الحجز';

  @override
  String get bookingAccept => 'قبول';

  @override
  String get bookingReject => 'رفض';

  @override
  String get bookingRejectTitle => 'لماذا ترفضين هذا الطلب؟';

  @override
  String get bookingRejectConfirm => 'رفض الطلب';

  @override
  String get reasonRejectFar => 'المكان بعيد';

  @override
  String get reasonRejectBusy => 'لدي التزام في هذا الوقت';

  @override
  String get reasonRejectNotSuitable => 'الطلب غير مناسب لي';

  @override
  String get reasonOther => 'سبب آخر';

  @override
  String get bookingCancelAction => 'إلغاء هذا الحجز';

  @override
  String get bookingCancelTitle => 'لماذا تلغين هذا الحجز؟';

  @override
  String get bookingCancelConfirm => 'تأكيد الإلغاء';

  @override
  String bookingCancelPenalty(String amount) {
    return 'سيُخصم $amount من محفظتك عند الإلغاء.';
  }

  @override
  String get reasonCancelEmergency => 'ظرف طارئ';

  @override
  String get reasonCancelTransport => 'تعذّر الوصول';

  @override
  String get reasonCancelCustomerAsked => 'طلب العميل الإلغاء';

  @override
  String get bookingStepOnTheWay => 'انطلقتُ إلى العميل';

  @override
  String get bookingStepArrived => 'وصلتُ';

  @override
  String get bookingStepStart => 'بدء العمل';

  @override
  String get bookingSwipeComplete => 'اسحبي لإنهاء العمل';

  @override
  String get bookingCompleteHint =>
      'عند الإنهاء يُحسب أجرك النهائي وتُخصم العمولة من محفظتك. لا يمكن التراجع.';

  @override
  String get bookingErrorExpired =>
      'انتهت مهلة هذا الطلب، ولم يعد بالإمكان الرد عليه.';

  @override
  String get bookingErrorCancelled => 'أُلغي هذا الحجز.';

  @override
  String get bookingErrorCompleted => 'هذا العمل مكتمل بالفعل.';

  @override
  String get bookingErrorStale =>
      'تغيّرت حالة هذا الحجز، وحدّثنا الصفحة لتعرضها كما هي الآن.';

  @override
  String get bookingErrorGate =>
      'لا يمكنك قبول طلبات جديدة الآن. راجعي حالة حسابك ومحفظتك.';

  @override
  String get bookingErrorClash => 'يتعارض هذا الموعد مع عمل آخر لديك.';

  @override
  String get bookingErrorRefused =>
      'تعذّر تنفيذ هذه الخطوة الآن. حاولي مجدداً بعد قليل.';

  @override
  String get bookingErrorNotFound => 'لم نعد نجد هذا الحجز.';

  @override
  String get workTitle => 'عملي';

  @override
  String get workSchedule => 'جدول العمل الأسبوعي';

  @override
  String get workScheduleHint => 'متى تستقبلين الحجوزات';

  @override
  String get workServices => 'خدماتي وأسعاري';

  @override
  String get workNoServices => 'لم تضيفي أي خدمة بعد. بدون خدمة لا يمكن حجزك.';

  @override
  String get workAddService => 'إضافة خدمة';

  @override
  String get availabilityOn => 'أنا متاحة للعمل';

  @override
  String get availabilityOff => 'أنا غير متاحة الآن';

  @override
  String get availabilityIntentNote =>
      'هذا اختيارك أنتِ ويعبّر عن رغبتك في العمل فقط، وليس موافقة من بيتنا ولا يمنحك أي صلاحية.';

  @override
  String get availabilityNoEffectNow =>
      'لن يكون لهذا الخيار أثر الآن، لأن حسابك لا يستطيع استقبال طلبات جديدة حالياً.';

  @override
  String get pricingHourly => 'بالساعة';

  @override
  String get pricingBySize => 'حسب حجم المنزل';

  @override
  String get pricingFixed => 'سعر ثابت';

  @override
  String get pricingHourlyExplain =>
      'سعر لكل ساعة، مع حد أدنى من الساعات. يُحسب الأجر النهائي من الوقت الفعلي.';

  @override
  String get pricingBySizeExplain => 'سعر حسب عدد الغرف، على شكل شرائح.';

  @override
  String get pricingFixedExplain => 'سعر واحد للعمل كاملاً.';

  @override
  String priceSummaryHourly(String rate, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ساعة',
      few: '$hours ساعات',
      two: 'ساعتين',
      one: 'ساعة واحدة',
    );
    return '$rate بالساعة · حد أدنى $_temp0';
  }

  @override
  String priceSummaryFixed(String price) {
    return '$price سعر ثابت';
  }

  @override
  String priceSummaryBySize(String from, String to, int rooms) {
    return 'من $from إلى $to · حتى $rooms غرف';
  }

  @override
  String get offeringPaused => 'متوقفة مؤقتاً';

  @override
  String get offeringAddTitle => 'إضافة خدمة';

  @override
  String get offeringEditTitle => 'تعديل الخدمة';

  @override
  String get offeringService => 'الخدمة';

  @override
  String get offeringPricingModel => 'طريقة التسعير';

  @override
  String offeringRange(String min, String max, String unit) {
    return 'المسموح: من $min إلى $max $unit';
  }

  @override
  String get offeringRangePerHour => 'للساعة';

  @override
  String get offeringRangePerJob => 'للعمل';

  @override
  String get offeringRangePerTier => 'لكل شريحة';

  @override
  String get offeringNoRange => 'لا يوجد نطاق سعر محدد لهذه الخدمة بعد.';

  @override
  String get offeringHourlyRate => 'السعر بالساعة';

  @override
  String get offeringFixedPrice => 'السعر الثابت';

  @override
  String get offeringMinHours => 'الحد الأدنى من الساعات';

  @override
  String get offeringMinHoursHint => 'إن انتهى العمل أبكر، يُحتسب هذا الحد.';

  @override
  String get offeringMinHoursInvalid => 'الحد الأدنى ساعة واحدة على الأقل';

  @override
  String get offeringTierRooms => 'حتى (غرف)';

  @override
  String get offeringTierPrice => 'السعر';

  @override
  String get offeringTierAdd => 'إضافة شريحة';

  @override
  String get offeringTiersInvalid =>
      'رتّبي الشرائح تصاعدياً: كل شريحة تغطي غرفاً أكثر من التي قبلها.';

  @override
  String get offeringPriceMissing => 'أدخلي السعر بأرقام صحيحة';

  @override
  String offeringOutOfRange(String min, String max) {
    return 'السعر يجب أن يكون بين $min و$max';
  }

  @override
  String offeringCurrencyFixed(String currency) {
    return 'العملة: $currency. تُحدَّد عند إضافة الخدمة ولا يمكن تغييرها.';
  }

  @override
  String get offeringActive => 'الخدمة مفعّلة';

  @override
  String get offeringActiveHint => 'أوقفيها مؤقتاً دون حذف أسعارك.';

  @override
  String get offeringDelete => 'حذف الخدمة';

  @override
  String get offeringDeleteTitle => 'حذف هذه الخدمة؟';

  @override
  String get offeringDeleteBody => 'لن تظهر للزبائن بعد الآن.';

  @override
  String get offeringSave => 'حفظ';

  @override
  String get offeringTypeNotAllowed =>
      'طريقة التسعير هذه غير متاحة لهذه الخدمة.';

  @override
  String get offeringAlreadyExists =>
      'تقدّمين هذه الخدمة بالفعل. عدّليها بدل إضافتها مرة أخرى.';

  @override
  String get scheduleTitle => 'جدول العمل';

  @override
  String scheduleTimezone(String zone, String now) {
    return 'كل الأوقات بتوقيت بلدك ($zone)، والساعة هناك الآن $now، مهما كان توقيت هاتفك.';
  }

  @override
  String get scheduleDayOff => 'عطلة';

  @override
  String get scheduleAddRange => 'فترة أخرى';

  @override
  String get scheduleExceptions => 'أيام استثنائية';

  @override
  String get scheduleExceptionsHint =>
      'أيام عطلة أو ساعات إضافية خارج جدولك المعتاد.';

  @override
  String get scheduleBlocked => 'لا أعمل هذا اليوم';

  @override
  String scheduleExtra(String range) {
    return 'ساعات إضافية $range';
  }

  @override
  String get scheduleAddBlocked => 'يوم عطلة';

  @override
  String get scheduleAddExtra => 'ساعات إضافية';

  @override
  String get scheduleOverlap => 'هذه الفترات متداخلة';

  @override
  String get scheduleRangeInvalid => 'يجب أن تبدأ الفترة قبل نهايتها';

  @override
  String get scheduleInvalid => 'صحّحي الأوقات المعلّمة أولاً';

  @override
  String get scheduleSave => 'حفظ الجدول';

  @override
  String get scheduleSaved => 'تم حفظ جدولك';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get walletBalance => 'رصيدك';

  @override
  String walletRoomToFloor(String room, String floor) {
    return 'يبقى $room قبل الوصول إلى الحد الأدنى ($floor). الرصيد السالب مسموح حتى هذا الحد.';
  }

  @override
  String walletPastFloor(String over, String floor) {
    return 'تجاوزتِ الحد الأدنى ($floor) بمقدار $over.';
  }

  @override
  String walletLowWarning(String threshold) {
    return 'رصيدك منخفض: وصل إلى $threshold أو أقل. اشحني المحفظة قبل بلوغ الحد الأدنى كي لا يتوقف استقبال الطلبات.';
  }

  @override
  String get walletBelowFloor =>
      'تجاوز رصيدك الحد الأدنى. يتوقف استقبال الطلبات الجديدة تلقائياً حتى الشحن، ويعود تلقائياً بعده.';

  @override
  String get walletTopupNote =>
      'لا يمكن شحن المحفظة من التطبيق حالياً: يسجّل فريق بيتنا الشحن يدوياً بعد الدفع له مباشرة. تواصلي مع الدعم للشحن.';

  @override
  String get walletLedger => 'حركات المحفظة';

  @override
  String get walletLedgerEmpty => 'لا توجد حركات بعد.';

  @override
  String get entryTopup => 'شحن';

  @override
  String get entryCommission => 'عمولة';

  @override
  String get entryCancellationFee => 'رسوم إلغاء';

  @override
  String get entryAdjustment => 'تسوية';

  @override
  String get entryRefund => 'استرداد';

  @override
  String get entryReversal => 'عكس قيد';

  @override
  String get entryOther => 'حركة';

  @override
  String entryBalanceAfter(String balance) {
    return 'الرصيد: $balance';
  }

  @override
  String get bookingCannotAcceptNow =>
      'لا يمكنك قبول طلبات جديدة حالياً. راجعي حالة حسابك ومحفظتك.';

  @override
  String get statusJobsInHand => 'أعمالك الحالية مستمرة';

  @override
  String get statusJobsInHandBody =>
      'الإيقاف يمنع الأعمال الجديدة فقط. يمكنك إتمام ما بدأتِه.';

  @override
  String get devFillOtp => 'تعبئة الرمز تلقائياً (وضع التطوير)';

  @override
  String devOtpUnavailable(String reason) {
    return 'تعذّر جلب الرمز: $reason';
  }
}
