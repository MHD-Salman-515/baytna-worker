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
  /// **'رصيد محفظتك تجاوز الحد المسموح. لن تصلك عروض عمل حتى تتم تسوية الرصيد، حتى لو كان حسابك موثّقاً.'**
  String get financialSuspendedBody;

  /// No description provided for @financialUnknownBody.
  ///
  /// In ar, this message translates to:
  /// **'وضعك المالي غير واضح. تواصلي مع دعم بيتنا.'**
  String get financialUnknownBody;

  /// No description provided for @homeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك، أنتِ جاهزة للعمل'**
  String get homeWelcome;

  /// No description provided for @homeComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات والعروض والمحفظة قادمة في التحديث القادم'**
  String get homeComingSoon;

  /// No description provided for @homeSignedInAs.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بالرقم'**
  String get homeSignedInAs;

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
