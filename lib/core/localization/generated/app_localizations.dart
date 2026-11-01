import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name shown on splash and window title.
  ///
  /// In ar, this message translates to:
  /// **'بيتنا للعاملات'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'اعملي بثقة، بشروطك'**
  String get appTagline;

  /// Label of the button that switches to the OTHER language, written in that language.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get switchLanguage;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// Shown when a request is slow because the staging server is cold-starting.
  ///
  /// In ar, this message translates to:
  /// **'الخادم يستيقظ، قد يستغرق ذلك دقيقة…'**
  String get serverWakingUp;

  /// No description provided for @countrySelectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر بلدك'**
  String get countrySelectTitle;

  /// No description provided for @countrySelectSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نعرض الخدمات والأسعار حسب بلدك'**
  String get countrySelectSubtitle;

  /// No description provided for @countriesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دول متاحة حالياً'**
  String get countriesEmpty;

  /// No description provided for @phoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك المحمول وسنرسل لك رمز تحقق'**
  String get phoneSubtitle;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف المحمول'**
  String get phoneFieldLabel;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيحاً'**
  String get phoneInvalid;

  /// No description provided for @phoneRejected.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرقم غير صالح للبلد المختار'**
  String get phoneRejected;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من 6 أرقام المرسل إلى {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpVerify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get otpVerify;

  /// No description provided for @otpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إعادة الإرسال بعد {seconds, plural, =1{ثانية واحدة} =2{ثانيتين} few{{seconds} ثوانٍ} other{{seconds} ثانية}}'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResend;

  /// No description provided for @otpResent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد'**
  String get otpResent;

  /// No description provided for @otpInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح أو منتهي الصلاحية'**
  String get otpInvalid;

  /// No description provided for @otpTooManyAttempts.
  ///
  /// In ar, this message translates to:
  /// **'محاولات خاطئة كثيرة. اطلب رمزاً جديداً للمتابعة.'**
  String get otpTooManyAttempts;

  /// No description provided for @changeNumber.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get changeNumber;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @sessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. يرجى تسجيل الدخول مجدداً.'**
  String get sessionExpired;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال. تحقق من اتصالك بالإنترنت.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الخادم وقتاً طويلاً للرد. حاول مجدداً.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في الخادم. حاول لاحقاً.'**
  String get errorServer;

  /// No description provided for @errorRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة. انتظر قليلاً ثم حاول مجدداً.'**
  String get errorRateLimited;

  /// No description provided for @errorValidation.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المدخلة غير صحيحة.'**
  String get errorValidation;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'ليست لديك صلاحية للقيام بذلك.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'العنصر المطلوب غير موجود.'**
  String get errorNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع.'**
  String get errorUnknown;

  /// No description provided for @splashLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل حسابك'**
  String get splashLoadFailed;

  /// No description provided for @applyTitle.
  ///
  /// In ar, this message translates to:
  /// **'انضمي إلى بيتنا'**
  String get applyTitle;

  /// No description provided for @applySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قدّمي طلبك للعمل مع بيتنا. نراجع كل طلب بعناية لحماية العاملات والعائلات.'**
  String get applySubtitle;

  /// No description provided for @applyStepProfile.
  ///
  /// In ar, this message translates to:
  /// **'أكملي ملفك المهني: خبرتك ولغاتك والمدن التي تعملين فيها'**
  String get applyStepProfile;

  /// No description provided for @applyStepDocuments.
  ///
  /// In ar, this message translates to:
  /// **'ارفعي صور هويتك وشهادة عدم المحكومية'**
  String get applyStepDocuments;

  /// No description provided for @applyStepReview.
  ///
  /// In ar, this message translates to:
  /// **'يراجع فريق بيتنا طلبك، ثم تبدئين العمل بعد القبول'**
  String get applyStepReview;

  /// No description provided for @applyAction.
  ///
  /// In ar, this message translates to:
  /// **'تقديم طلب الانضمام'**
  String get applyAction;

  /// No description provided for @applyRoleNotGranted.
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم طلبك لكن لم تُحدَّث صلاحياتك بعد. حاولي مجدداً.'**
  String get applyRoleNotGranted;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملفك المهني'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'هذه المعلومات تساعد العائلات على اختيارك'**
  String get profileSubtitle;

  /// No description provided for @profileBioAr.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عنك (بالعربية)'**
  String get profileBioAr;

  /// No description provided for @profileBioEn.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عنك (بالإنجليزية) — اختياري'**
  String get profileBioEn;

  /// No description provided for @profileBioHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: خبرة 5 سنوات في تنظيف المنازل والطبخ'**
  String get profileBioHint;

  /// No description provided for @profileYears.
  ///
  /// In ar, this message translates to:
  /// **'سنوات الخبرة'**
  String get profileYears;

  /// No description provided for @profileYearsInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخلي عدداً صحيحاً بين 0 و60'**
  String get profileYearsInvalid;

  /// No description provided for @profileLanguages.
  ///
  /// In ar, this message translates to:
  /// **'اللغات التي تتحدثينها'**
  String get profileLanguages;

  /// No description provided for @profileLanguagesRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختاري لغة واحدة على الأقل'**
  String get profileLanguagesRequired;

  /// No description provided for @profileCity.
  ///
  /// In ar, this message translates to:
  /// **'مدينتك'**
  String get profileCity;

  /// No description provided for @profileCityRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختاري مدينتك'**
  String get profileCityRequired;

  /// No description provided for @profileAreas.
  ///
  /// In ar, this message translates to:
  /// **'المدن التي تعملين فيها'**
  String get profileAreas;

  /// No description provided for @profileAreasRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختاري مدينة واحدة على الأقل'**
  String get profileAreasRequired;

  /// No description provided for @profileNoCities.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مدن متاحة في بلدك حالياً'**
  String get profileNoCities;

  /// No description provided for @profileSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ومتابعة'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ ملفك'**
  String get profileSaved;

  /// No description provided for @languageAr.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageAr;

  /// No description provided for @languageKu.
  ///
  /// In ar, this message translates to:
  /// **'الكردية'**
  String get languageKu;

  /// No description provided for @languageEn.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get languageEn;

  /// No description provided for @languageTr.
  ///
  /// In ar, this message translates to:
  /// **'التركية'**
  String get languageTr;

  /// No description provided for @languageFr.
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية'**
  String get languageFr;

  /// No description provided for @documentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوثائق'**
  String get documentsTitle;

  /// No description provided for @documentsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'صوّري الوثائق كاملة وبإضاءة جيدة حتى تكون كل الكتابة واضحة'**
  String get documentsSubtitle;

  /// No description provided for @documentsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'تُرسل وثائقك مباشرة إلى فريق المراجعة في بيتنا ولا تُحفظ على هاتفك.'**
  String get documentsPrivacy;

  /// No description provided for @documentNationalIdFront.
  ///
  /// In ar, this message translates to:
  /// **'الهوية — الوجه الأمامي'**
  String get documentNationalIdFront;

  /// No description provided for @documentNationalIdBack.
  ///
  /// In ar, this message translates to:
  /// **'الهوية — الوجه الخلفي'**
  String get documentNationalIdBack;

  /// No description provided for @documentCriminalRecord.
  ///
  /// In ar, this message translates to:
  /// **'شهادة عدم المحكومية'**
  String get documentCriminalRecord;

  /// No description provided for @documentOther.
  ///
  /// In ar, this message translates to:
  /// **'وثيقة أخرى'**
  String get documentOther;

  /// No description provided for @documentStateMissing.
  ///
  /// In ar, this message translates to:
  /// **'مطلوبة'**
  String get documentStateMissing;

  /// No description provided for @documentStatePending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get documentStatePending;

  /// No description provided for @documentStateApproved.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get documentStateApproved;

  /// No description provided for @documentStateRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get documentStateRejected;

  /// No description provided for @documentStateExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهية الصلاحية'**
  String get documentStateExpired;

  /// No description provided for @documentStateReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة للرفع'**
  String get documentStateReady;

  /// No description provided for @documentRejectedReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض: {reason}'**
  String documentRejectedReason(String reason);

  /// No description provided for @documentExpiresOn.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي صلاحيتها في {date}'**
  String documentExpiresOn(String date);

  /// No description provided for @documentSourceCamera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get documentSourceCamera;

  /// No description provided for @documentSourceGallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get documentSourceGallery;

  /// No description provided for @documentSourceFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف PDF'**
  String get documentSourceFile;

  /// No description provided for @documentChoose.
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get documentChoose;

  /// No description provided for @documentReplace.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get documentReplace;

  /// No description provided for @documentUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع'**
  String get documentUpload;

  /// No description provided for @documentDiscard.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get documentDiscard;

  /// No description provided for @documentExpiryLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء الصلاحية'**
  String get documentExpiryLabel;

  /// No description provided for @documentExpiryPick.
  ///
  /// In ar, this message translates to:
  /// **'اختاري تاريخ الانتهاء المكتوب على الشهادة'**
  String get documentExpiryPick;

  /// No description provided for @documentUploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرفع… {percent}٪'**
  String documentUploading(int percent);

  /// No description provided for @documentUploadingUnknown.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرفع…'**
  String get documentUploadingUnknown;

  /// No description provided for @documentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الوثيقة'**
  String get documentUploaded;

  /// No description provided for @documentTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'الملف أكبر من 5 ميغابايت. التقطي صورة جديدة أو اختاري ملفاً أصغر.'**
  String get documentTooLarge;

  /// No description provided for @documentTypeNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'نوع الملف غير مدعوم. المسموح: صورة JPEG أو PNG، أو ملف PDF.'**
  String get documentTypeNotAllowed;

  /// No description provided for @documentExpiryRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخلي تاريخ انتهاء صلاحية في المستقبل'**
  String get documentExpiryRequired;

  /// No description provided for @documentDeletionLocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعديل الوثائق أثناء مراجعة طلبك'**
  String get documentDeletionLocked;

  /// No description provided for @documentPdfPreview.
  ///
  /// In ar, this message translates to:
  /// **'ملف PDF · {size}'**
  String documentPdfPreview(String size);

  /// No description provided for @documentsDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get documentsDone;

  /// No description provided for @documentsAllUploaded.
  ///
  /// In ar, this message translates to:
  /// **'رُفعت كل الوثائق المطلوبة. يمكنك الآن إرسال طلبك للمراجعة.'**
  String get documentsAllUploaded;

  /// No description provided for @statusTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبك'**
  String get statusTitle;

  /// No description provided for @statusDraftTitle.
  ///
  /// In ar, this message translates to:
  /// **'أكملي طلبك'**
  String get statusDraftTitle;

  /// No description provided for @statusDraftBody.
  ///
  /// In ar, this message translates to:
  /// **'بقيت خطوات قليلة قبل إرسال طلبك للمراجعة.'**
  String get statusDraftBody;

  /// No description provided for @statusPendingTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبك قيد المراجعة'**
  String get statusPendingTitle;

  /// No description provided for @statusPendingBody.
  ///
  /// In ar, this message translates to:
  /// **'سنخبرك هنا فور انتهاء المراجعة. لا يمكنك استقبال طلبات عمل قبل القبول.'**
  String get statusPendingBody;

  /// No description provided for @statusSubmittedAt.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل في {date}'**
  String statusSubmittedAt(String date);

  /// No description provided for @statusWaitingMinutes.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة منذ {count, plural, =0{أقل من دقيقة} =1{دقيقة} =2{دقيقتين} few{{count} دقائق} other{{count} دقيقة}}'**
  String statusWaitingMinutes(int count);

  /// No description provided for @statusWaitingHours.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة منذ {count, plural, =1{ساعة} =2{ساعتين} few{{count} ساعات} other{{count} ساعة}}'**
  String statusWaitingHours(int count);

  /// No description provided for @statusWaitingDays.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة منذ {count, plural, =1{يوم} =2{يومين} few{{count} أيام} other{{count} يوماً}}'**
  String statusWaitingDays(int count);

  /// No description provided for @statusRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يُقبل طلبك بعد'**
  String get statusRejectedTitle;

  /// No description provided for @statusRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'صحّحي ما يلي ثم أعيدي إرسال طلبك.'**
  String get statusRejectedBody;

  /// No description provided for @statusRejectedReason.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة فريق المراجعة'**
  String get statusRejectedReason;

  /// No description provided for @statusDocumentsToReplace.
  ///
  /// In ar, this message translates to:
  /// **'وثائق يجب استبدالها'**
  String get statusDocumentsToReplace;

  /// No description provided for @statusSuspendedTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موقوف'**
  String get statusSuspendedTitle;

  /// No description provided for @statusSuspendedBody.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك العمل حالياً. تواصلي مع دعم بيتنا لمعرفة السبب وكيفية رفع الإيقاف.'**
  String get statusSuspendedBody;

  /// No description provided for @statusApprovedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم قبولك!'**
  String get statusApprovedTitle;

  /// No description provided for @statusApprovedBody.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موثّق ويمكنك البدء بالعمل.'**
  String get statusApprovedBody;

  /// No description provided for @statusUnknownTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد حالة طلبك'**
  String get statusUnknownTitle;

  /// No description provided for @statusUnknownBody.
  ///
  /// In ar, this message translates to:
  /// **'حدّثي الصفحة، وإن استمرت المشكلة تواصلي مع دعم بيتنا.'**
  String get statusUnknownBody;

  /// No description provided for @statusChecklistTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات'**
  String get statusChecklistTitle;

  /// No description provided for @statusStepProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف المهني'**
  String get statusStepProfile;

  /// No description provided for @statusStepDocuments.
  ///
  /// In ar, this message translates to:
  /// **'الوثائق المطلوبة'**
  String get statusStepDocuments;

  /// No description provided for @statusStepDone.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusStepDone;

  /// No description provided for @statusStepTodo.
  ///
  /// In ar, this message translates to:
  /// **'غير مكتمل'**
  String get statusStepTodo;

  /// No description provided for @statusEditProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف'**
  String get statusEditProfile;

  /// No description provided for @statusOpenDocuments.
  ///
  /// In ar, this message translates to:
  /// **'الوثائق'**
  String get statusOpenDocuments;

  /// No description provided for @statusSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمراجعة'**
  String get statusSubmit;

  /// No description provided for @statusResubmit.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال للمراجعة'**
  String get statusResubmit;

  /// No description provided for @statusSubmitBlocked.
  ///
  /// In ar, this message translates to:
  /// **'أكملي الخطوات أعلاه أولاً'**
  String get statusSubmitBlocked;

  /// No description provided for @statusSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك للمراجعة'**
  String get statusSubmitted;

  /// No description provided for @statusMissingDocuments.
  ///
  /// In ar, this message translates to:
  /// **'بعض الوثائق المطلوبة ناقصة أو مرفوضة أو منتهية الصلاحية'**
  String get statusMissingDocuments;

  /// No description provided for @statusTransitionConflict.
  ///
  /// In ar, this message translates to:
  /// **'تغيّرت حالة طلبك. تم تحديث الصفحة.'**
  String get statusTransitionConflict;

  /// No description provided for @statusContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get statusContinue;

  /// No description provided for @statusPullToRefresh.
  ///
  /// In ar, this message translates to:
  /// **'اسحبي للأسفل للتحديث'**
  String get statusPullToRefresh;

  /// No description provided for @statusRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get statusRefresh;

  /// No description provided for @accountSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابك'**
  String get accountSectionTitle;

  /// No description provided for @verificationLabel.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق'**
  String get verificationLabel;

  /// No description provided for @verificationDraft.
  ///
  /// In ar, this message translates to:
  /// **'غير مكتمل'**
  String get verificationDraft;

  /// No description provided for @verificationPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get verificationPending;

  /// No description provided for @verificationApproved.
  ///
  /// In ar, this message translates to:
  /// **'موثّقة'**
  String get verificationApproved;

  /// No description provided for @verificationRejected.
  ///
  /// In ar, this message translates to:
  /// **'بحاجة لتعديل'**
  String get verificationRejected;

  /// No description provided for @verificationSuspended.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get verificationSuspended;

  /// No description provided for @verificationUnknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get verificationUnknown;

  /// No description provided for @financialLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوضع المالي'**
  String get financialLabel;

  /// No description provided for @financialActive.
  ///
  /// In ar, this message translates to:
  /// **'سليم'**
  String get financialActive;

  /// No description provided for @financialSuspended.
  ///
  /// In ar, this message translates to:
  /// **'موقوف مالياً'**
  String get financialSuspended;

  /// No description provided for @financialUnknown.
  ///
  /// In ar, this message translates to:
  /// **'مقيّد'**
  String get financialUnknown;

  /// No description provided for @financialSuspendedBody.
  ///
  /// In ar, this message translates to:
  /// **'رصيد محفظتك تجاوز الحد المسموح. لن تصلك طلبات جديدة حتى تتم تسوية الرصيد، ويمكنك إكمال عملك الحالي.'**
  String get financialSuspendedBody;

  /// No description provided for @financialUnknownBody.
  ///
  /// In ar, this message translates to:
  /// **'وضعك المالي غير واضح. تواصلي مع دعم بيتنا.'**
  String get financialUnknownBody;

  /// No description provided for @tabJobs.
  ///
  /// In ar, this message translates to:
  /// **'الأعمال'**
  String get tabJobs;

  /// No description provided for @tabWork.
  ///
  /// In ar, this message translates to:
  /// **'عملي'**
  String get tabWork;

  /// No description provided for @tabWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get tabWallet;

  /// No description provided for @loadMore.
  ///
  /// In ar, this message translates to:
  /// **'تحميل المزيد'**
  String get loadMore;

  /// No description provided for @jobsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أعمالي'**
  String get jobsTitle;

  /// No description provided for @jobsRequests.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات ({count})'**
  String jobsRequests(int count);

  /// No description provided for @jobsActive.
  ///
  /// In ar, this message translates to:
  /// **'الحالية ({count})'**
  String jobsActive(int count);

  /// No description provided for @jobsHistory.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get jobsHistory;

  /// No description provided for @jobsRequestsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بانتظار ردك الآن. ستظهر هنا فور وصولها.'**
  String get jobsRequestsEmpty;

  /// No description provided for @jobsActiveEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أعمال مقبولة حالياً.'**
  String get jobsActiveEmpty;

  /// No description provided for @jobsHistoryEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أعمال سابقة بعد.'**
  String get jobsHistoryEmpty;

  /// No description provided for @jobsExpiredNote.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الرد على هذا الطلب.'**
  String get jobsExpiredNote;

  /// No description provided for @jobsBannerFinancial.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موقوف مالياً: لن تصلك طلبات جديدة حتى تتم تسوية محفظتك. أعمالك الحالية مستمرة.'**
  String get jobsBannerFinancial;

  /// No description provided for @jobsBannerUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'أنتِ غير متاحة الآن، فلن تصلك طلبات جديدة.'**
  String get jobsBannerUnavailable;

  /// No description provided for @bookingStatusSearching.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get bookingStatusSearching;

  /// No description provided for @bookingStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار ردك'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get bookingStatusAccepted;

  /// No description provided for @bookingStatusOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get bookingStatusOnTheWay;

  /// No description provided for @bookingStatusArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصلتِ'**
  String get bookingStatusArrived;

  /// No description provided for @bookingStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ العمل'**
  String get bookingStatusInProgress;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get bookingStatusCompleted;

  /// No description provided for @bookingStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get bookingStatusRejected;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingStatusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي المهلة'**
  String get bookingStatusExpired;

  /// No description provided for @bookingStatusNoShow.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم الحضور'**
  String get bookingStatusNoShow;

  /// No description provided for @bookingStatusUnknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get bookingStatusUnknown;

  /// No description provided for @bookingAnswerWithin.
  ///
  /// In ar, this message translates to:
  /// **'أجيبي خلال {time}'**
  String bookingAnswerWithin(String time);

  /// No description provided for @bookingDeadlinePassed.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الرد'**
  String get bookingDeadlinePassed;

  /// No description provided for @bookingPlaceYourCity.
  ///
  /// In ar, this message translates to:
  /// **'{city} — داخل مدينتك'**
  String bookingPlaceYourCity(String city);

  /// No description provided for @bookingPlaceOtherCity.
  ///
  /// In ar, this message translates to:
  /// **'{city} — نحو {km} كم بين مركزَي المدينتين'**
  String bookingPlaceOtherCity(String city, int km);

  /// No description provided for @bookingHiddenUntilAccepted.
  ///
  /// In ar, this message translates to:
  /// **'هذا كل ما يمكن معرفته عن الموقع الآن. العنوان الدقيق والمسافة ورقم العميل يظهرون بعد القبول فقط.'**
  String get bookingHiddenUntilAccepted;

  /// No description provided for @bookingFloor.
  ///
  /// In ar, this message translates to:
  /// **'الطابق: {floor}'**
  String bookingFloor(String floor);

  /// No description provided for @bookingOpenMap.
  ///
  /// In ar, this message translates to:
  /// **'فتح الخريطة'**
  String get bookingOpenMap;

  /// No description provided for @bookingCannotOpen.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح التطبيق المطلوب'**
  String get bookingCannotOpen;

  /// No description provided for @bookingDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة المتوقعة: {duration}'**
  String bookingDuration(String duration);

  /// No description provided for @bookingCustomerNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة من العميل'**
  String get bookingCustomerNote;

  /// No description provided for @durationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count} د'**
  String durationMinutes(int count);

  /// No description provided for @durationHours.
  ///
  /// In ar, this message translates to:
  /// **'{count} س'**
  String durationHours(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{hours} س {minutes} د'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @bookingWorkingFor.
  ///
  /// In ar, this message translates to:
  /// **'مدة العمل حتى الآن'**
  String get bookingWorkingFor;

  /// No description provided for @bookingEstimatedEarnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباحك المتوقعة (تقديرية)'**
  String get bookingEstimatedEarnings;

  /// No description provided for @bookingEstimateFixed.
  ///
  /// In ar, this message translates to:
  /// **'بعد خصم عمولة بيتنا.'**
  String get bookingEstimateFixed;

  /// No description provided for @bookingEstimateHourly.
  ///
  /// In ar, this message translates to:
  /// **'تقدير لمدة {hours} س بعد خصم العمولة. الرقم النهائي يُحسب من وقت عملك الفعلي عند الإنهاء.'**
  String bookingEstimateHourly(String hours);

  /// No description provided for @bookingEstimateHourlyNoHours.
  ///
  /// In ar, this message translates to:
  /// **'تقدير بعد خصم العمولة. الرقم النهائي يُحسب من وقت عملك الفعلي عند الإنهاء.'**
  String get bookingEstimateHourlyNoHours;

  /// No description provided for @bookingMinimumHours.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى {hours, plural, =1{ساعة واحدة} =2{ساعتين} few{{hours} ساعات} other{{hours} ساعة}}.'**
  String bookingMinimumHours(int hours);

  /// No description provided for @bookingFinalEarnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباحك النهائية'**
  String get bookingFinalEarnings;

  /// No description provided for @bookingEstimateWas.
  ///
  /// In ar, this message translates to:
  /// **'كان التقدير'**
  String get bookingEstimateWas;

  /// No description provided for @bookingTimeWorked.
  ///
  /// In ar, this message translates to:
  /// **'وقت العمل الفعلي'**
  String get bookingTimeWorked;

  /// No description provided for @bookingHoursCharged.
  ///
  /// In ar, this message translates to:
  /// **'الساعات المحتسبة'**
  String get bookingHoursCharged;

  /// No description provided for @bookingCommissionCharged.
  ///
  /// In ar, this message translates to:
  /// **'العمولة المخصومة من محفظتك'**
  String get bookingCommissionCharged;

  /// No description provided for @bookingDifferenceMinimum.
  ///
  /// In ar, this message translates to:
  /// **'عملتِ أقل من الحد الأدنى، فاحتُسب الحد الأدنى ({hours, plural, =1{ساعة واحدة} =2{ساعتين} few{{hours} ساعات} other{{hours} ساعة}}) بدل الساعات المقدّرة. هذا الفرق طبيعي وليس خصماً عليك.'**
  String bookingDifferenceMinimum(int hours);

  /// No description provided for @bookingDifferenceActualTime.
  ///
  /// In ar, this message translates to:
  /// **'الأجر بالساعة يُحسب من وقت عملك الفعلي، لا من المدة المقدّرة عند الحجز، لذلك اختلف الرقم عن التقدير.'**
  String get bookingDifferenceActualTime;

  /// No description provided for @bookingDifferenceGeneric.
  ///
  /// In ar, this message translates to:
  /// **'تحدد الرقم النهائي عند إنهاء العمل، لذلك اختلف عن التقدير.'**
  String get bookingDifferenceGeneric;

  /// No description provided for @bookingSeeWallet.
  ///
  /// In ar, this message translates to:
  /// **'عرض محفظتي'**
  String get bookingSeeWallet;

  /// No description provided for @bookingCancelledByCustomer.
  ///
  /// In ar, this message translates to:
  /// **'ألغى العميل هذا الحجز'**
  String get bookingCancelledByCustomer;

  /// No description provided for @bookingCancelledByYou.
  ///
  /// In ar, this message translates to:
  /// **'ألغيتِ هذا الحجز'**
  String get bookingCancelledByYou;

  /// No description provided for @bookingAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get bookingAccept;

  /// No description provided for @bookingReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get bookingReject;

  /// No description provided for @bookingCannotAcceptSuspended.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك قبول طلبات جديدة حتى تتم تسوية محفظتك.'**
  String get bookingCannotAcceptSuspended;

  /// No description provided for @bookingRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'لماذا ترفضين هذا الطلب؟'**
  String get bookingRejectTitle;

  /// No description provided for @bookingRejectConfirm.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get bookingRejectConfirm;

  /// No description provided for @reasonRejectFar.
  ///
  /// In ar, this message translates to:
  /// **'المكان بعيد'**
  String get reasonRejectFar;

  /// No description provided for @reasonRejectBusy.
  ///
  /// In ar, this message translates to:
  /// **'لدي التزام في هذا الوقت'**
  String get reasonRejectBusy;

  /// No description provided for @reasonRejectNotSuitable.
  ///
  /// In ar, this message translates to:
  /// **'الطلب غير مناسب لي'**
  String get reasonRejectNotSuitable;

  /// No description provided for @reasonOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get reasonOther;

  /// No description provided for @bookingCancelAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء هذا الحجز'**
  String get bookingCancelAction;

  /// No description provided for @bookingCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'لماذا تلغين هذا الحجز؟'**
  String get bookingCancelTitle;

  /// No description provided for @bookingCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get bookingCancelConfirm;

  /// No description provided for @bookingCancelPenalty.
  ///
  /// In ar, this message translates to:
  /// **'سيُخصم {amount} من محفظتك عند الإلغاء.'**
  String bookingCancelPenalty(String amount);

  /// No description provided for @reasonCancelEmergency.
  ///
  /// In ar, this message translates to:
  /// **'ظرف طارئ'**
  String get reasonCancelEmergency;

  /// No description provided for @reasonCancelTransport.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الوصول'**
  String get reasonCancelTransport;

  /// No description provided for @reasonCancelCustomerAsked.
  ///
  /// In ar, this message translates to:
  /// **'طلب العميل الإلغاء'**
  String get reasonCancelCustomerAsked;

  /// No description provided for @bookingStepOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'انطلقتُ إلى العميل'**
  String get bookingStepOnTheWay;

  /// No description provided for @bookingStepArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصلتُ'**
  String get bookingStepArrived;

  /// No description provided for @bookingStepStart.
  ///
  /// In ar, this message translates to:
  /// **'بدء العمل'**
  String get bookingStepStart;

  /// No description provided for @bookingSwipeComplete.
  ///
  /// In ar, this message translates to:
  /// **'اسحبي لإنهاء العمل'**
  String get bookingSwipeComplete;

  /// No description provided for @bookingCompleteHint.
  ///
  /// In ar, this message translates to:
  /// **'عند الإنهاء يُحسب أجرك النهائي وتُخصم العمولة من محفظتك. لا يمكن التراجع.'**
  String get bookingCompleteHint;

  /// No description provided for @bookingErrorExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة هذا الطلب، ولم يعد بالإمكان الرد عليه.'**
  String get bookingErrorExpired;

  /// No description provided for @bookingErrorCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي هذا الحجز.'**
  String get bookingErrorCancelled;

  /// No description provided for @bookingErrorCompleted.
  ///
  /// In ar, this message translates to:
  /// **'هذا العمل مكتمل بالفعل.'**
  String get bookingErrorCompleted;

  /// No description provided for @bookingErrorStale.
  ///
  /// In ar, this message translates to:
  /// **'تغيّرت حالة هذا الحجز، وحدّثنا الصفحة لتعرضها كما هي الآن.'**
  String get bookingErrorStale;

  /// No description provided for @bookingErrorGate.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك قبول طلبات جديدة الآن. راجعي حالة حسابك ومحفظتك.'**
  String get bookingErrorGate;

  /// No description provided for @bookingErrorClash.
  ///
  /// In ar, this message translates to:
  /// **'يتعارض هذا الموعد مع عمل آخر لديك.'**
  String get bookingErrorClash;

  /// No description provided for @bookingErrorRefused.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تنفيذ هذه الخطوة الآن. حاولي مجدداً بعد قليل.'**
  String get bookingErrorRefused;

  /// No description provided for @bookingErrorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعد نجد هذا الحجز.'**
  String get bookingErrorNotFound;

  /// No description provided for @workTitle.
  ///
  /// In ar, this message translates to:
  /// **'عملي'**
  String get workTitle;

  /// No description provided for @workSchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول العمل الأسبوعي'**
  String get workSchedule;

  /// No description provided for @workScheduleHint.
  ///
  /// In ar, this message translates to:
  /// **'متى تستقبلين الحجوزات'**
  String get workScheduleHint;

  /// No description provided for @workServices.
  ///
  /// In ar, this message translates to:
  /// **'خدماتي وأسعاري'**
  String get workServices;

  /// No description provided for @workNoServices.
  ///
  /// In ar, this message translates to:
  /// **'لم تضيفي أي خدمة بعد. بدون خدمة لا يمكن حجزك.'**
  String get workNoServices;

  /// No description provided for @workAddService.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة'**
  String get workAddService;

  /// No description provided for @availabilityOn.
  ///
  /// In ar, this message translates to:
  /// **'أنا متاحة للعمل'**
  String get availabilityOn;

  /// No description provided for @availabilityOff.
  ///
  /// In ar, this message translates to:
  /// **'أنا غير متاحة الآن'**
  String get availabilityOff;

  /// No description provided for @availabilityIntentNote.
  ///
  /// In ar, this message translates to:
  /// **'هذا اختيارك أنتِ ويعبّر عن رغبتك في العمل فقط، وليس موافقة من بيتنا ولا يمنحك أي صلاحية.'**
  String get availabilityIntentNote;

  /// No description provided for @availabilityNoEffectNow.
  ///
  /// In ar, this message translates to:
  /// **'لن يكون لهذا الخيار أثر الآن، لأن حسابك لا يستطيع استقبال طلبات جديدة حالياً.'**
  String get availabilityNoEffectNow;

  /// No description provided for @pricingHourly.
  ///
  /// In ar, this message translates to:
  /// **'بالساعة'**
  String get pricingHourly;

  /// No description provided for @pricingBySize.
  ///
  /// In ar, this message translates to:
  /// **'حسب حجم المنزل'**
  String get pricingBySize;

  /// No description provided for @pricingFixed.
  ///
  /// In ar, this message translates to:
  /// **'سعر ثابت'**
  String get pricingFixed;

  /// No description provided for @pricingHourlyExplain.
  ///
  /// In ar, this message translates to:
  /// **'سعر لكل ساعة، مع حد أدنى من الساعات. يُحسب الأجر النهائي من الوقت الفعلي.'**
  String get pricingHourlyExplain;

  /// No description provided for @pricingBySizeExplain.
  ///
  /// In ar, this message translates to:
  /// **'سعر حسب عدد الغرف، على شكل شرائح.'**
  String get pricingBySizeExplain;

  /// No description provided for @pricingFixedExplain.
  ///
  /// In ar, this message translates to:
  /// **'سعر واحد للعمل كاملاً.'**
  String get pricingFixedExplain;

  /// No description provided for @priceSummaryHourly.
  ///
  /// In ar, this message translates to:
  /// **'{rate} بالساعة · حد أدنى {hours, plural, =1{ساعة واحدة} =2{ساعتين} few{{hours} ساعات} other{{hours} ساعة}}'**
  String priceSummaryHourly(String rate, int hours);

  /// No description provided for @priceSummaryFixed.
  ///
  /// In ar, this message translates to:
  /// **'{price} سعر ثابت'**
  String priceSummaryFixed(String price);

  /// No description provided for @priceSummaryBySize.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to} · حتى {rooms} غرف'**
  String priceSummaryBySize(String from, String to, int rooms);

  /// No description provided for @offeringPaused.
  ///
  /// In ar, this message translates to:
  /// **'متوقفة مؤقتاً'**
  String get offeringPaused;

  /// No description provided for @offeringAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة'**
  String get offeringAddTitle;

  /// No description provided for @offeringEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخدمة'**
  String get offeringEditTitle;

  /// No description provided for @offeringService.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة'**
  String get offeringService;

  /// No description provided for @offeringPricingModel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التسعير'**
  String get offeringPricingModel;

  /// No description provided for @offeringRange.
  ///
  /// In ar, this message translates to:
  /// **'المسموح: من {min} إلى {max} {unit}'**
  String offeringRange(String min, String max, String unit);

  /// No description provided for @offeringRangePerHour.
  ///
  /// In ar, this message translates to:
  /// **'للساعة'**
  String get offeringRangePerHour;

  /// No description provided for @offeringRangePerJob.
  ///
  /// In ar, this message translates to:
  /// **'للعمل'**
  String get offeringRangePerJob;

  /// No description provided for @offeringRangePerTier.
  ///
  /// In ar, this message translates to:
  /// **'لكل شريحة'**
  String get offeringRangePerTier;

  /// No description provided for @offeringNoRange.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نطاق سعر محدد لهذه الخدمة بعد.'**
  String get offeringNoRange;

  /// No description provided for @offeringHourlyRate.
  ///
  /// In ar, this message translates to:
  /// **'السعر بالساعة'**
  String get offeringHourlyRate;

  /// No description provided for @offeringFixedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الثابت'**
  String get offeringFixedPrice;

  /// No description provided for @offeringMinHours.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى من الساعات'**
  String get offeringMinHours;

  /// No description provided for @offeringMinHoursHint.
  ///
  /// In ar, this message translates to:
  /// **'إن انتهى العمل أبكر، يُحتسب هذا الحد.'**
  String get offeringMinHoursHint;

  /// No description provided for @offeringMinHoursInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى ساعة واحدة على الأقل'**
  String get offeringMinHoursInvalid;

  /// No description provided for @offeringTierRooms.
  ///
  /// In ar, this message translates to:
  /// **'حتى (غرف)'**
  String get offeringTierRooms;

  /// No description provided for @offeringTierPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get offeringTierPrice;

  /// No description provided for @offeringTierAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة شريحة'**
  String get offeringTierAdd;

  /// No description provided for @offeringTiersInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رتّبي الشرائح تصاعدياً: كل شريحة تغطي غرفاً أكثر من التي قبلها.'**
  String get offeringTiersInvalid;

  /// No description provided for @offeringPriceMissing.
  ///
  /// In ar, this message translates to:
  /// **'أدخلي السعر بأرقام صحيحة'**
  String get offeringPriceMissing;

  /// No description provided for @offeringOutOfRange.
  ///
  /// In ar, this message translates to:
  /// **'السعر يجب أن يكون بين {min} و{max}'**
  String offeringOutOfRange(String min, String max);

  /// No description provided for @offeringCurrencyFixed.
  ///
  /// In ar, this message translates to:
  /// **'العملة: {currency}. تُحدَّد عند إضافة الخدمة ولا يمكن تغييرها.'**
  String offeringCurrencyFixed(String currency);

  /// No description provided for @offeringActive.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة مفعّلة'**
  String get offeringActive;

  /// No description provided for @offeringActiveHint.
  ///
  /// In ar, this message translates to:
  /// **'أوقفيها مؤقتاً دون حذف أسعارك.'**
  String get offeringActiveHint;

  /// No description provided for @offeringDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الخدمة'**
  String get offeringDelete;

  /// No description provided for @offeringDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه الخدمة؟'**
  String get offeringDeleteTitle;

  /// No description provided for @offeringDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'لن تظهر للزبائن بعد الآن.'**
  String get offeringDeleteBody;

  /// No description provided for @offeringSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get offeringSave;

  /// No description provided for @offeringTypeNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التسعير هذه غير متاحة لهذه الخدمة.'**
  String get offeringTypeNotAllowed;

  /// No description provided for @offeringAlreadyExists.
  ///
  /// In ar, this message translates to:
  /// **'تقدّمين هذه الخدمة بالفعل. عدّليها بدل إضافتها مرة أخرى.'**
  String get offeringAlreadyExists;

  /// No description provided for @scheduleTitle.
  ///
  /// In ar, this message translates to:
  /// **'جدول العمل'**
  String get scheduleTitle;

  /// No description provided for @scheduleTimezone.
  ///
  /// In ar, this message translates to:
  /// **'كل الأوقات بتوقيت بلدك ({zone})، والساعة هناك الآن {now}، مهما كان توقيت هاتفك.'**
  String scheduleTimezone(String zone, String now);

  /// No description provided for @scheduleDayOff.
  ///
  /// In ar, this message translates to:
  /// **'عطلة'**
  String get scheduleDayOff;

  /// No description provided for @scheduleAddRange.
  ///
  /// In ar, this message translates to:
  /// **'فترة أخرى'**
  String get scheduleAddRange;

  /// No description provided for @scheduleExceptions.
  ///
  /// In ar, this message translates to:
  /// **'أيام استثنائية'**
  String get scheduleExceptions;

  /// No description provided for @scheduleExceptionsHint.
  ///
  /// In ar, this message translates to:
  /// **'أيام عطلة أو ساعات إضافية خارج جدولك المعتاد.'**
  String get scheduleExceptionsHint;

  /// No description provided for @scheduleBlocked.
  ///
  /// In ar, this message translates to:
  /// **'لا أعمل هذا اليوم'**
  String get scheduleBlocked;

  /// No description provided for @scheduleExtra.
  ///
  /// In ar, this message translates to:
  /// **'ساعات إضافية {range}'**
  String scheduleExtra(String range);

  /// No description provided for @scheduleAddBlocked.
  ///
  /// In ar, this message translates to:
  /// **'يوم عطلة'**
  String get scheduleAddBlocked;

  /// No description provided for @scheduleAddExtra.
  ///
  /// In ar, this message translates to:
  /// **'ساعات إضافية'**
  String get scheduleAddExtra;

  /// No description provided for @scheduleOverlap.
  ///
  /// In ar, this message translates to:
  /// **'هذه الفترات متداخلة'**
  String get scheduleOverlap;

  /// No description provided for @scheduleRangeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تبدأ الفترة قبل نهايتها'**
  String get scheduleRangeInvalid;

  /// No description provided for @scheduleInvalid.
  ///
  /// In ar, this message translates to:
  /// **'صحّحي الأوقات المعلّمة أولاً'**
  String get scheduleInvalid;

  /// No description provided for @scheduleSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الجدول'**
  String get scheduleSave;

  /// No description provided for @scheduleSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ جدولك'**
  String get scheduleSaved;

  /// No description provided for @walletTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get walletTitle;

  /// No description provided for @walletBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك'**
  String get walletBalance;

  /// No description provided for @walletRoomToFloor.
  ///
  /// In ar, this message translates to:
  /// **'يبقى {room} قبل الوصول إلى الحد الأدنى ({floor}). الرصيد السالب مسموح حتى هذا الحد.'**
  String walletRoomToFloor(String room, String floor);

  /// No description provided for @walletPastFloor.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزتِ الحد الأدنى ({floor}) بمقدار {over}.'**
  String walletPastFloor(String over, String floor);

  /// No description provided for @walletLowWarning.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك منخفض: وصل إلى {threshold} أو أقل. اشحني المحفظة قبل بلوغ الحد الأدنى كي لا يتوقف استقبال الطلبات.'**
  String walletLowWarning(String threshold);

  /// No description provided for @walletBelowFloor.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز رصيدك الحد الأدنى. يتوقف استقبال الطلبات الجديدة تلقائياً حتى الشحن، ويعود تلقائياً بعده.'**
  String get walletBelowFloor;

  /// No description provided for @walletTopupNote.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن شحن المحفظة من التطبيق حالياً: يسجّل فريق بيتنا الشحن يدوياً بعد الدفع له مباشرة. تواصلي مع الدعم للشحن.'**
  String get walletTopupNote;

  /// No description provided for @walletLedger.
  ///
  /// In ar, this message translates to:
  /// **'حركات المحفظة'**
  String get walletLedger;

  /// No description provided for @walletLedgerEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد.'**
  String get walletLedgerEmpty;

  /// No description provided for @entryTopup.
  ///
  /// In ar, this message translates to:
  /// **'شحن'**
  String get entryTopup;

  /// No description provided for @entryCommission.
  ///
  /// In ar, this message translates to:
  /// **'عمولة'**
  String get entryCommission;

  /// No description provided for @entryCancellationFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم إلغاء'**
  String get entryCancellationFee;

  /// No description provided for @entryAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية'**
  String get entryAdjustment;

  /// No description provided for @entryRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرداد'**
  String get entryRefund;

  /// No description provided for @entryReversal.
  ///
  /// In ar, this message translates to:
  /// **'عكس قيد'**
  String get entryReversal;

  /// No description provided for @entryOther.
  ///
  /// In ar, this message translates to:
  /// **'حركة'**
  String get entryOther;

  /// No description provided for @entryBalanceAfter.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد: {balance}'**
  String entryBalanceAfter(String balance);

  /// No description provided for @devFillOtp.
  ///
  /// In ar, this message translates to:
  /// **'تعبئة الرمز تلقائياً (وضع التطوير)'**
  String get devFillOtp;

  /// No description provided for @devOtpUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر جلب الرمز: {reason}'**
  String devOtpUnavailable(String reason);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
