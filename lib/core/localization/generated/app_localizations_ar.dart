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
      'لا يمكنك العمل حالياً. تواصلي مع دعم بيتنا لمعرفة السبب وكيفية رفع الإيقاف.';

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
      'رصيد محفظتك تجاوز الحد المسموح. لن تصلك عروض عمل حتى تتم تسوية الرصيد، حتى لو كان حسابك موثّقاً.';

  @override
  String get financialUnknownBody =>
      'وضعك المالي غير واضح. تواصلي مع دعم بيتنا.';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeWelcome => 'أهلاً بك، أنتِ جاهزة للعمل';

  @override
  String get homeComingSoon =>
      'الحجوزات والعروض والمحفظة قادمة في التحديث القادم';

  @override
  String get homeSignedInAs => 'تم تسجيل الدخول بالرقم';

  @override
  String get devFillOtp => 'تعبئة الرمز تلقائياً (وضع التطوير)';

  @override
  String devOtpUnavailable(String reason) {
    return 'تعذّر جلب الرمز: $reason';
  }
}
