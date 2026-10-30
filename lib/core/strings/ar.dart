import '../db/enums.dart';

abstract final class ArStrings {
  static const appName = 'رِزمة';

  static const back = 'رجوع';
  static const continueLabel = 'متابعة';

  static const welcomeOfflineReady = 'جاهز تمامًا للعمل دون إنترنت';
  static const welcomeHello = 'أهلًا بك!';
  static const welcomeCurriculum = 'المنهاج الفلسطيني';
  static const welcomeTagline = 'تطبيق التعلّم التفاعلي الممتع';
  static const welcomeCardTitle = 'الرزمة التعليمية كاملة بين يديك';
  static const welcomeCardBody =
      'شروحات تفاعلية وأسئلة وألعاب تدريب تعمل كاملة دون اتصال.';
  static const welcomeValue1Title = 'لكل أخ ملفه';
  static const welcomeValue1Subtitle = 'ملفات متعددة';
  static const welcomeValue2Title = 'تعلّم بالتدريب';
  static const welcomeValue2Subtitle = 'أنشطة وتحديات';
  static const welcomeValue3Title = 'بدون إنترنت';
  static const welcomeValue3Subtitle = 'يعمل أينما كنت';
  static const welcomeStart = 'ابدأ رحلة التعلّم';
  static const welcomeFooter = 'مجاني ومفتوح لجميع الطلاب في فلسطين';
  static const welcomeHaveProfile = 'لديّ ملف طالب على هذا الجهاز';

  static const createProfileTitle = 'إنشاء ملف';
  static const gradeStep = 'خطوة 1 من 2';
  static const step1Progress = 'الخطوة 1 من 2: المعلومات الأساسية';
  static const step1Heading = 'مَن أنتَ يا بطل؟';
  static const step1Sub = 'اكتب اسمك واختر صفك لنجهّز لك حزم الدروس.';
  static const gradeTitle = 'اختر صفك المدرسي';
  static const gradeTileLabel = 'الصف';
  static const stageBasic = 'المرحلة الأساسية';
  static const stageSecondary = 'المرحلة الثانوية';
  static const step1InfoTitle = 'حزم دروس صفك جاهزة للتحميل';
  static const step1InfoBody =
      'ستعمل الدروس والاختبارات دون إنترنت بعد تحميلها.';
  static const step1Next = 'التالي: تخصيص الملف';
  static const nameLabel = 'اسمك أو لقبك المفضّل';
  static const nameHint = 'اكتب اسمك';
  static const gradeGroup14 = 'الصفوف 1–4';
  static const gradeGroup14Hint = 'صور وصوت أكثر';
  static const gradeGroup58 = 'الصفوف 5–8';
  static const gradeGroup58Hint = 'تدريبات وتقدّم';
  static const gradeGroup912 = 'الصفوف 9–12';
  static const gradeGroup912Hint = 'ملخّصات وامتحانات';
  static const gradeChangeLater = 'يمكنك تعديل صفك لاحقًا من «حسابي»';

  static String continueWithGrade(int grade) => 'متابعة · الصف $grade';
  static String gradeSemantics(int grade) => 'الصف $grade';

  static const setupStep = 'خطوة 2 من 2';
  static const setupTitle = 'اجعل الملف لك';
  static const step2Progress = 'الخطوة 2 من 2: تخصيص الملف';
  static const setupSub = 'اختر لون تميمتك، وأضف رمزًا سريًا إن أردت.';
  static const setupPickColor = 'لون التميمة';
  static const setupPinTitle = 'رمز سري';
  static const setupPinSubtitle = 'يمنع الآخرين من فتح ملفك على هذا الجهاز';
  static const setupPinSwitch = 'تفعيل الرمز السري';
  static const setupPinHint = 'اختياري · يُنصح به للصفوف 7–12';
  static const setupClassTitle = 'رمز الصف (اختياري)';
  static const setupClassSubtitle = 'يعطيك إياه معلمك لتنضم إلى مجموعته';
  static const setupClassHint = 'مثال: GZ-5A';
  static const setupClassInvalid =
      'رمز الصف غير صحيح. استخدم حروفًا إنجليزية وأرقامًا وشرطة، مثل GZ-5A.';
  static const setupStart = 'ابدأ التعلّم';
  static const setupChangeLater = 'يمكنك تغيير كل هذا لاحقًا من حسابك.';
  static const setupCreateFailed = 'تعذّر إنشاء الملف، حاول مرة أخرى.';

  static String setupPreview(String name, int grade) =>
      '$name · ${gradeName(grade)}';

  static String colorName(ProfileColor color) => switch (color) {
    ProfileColor.teal => 'أخضر',
    ProfileColor.coral => 'مرجاني',
    ProfileColor.blue => 'أزرق',
    ProfileColor.purple => 'بنفسجي',
    ProfileColor.amber => 'عنبري',
  };

  static const pinSetupTitle = 'اختر رمزًا سريًّا من 4 أرقام';
  static const pinConfirmTitle = 'أعد إدخال الرمز للتأكيد';
  static const pinMismatch = 'الرمزان غير متطابقين، حاول مرة أخرى.';
  static const pinDelete = 'حذف';

  static String pinDotsSemantics(int filled, int length) =>
      'أُدخل $filled من $length أرقام';

  static const pickerTitle = 'من يتعلّم الآن؟';
  static const pickerSubtitle = 'اختر ملفك لتكمل من حيث توقفت.';
  static const pickerTopTitle = 'اختر ملفك';
  static const pickerReady = 'جاهز';
  static const pickerLocked = 'محمي';
  static const pickerSafeTitle = 'كل شيء محفوظ على هذا الجهاز';
  static const pickerSafeBody =
      'الدروس والنجوم والتقدّم تبقى معك حتى عند انقطاع الإنترنت أو الكهرباء.';
  static const pickerNewTitle = 'إضافة ملف جديد';
  static const pickerNewSubtitle = 'أضف ملفًا لأخ أو أخت';
  static const pickerRestoreTitle = 'لديك رمز طالب؟';
  static const pickerRestoreSubtitle = 'استعد تقدّمك على هذا الجهاز';
  static const pickerPrivacy =
      'الملفات محفوظة على هذا الجهاز · لا نطلب بريدًا ولا رقم هاتف';
  static const restoreNeedsInternet =
      'الاستعادة تحتاج اتصالًا بالإنترنت وستتوفّر قريبًا.';

  static const restoreTitle = 'استعادة ملف طالب';
  static const restoreHeading = 'أعِد تقدّمك إلى هذا الهاتف';
  static const restoreIntro =
      'اكتب رمز الطالب لتعود نتائجك ونجومك وملابس تميمتك.';
  static const restoreCodeLabel = 'رمز الطالب';
  static const restoreCheck = 'استعادة';
  static const restoreWrongCode =
      'لا يوجد طالب بهذا الرمز. تأكّد منه وحاول مرة أخرى.';
  static String restoreCodeLocked(int minutes) =>
      'محاولات كثيرة على هذا الرمز. حاول بعد ${minutesWord(minutes)}.';
  static String restoreDeviceLocked(int minutes) =>
      'محاولات كثيرة من هذا الهاتف. حاول بعد ${minutesWord(minutes)}.';
  static const restoreOffline =
      'لا يوجد اتصال بالإنترنت. الاستعادة تحتاج اتصالًا، جرّب عندما يتوفّر.';
  static const restoreUnavailable =
      'الاستعادة تحتاج خادم رِزمة، وهو غير متاح في هذه النسخة بعد.';
  static const restorePendingDeletion =
      'طُلب حذف هذا الملف نهائيًا. هل تريد إلغاء الحذف واستعادته؟';
  static const restoreCancelDeletion = 'إلغاء الحذف واستعادة الملف';
  static const restoreFoundTitle = 'وجدنا ملفك!';
  static const restoreNameLabel = 'اكتب اسمك';
  static const restoreNameNote =
      'الاسم لا يُحفظ على الإنترنت، لذلك نطلبه من جديد. يمكنك وضع رقم سري من «حسابي».';
  static const restoreFinish = 'ادخل إلى دروسك';
  static const restoreFailed = 'تعذّرت الاستعادة. حاول مرة أخرى.';

  static String minutesWord(int n) => switch (n) {
    <= 1 => 'دقيقة واحدة',
    2 => 'دقيقتين',
    >= 3 && <= 10 => '$n دقائق',
    _ => '$n دقيقة',
  };
  static const profileProtected = 'محمي برمز سري';

  static String profileSemantics(String name, String grade, bool locked) =>
      locked ? '$name، $grade، $profileProtected' : '$name، $grade';

  static String stars(int n) {
    if (n == 0) return '0 نجوم';
    if (n == 1) return 'نجمة واحدة';
    if (n == 2) return 'نجمتان';
    if (n >= 3 && n <= 10) return '$n نجوم';
    return '$n نجمة';
  }

  static String streakDays(int n) {
    if (n == 1) return 'يوم واحد متتالٍ';
    if (n == 2) return 'يومان متتاليان';
    if (n >= 3 && n <= 10) return '$n أيام متتالية';
    return '$n يومًا متتاليًا';
  }

  static const pinScreenTitle = 'الرمز السري';
  static const pinEnterTitle = 'أدخل رمزك السري';
  static const pinForgot = 'نسيت الرمز؟ استخدم رمز الطالب لإعادة تعيينه';
  static const pinWrong = 'الرمز غير صحيح، حاول مرة أخرى.';

  static String pinHello(String name) => 'مرحبًا $name';
  static String pinProfileChip(String name, String grade) =>
      'ملف $name • $grade';
  static const pinEnterSub = 'أدخل الأرقام الأربعة لفتح دروسك.';
  static const pinCalm = 'لا بأس، حاول مرة أخرى بهدوء.';
  static String pinLocked(int seconds) =>
      'تجاوزت عدد المحاولات. حاول بعد $seconds ثانية.';

  static const forgotTitle = 'استعادة الوصول';
  static const forgotCodeLabel = 'أدخل رمز الطالب';
  static const forgotCodeHint = 'RZ-XXXX-XXXX';
  static const forgotCodeWrong = 'رمز الطالب غير صحيح.';
  static const forgotVerify = 'تحقّق';
  static const forgotChoose = 'تم التحقق. ماذا تريد أن تفعل؟';
  static const forgotSetNew = 'تعيين رمز سري جديد';
  static const forgotRemove = 'إلغاء الرمز السري';

  static const homeAskToday = 'جاهز لدرس اليوم؟';

  static const offlineChip = 'دون إنترنت';
  static const homeFirstDaySubtitle = 'يومك الأول في رِزمة. لنبدأ معًا!';
  static const homeStartLesson = 'ابدأ الدرس';
  static const homeContinue = 'تابع الدرس';
  static const homeFirstMission = 'مهمتك الأولى';
  static const homeResumeKicker = 'تابع من حيث توقفت';
  static const homeFirstSteps = 'خطواتك الأولى';
  static const homeStepDownload = 'نزّل أول درس';
  static const homeStepDownloadHint = 'لتتعلّم حتى دون إنترنت';
  static const homeStepPractice = 'أكمل أول تدريب';
  static const homeStepPracticeHint = 'واربح نجومك الأولى';
  static const homeStepQuiz = 'جرّب أول اختبار';
  static const homeStepQuizHint = 'لتعرف ما تحتاج مراجعته';
  static const homeReviewPlaceholder =
      'ما يحتاج إلى مراجعة سيظهر هنا بعد أول اختبار.';
  static const homeNeedsReview = 'يحتاج إلى مراجعة';
  static const homeReviewButton = 'راجِع';
  static const homeMySubjects = 'موادي';
  static const homeShowAll = 'عرض الكل';
  static const homeNotStarted = 'لم تبدأ';
  static const homeLoadFailed = 'تعذّر تحميل الرئيسية.';
  static const homeLessonSoon = 'مشغّل الدروس قيد الإعداد وسيتوفّر قريبًا.';

  static String homeGreeting(String name) => 'مرحبًا، $name';
  static String homeFirstDayGreeting(String name) => 'أهلًا، $name';
  static String homeStartFirstLesson(String title) => 'ابدأ أول درس: $title';
  static String homeLessonMeta(int minutes) =>
      'نحو $minutes دقيقة · شرح وتدريب قصير';
  static String homeLessonTitle(int order, String title) =>
      'الدرس $order: $title';
  static String homeSubjectUnit(String subject, String unit) =>
      '$subject · $unit';
  static String homeFirstStepsCount(int done) => '$done من 3';
  static String homeMastery(int percent) => 'الإتقان $percent%';

  static const navHome = 'الرئيسية';
  static const navSubjects = 'المواد';
  static const navProgress = 'تقدّمي';
  static const navProfile = 'حسابي';
  static const navSectionSoon = 'هذا القسم قيد الإعداد وسيتوفّر قريبًا.';

  static const accountTitle = 'حسابي';
  static const accountProfileGroup = 'الملف';
  static const accountEditLook = 'تعديل المظهر واللون';
  static const accountStudentCode = 'رمز الطالب';
  static const accountSwitch = 'تبديل الطالب';
  static const accountPin = 'الرمز السري';
  static const accountPinOff = 'غير مفعّل';
  static const accountPinOn = 'مفعّل';
  static const accountLoadFailed = 'تعذّر تحميل حسابك.';

  static String accountSummary(int grade, int stars) =>
      '${gradeName(grade)} · ${ArStrings.stars(stars)}';

  static const accountStudyGroup = 'الدراسة';
  static const accountGrade = 'الصف';
  static const accountFontSize = 'حجم الخط';
  static const accountGameSounds = 'أصوات الألعاب';
  static const fontSizeSmall = 'صغير';
  static const fontSizeMedium = 'متوسط';
  static const fontSizeLarge = 'كبير';
  static const fontSheetTitle = 'حجم الخط';
  static const gradeSheetTitle = 'اختر صفّك';

  static String gradeContentSoon(int contentGrade) =>
      'محتوى هذا الصف لم يُضف بعد. ستواصل بمحتوى ${gradeName(contentGrade)} حتى يتوفّر.';
  static String gradeChanged(int grade) =>
      'تم تغيير الصف إلى ${gradeName(grade)}.';

  static const accountStorageGroup = 'التنزيل والتخزين';
  static const accountWifiOnly = 'التنزيل عبر Wi-Fi فقط';
  static const accountAutoVideo = 'تنزيل الفيديو تلقائيًا';
  static const accountAutoUpdate = 'تحديث الدروس تلقائيًا';
  static const accountManageDownloads = 'إدارة التنزيلات';
  static const accountStorageNote = 'يعمل مع التنزيلات عند توفرها.';

  static const accountGeneralGroup = 'عام';
  static const accountNightMode = 'الوضع الليلي';
  static const accountSoon = 'قريبًا';
  static const accountPrivacy = 'الخصوصية: بياناتك تبقى على جهازك';
  static const accountAbout = 'عن رزمة · مبادرة شبابية مجتمعية';
  static const privacyTitle = 'الخصوصية';
  static const privacy1 = 'ملفك وتقدّمك ونجومك محفوظة على هذا الجهاز.';
  static const privacy2 =
      'لا نطلب بريدًا إلكترونيًا ولا رقم هاتف ولا كلمة مرور.';
  static const privacy3 = 'الرمز السري يُحفظ مجزّأً ولا يُحفظ نصًّا.';
  static const aboutTitle = 'عن رزمة';
  static const about1 =
      'رِزمة مبادرة شبابية مجتمعية تحوّل المحتوى الذي يُقرأ إلى تعلّم يُمارس.';
  static const about2 = 'صُمّمت لتعمل دون إنترنت.';
  static const about3 = 'عناوين الدروس الحالية مؤقتة وتنتظر مراجعة معلمين.';
  static const close = 'إغلاق';

  static const accountDelete = 'حذف الملف الشخصي';
  static const deleteWarning =
      'سيُحذف هذا الملف نهائيًا من الجهاز ولا يمكن التراجع عن ذلك.';
  static const deleteItem1 = 'نجومك وتقدّمك في الدروس';
  static const deleteItem2 = 'نتائج التدريبات والاختبارات';
  static const deleteItem3 = 'إعداداتك ورمزك السري ورمز الطالب';
  static const deleteConfirm = 'احذف نهائيًا';
  static const deleteCancel = 'تراجع';
  static const deletePinTitle = 'أدخل رمزك السري لتأكيد الحذف';
  static const deleteFailed = 'تعذّر حذف الملف، حاول مرة أخرى.';

  static String deleteTitle(String name) => 'حذف ملف «$name»؟';

  static String deleteChooseTitle(String name) =>
      'ماذا تريد أن تفعل بملف «$name»؟';
  static const deleteRemoveOption = 'إزالة من هذا الهاتف فقط';
  static const deleteRemoveOptionNote =
      'نتائجك تبقى محفوظة، وتستعيدها برمز الطالب على أي هاتف.';
  static const deleteEverywhereOption = 'الحذف النهائي من كل مكان';
  static const deleteEverywhereOptionNote =
      'يُحذف من هذا الهاتف ومن الخادم. يمكن التراجع خلال 14 يومًا برمز الطالب.';
  static const deleteSyncing = 'نحفظ نتائجك على الخادم أولًا…';
  static String deleteSafe(String code) =>
      'نتائجك محفوظة على الخادم. لتستعيدها لاحقًا احتفظ برمز الطالب: $code';
  static String deleteUnsyncedWarning(int n) =>
      'لا يوجد اتصال الآن، و${resultsCount(n)} لم تُرفع بعد وستضيع إن أزلت الملف.';
  static const deleteRemoveConfirm = 'أزل من هذا الهاتف';
  static const deleteRemoveAnyway = 'أزل رغم ذلك';
  static const deleteEverywhereBody =
      'اكتب رمز الطالب للتأكيد. سيختفي الملف فورًا، ويُمسح من الخادم بعد 14 يومًا، ويمكنك إلغاء الحذف برمزك خلال هذه المدة.';
  static const deleteEverywhereConfirm = 'احذف من كل مكان';
  static const deleteEverywhereOffline =
      'لا يوجد اتصال بالإنترنت. الحذف من كل مكان يحتاج اتصالًا.';
  static const deleteEverywhereFailed =
      'تعذّر الحذف من الخادم الآن. حاول لاحقًا.';

  static String resultsCount(int n) => switch (n) {
    1 => 'نتيجة واحدة',
    2 => 'نتيجتان',
    >= 3 && <= 10 => '$n نتائج',
    _ => '$n نتيجة',
  };

  static const pinManageTitle = 'الرمز السري';
  static const pinChange = 'تغيير الرمز';
  static const pinDisable = 'إلغاء الرمز السري';
  static const pinEnabledNote = 'تم تفعيل الرمز السري.';
  static const pinChangedNote = 'تم تغيير الرمز السري.';
  static const pinDisabledNote = 'أُلغي الرمز السري.';

  static const codeTitle = 'رمز الطالب';
  static const codeYours = 'رمز الطالب الفريد الخاص بك';
  static String codeStudentCard(String name) => 'بطاقة الطالب: $name';
  static const codeBandTitle = 'رمز الاستعادة والربط';
  static const codeAlwaysValid = 'صالح دائمًا';
  static const codeKeepSafeTitle = 'احفظ هذا الرمز في مكان آمن';
  static const codeCopy = 'نسخ الرمز';
  static const codeShare = 'مشاركة الرمز';
  static const codeCopied = 'تم نسخ الرمز.';
  static const codeWhyTitle = 'لماذا هذا الرمز؟';
  static const codeWhy1 = 'انقل تقدّمك إلى جهاز جديد';
  static const codeWhy2 = 'معلمك يضيفك إلى مجموعته';
  static const codeWhy3 = 'لا يحتاج بريدًا ولا رقم هاتف';
  static const codeNeverSynced = 'لم يُحفظ على الإنترنت بعد';
  static const codeNothingPending = 'لا توجد نتائج بانتظار الاتصال';
  static const codeClassGroup = 'مجموعة الصف';
  static const codeKeepSafe =
      'احتفظ بالرمز في مكان آمن، أو اطلب من معلمك تسجيله.';

  static String codePending(int n) => switch (n) {
    1 => 'نتيجة واحدة بانتظار الاتصال',
    2 => 'نتيجتان بانتظار الاتصال',
    >= 3 && <= 10 => '$n نتائج بانتظار الاتصال',
    _ => '$n نتيجة بانتظار الاتصال',
  };
  static String codeClassLine(String code) => 'رمز الصف: $code';
  static String codeShareMessage(String code) => 'رمز الطالب في رِزمة: $code';

  static const _gradeOrdinals = [
    'الأول',
    'الثاني',
    'الثالث',
    'الرابع',
    'الخامس',
    'السادس',
    'السابع',
    'الثامن',
    'التاسع',
    'العاشر',
    'الحادي عشر',
    'الثاني عشر',
  ];

  static String gradeName(int grade) => 'الصف ${gradeOrdinal(grade)}';

  static String gradeOrdinal(int grade) => _gradeOrdinals[grade - 1];
}
