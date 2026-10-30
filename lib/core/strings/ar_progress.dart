abstract final class ArProgress {
  static const title = 'تقدّمي';
  static const overall = 'التقدّم العام';
  static const overallNoActivity = 'ابدأ أول درس لترى تقدّمك هنا.';
  static const overallKeepGoing = 'استمر، أنت تتقدّم!';
  static String streakDays(int n) => switch (n) {
    1 => 'يوم واحد متتالٍ',
    2 => 'يومان متتاليان',
    >= 3 && <= 10 => '$n أيام متتالية',
    _ => '$n يومًا متتاليًا',
  };
  static const statLessons = 'درسًا مكتملًا';
  static const statReview = 'مفاهيم للمراجعة';
  static const statQuizzes = 'اختبارات';
  static const statStars = 'نجمة';
  static const starsTotalTitle = 'مجموع النجوم';
  static const weekTitle = 'نشاطك هذا الأسبوع';
  static String weekTotal(int n) => switch (n) {
    0 => 'لا نشاط بعد',
    1 => 'نشاط واحد',
    2 => 'نشاطان',
    >= 3 && <= 10 => '$n أنشطة',
    _ => '$n نشاطًا',
  };

  static const dayLetters = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
  static const subjectsTitle = 'حسب المادة';
  static const subjectSoon = 'قريبًا';
  static const reviewTitle = 'ما يحتاج مراجعة';
  static const reviewEmpty = 'لا شيء يحتاج مراجعة الآن.';
  static const badgesTitle = 'شاراتي';

  static const badgeFirstLesson = 'درسك الأول';
  static const badgeStreak = '3 أيام';
  static const badgeStars = 'أول 100 نجمة';
  static const badgeListener = 'مستمع ماهر';
  static const badgeQuizAce = 'اختبار كامل';

  static const downloadsTitle = 'التنزيلات';
  static const downloadsKicker = 'التعلّم دون اتصال';
  static const offlineBannerTitle = 'كل المحتوى على جهازك';
  static const offlineBannerBody = 'الدروس تعمل كالمعتاد دون إنترنت.';
  static const downloadsTipTitle = 'تعلّم دون انقطاع';
  static const downloadsTipBody =
      'الأسئلة والنتائج والنجوم تُحفظ في هاتفك وتعمل حتى عند انقطاع الشبكة.';
  static const storageTitle = 'المساحة على الجهاز';
  static String storageNote(int lessons, int total) =>
      '${_lessons(lessons)} محمّلة من $total';
  static const installedTitle = 'المحتوى المحمّل';
  static const installedNote =
      'محتوى الدروس جزء من التطبيق، فلا حاجة إلى تنزيله ولا يمكن حذفه.';

  static const installedNoteDownloads =
      'نص الدروس يبقى على هاتفك دائمًا. يمكنك حذف الفيديو لتوفير المساحة.';

  static const updatesTitle = 'تحديثات الدروس';
  static const updatesNone = 'كل الدروس على هاتفك محدّثة.';
  static String updatesPending(String size) => '$size بانتظار التنزيل.';
  static const updatesRunning = 'جارٍ التنزيل…';
  static const updatesWaitingWifi =
      'بانتظار Wi-Fi. يمكنك التنزيل الآن عبر بيانات الهاتف.';
  static String updatesDownloadNow(String size) => 'نزّل الآن ($size)';
  static const updatesOffline =
      'لا اتصال بالإنترنت. يكمل التنزيل من حيث توقف حين يعود.';
  static const updatesStorageFull =
      'المساحة على الهاتف ممتلئة. احذف بعض الفيديو لتوفير المساحة.';
  static String updatesFailed(int n) => n == 1
      ? 'تعذّر تنزيل ملف واحد، وسيُعاد لاحقًا.'
      : 'تعذّر تنزيل $n ملفات، وسيُعاد لاحقًا.';
  static const updatesCheck = 'ابحث عن تحديثات';
  static const updatesChoose = 'اختر ما تنزّله';

  static const chooseTitle = 'اختر ما تنزّله';
  static const chooseKicker = 'الدروس والفيديو';
  static const chooseLessons = 'تحديثات ودروس جديدة';
  static const chooseVideos = 'الفيديو';
  static const chooseFiles = 'ملفات الدروس';
  static String chooseFilesCount(int n) => switch (n) {
    1 => 'ملف واحد',
    2 => 'ملفان',
    <= 10 => '$n ملفات',
    _ => '$n ملفًا',
  };
  static const chooseNew = 'درس جديد';
  static const chooseUpdate = 'تحديث';
  static const chooseOnPhone = 'على هاتفك';
  static const chooseNothing =
      'لا شيء متاح للتنزيل الآن. ابحث عن تحديثات حين يتوفّر الإنترنت.';
  static String chooseDownload(String size) => 'نزّل المحدد ($size)';
  static String chooseSelected(int n, String size) =>
      n == 0 ? 'لم تختر شيئًا بعد.' : 'المحدد: $n · $size';
  static const chooseMobileNote =
      'أنت على بيانات الهاتف: التنزيل سيستهلك منها.';
  static const chooseOffline = 'لا اتصال بالإنترنت الآن.';
  static const chooseAll = 'اختر الكل';
  static const chooseNone = 'إلغاء الكل';

  static const progressPreparing = 'جارٍ التحضير…';
  static String progressLine(int percent, String? speed, String? remaining) => [
    '$percent٪',
    ?speed,
    if (remaining != null) 'باقي $remaining',
  ].join(' · ');

  static String videoRowSize(String size) => 'فيديو · $size';
  static const videoRowDownload = 'تنزيل';
  static const videoRowRemove = 'حذف الفيديو';
  static String videoRowQueued(int percent) => 'يُنزَّل · $percent٪';
  static const installedEmpty = 'لا دروس محمّلة بعد.';
  static const syncTitle = 'بانتظار الاتصال';
  static String syncBody(int n) => n == 0
      ? 'كل نتائجك محفوظة على جهازك.'
      : '${_results(n)} محفوظة على جهازك وستُرفع تلقائيًا حين يتوفّر الإنترنت.';

  static const wardrobeTitle = 'خزانة رِزمة';
  static String wardrobeKicker(String name) => 'زيّن شخصيتك بالنجوم، يا $name';
  static const wardrobeBalance = 'رصيدك من النجوم';
  static const filterAll = 'الكل';
  static const filterColors = 'الألوان';
  static const filterAccessories = 'الإكسسوارات';
  static const itemEquipped = 'ترتديه';
  static const itemOwned = 'تملكه';
  static const itemEquip = 'ارتدِه';
  static const itemUnequip = 'اخلعه';
  static const itemUseColor = 'استخدمه';
  static const itemInUse = 'مستخدم';
  static String itemPrice(int n) => '$n';
  static const wardrobeNote =
      'النجوم تفتح الزينة فقط — كل الدروس مفتوحة دائمًا.';
  static const notEnoughStars = 'نجومك لا تكفي بعد. تابع التعلّم لتكسب المزيد!';
  static String purchased(String name) => 'صارت $name لك!';
  static const lockedLesson = 'أكمل درسًا';
  static const itemCap = 'قبعة التخرّج';
  static const itemScarf = 'الشال المطرّز';
  static const itemGlasses = 'نظارة القراءة';
  static const itemStar = 'نجمة الإتقان';
  static const colorTeal = 'اللون الأخضر';
  static const colorCoral = 'لون البرتقال';
  static const colorBlue = 'لون السماء';
  static const colorPurple = 'لون البنفسج';
  static const colorAmber = 'لون العسل';
  static const confirmBuyTitle = 'تأكيد الشراء';
  static String confirmBuyBody(String name, int price) =>
      'تشتري $name بـ $price من نجومك؟';
  static const buy = 'اشترِ';
  static const cancel = 'إلغاء';
  static const wardrobeOpen = 'خزانة رِزمة';
  static const wardrobeOpenNote = 'زيّن شخصيتك بالنجوم';

  static String _lessons(int n) => switch (n) {
    0 => 'لا دروس',
    1 => 'درس واحد',
    2 => 'درسان',
    >= 3 && <= 10 => '$n دروس',
    _ => '$n درسًا',
  };

  static String _results(int n) => switch (n) {
    1 => 'نتيجة واحدة',
    2 => 'نتيجتان',
    >= 3 && <= 10 => '$n نتائج',
    _ => '$n نتيجة',
  };
}
