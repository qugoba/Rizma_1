abstract final class ArLearn {
  static const subjectsTitle = 'المواد';
  static const subjectsSearchHint = 'ابحث عن درس';
  static const searchNoResults = 'لا توجد دروس بهذا الاسم.';
  static const subjectNotStarted = 'لم تبدأ';
  static String subjectsOfGrade(String grade) => 'مواد $grade';
  static String subjectCurrent(String lesson) => 'الحالي: $lesson';

  static String subjectsCount(int n) => switch (n) {
    1 => 'مادة واحدة',
    2 => 'مادتان',
    >= 3 && <= 10 => '$n مواد',
    _ => '$n مادة',
  };

  static String lessonsLoaded(int n) => switch (n) {
    0 => 'لا دروس محمّلة',
    1 => 'درس واحد محمّل',
    2 => 'درسان محمّلان',
    >= 3 && <= 10 => '$n دروس محمّلة',
    _ => '$n درسًا محمّلًا',
  };

  static const unitsSubjectProgress = 'تقدّمك في المادة';
  static const unitsTitle = 'الوحدات';
  static const unitNotStarted = 'لم تبدأ';
  static const curriculumChip = 'المنهاج الفلسطيني';
  static const unitDone = 'مكتملة';
  static const unitActive = 'الوحدة النشطة';
  static const unitActiveLesson = 'الدرس النشط الآن';
  static const unitContinue = 'متابعة الوحدة';
  static const unitReview = 'مراجعة';
  static const unitStart = 'ابدأ';
  static String progressChip(int percent) => 'التقدّم $percent%';
  static String unitHeading(int order, String title) => 'الوحدة $order: $title';
  static String unitsCount(int n) => switch (n) {
    1 => 'وحدة واحدة',
    2 => 'وحدتان',
    >= 3 && <= 10 => '$n وحدات',
    _ => '$n وحدة',
  };

  static const _unitOrdinals = [
    'الأولى',
    'الثانية',
    'الثالثة',
    'الرابعة',
    'الخامسة',
    'السادسة',
    'السابعة',
    'الثامنة',
    'التاسعة',
    'العاشرة',
  ];

  static String unitOrdinal(int n) => n >= 1 && n <= _unitOrdinals.length
      ? 'الوحدة ${_unitOrdinals[n - 1]}'
      : 'الوحدة $n';

  static String lessonsCount(int n) => switch (n) {
    0 => 'لا دروس',
    1 => 'درس واحد',
    2 => 'درسان',
    >= 3 && <= 10 => '$n دروس',
    _ => '$n درسًا',
  };

  static String lessonsAndDone(int total, int done) =>
      '${lessonsCount(total)} · $done مكتملة';

  static String lessonsKicker(String subject, int unitNumber) =>
      '$subject · ${unitOrdinal(unitNumber)}';
  static String lessonsDoneOf(int done, int total) => '$done من $total';
  static String lessonNumber(int n) => 'الدرس $n';
  static const lessonDone = 'مكتمل';
  static const lessonsTitle = 'الدروس';
  static const lessonsPath = 'مسار دروس الوحدة';
  static const lessonCurrent = 'الدرس الحالي';
  static const lessonOpen = 'متاح للبدء';
  static const lessonContinue = 'متابعة';
  static String lessonNumbered(int n, String title) => '$n. $title';
  static String lessonsDoneSentence(int done, int total) =>
      'أنجزت $done من $total';
  static const lessonNotStarted = 'لم يبدأ';
  static String lessonInProgress(int percent) => 'قيد التعلّم · $percent%';
  static const downloadUnit = 'تحميل الوحدة كاملة';

  static String lessonKicker(int number, int unitNumber) =>
      'الدرس $number · ${unitOrdinal(unitNumber)}';
  static const lessonLoaded = 'محمّل';
  static String stationsDone(int done, int total) => '$done من $total محطات';
  static const stationStart = 'ابدأ هذه المحطة';
  static const lessonNoContent = 'محتوى هذا الدرس قيد الإعداد';
  static const lessonChoose =
      'اختر الطريقة التي تناسبك — لا يوجد ترتيب إلزامي.';
  static const lessonComingSoon = 'قريبًا';
  static const lessonSaved = 'تمت إضافة الدرس إلى المحفوظات.';
  static const lessonUnsaved = 'أُزيل الدرس من المحفوظات.';

  static const partPack = 'الرزمة التعليمية';
  static const partExplanation = 'شرح مبسّط';
  static const partSummary = 'ملخص الدرس';
  static const partVideo = 'فيديو الشرح';
  static const partWords = 'الكلمات والنطق';
  static const partPractice = 'تدرّب';

  static const roundPracticeTitle = 'تدريب';
  static const partQuiz = 'اختبر نفسك';

  static String packMeta(int pages) => 'رزمة · ${pagesCount(pages)}';
  static String pagesCount(int n) => switch (n) {
    1 => 'صفحة واحدة',
    2 => 'صفحتان',
    >= 3 && <= 10 => '$n صفحات',
    _ => '$n صفحة',
  };
  static String explanationMeta(int minutes) =>
      'قراءة · ${minutesCount(minutes)}';
  static String minutesCount(int n) => switch (n) {
    1 => 'دقيقة واحدة',
    2 => 'دقيقتان',
    >= 3 && <= 10 => '$n دقائق',
    _ => '$n دقيقة',
  };
  static String summaryMeta(int points) => switch (points) {
    1 => 'نقطة أساسية واحدة',
    2 => 'نقطتان أساسيتان',
    >= 3 && <= 10 => '$points نقاط أساسية',
    _ => '$points نقطة أساسية',
  };
  static String videoMeta(int minutes) => minutesCount(minutes);
  static String wordsMeta(int words) => switch (words) {
    1 => 'كلمة واحدة',
    2 => 'كلمتان',
    >= 3 && <= 10 => '$words كلمات',
    _ => '$words كلمة',
  };
  static String practiceMeta(int questions) =>
      '${questionsCount(questions)} تفاعلية';
  static String quizMeta(int questions) =>
      '${questionsCount(questions)} · بلا مؤقت';
  static String questionsCount(int n) => switch (n) {
    1 => 'سؤال واحد',
    2 => 'سؤالان',
    >= 3 && <= 10 => '$n أسئلة',
    _ => '$n سؤالًا',
  };

  static const partUnavailable = 'هذا الجزء غير متوفر لهذا الدرس بعد.';
  static const speechUnavailable = 'النطق الصوتي غير متاح على هذا الجهاز.';
  static const next = 'التالية';
  static const previous = 'السابقة';

  static String packKicker(String lesson) => '$lesson · المحتوى الأصلي';
  static const packTitle = 'الرزمة التعليمية';
  static const packLoaded = 'محمّل';
  static String packPage(int page, int total) => 'صفحة $page من $total';
  static String packPageNumber(int n) => 'ص $n';
  static const packTextSize = 'حجم الخط';

  static const explainTitle = 'شرح مبسّط';
  static String explainStep(int step, int total) => 'الخطوة $step من $total';
  static const explainFeedback = 'كيف تشعر تجاه هذه الخطوة؟ (اختياري)';
  static const explainGotIt = 'فهمت تمامًا';
  static const explainNeedMore = 'أحتاج توضيحًا';
  static const explainKicker = 'شرح';
  static const explainConcept = 'مفهوم مبسّط';
  static const explainListen = 'استمع للشرح';
  static const explainListenSub = 'قراءة صوتية لهذه الخطوة';
  static const explainVisual = 'المقارنة المرئية';
  static const explainVisualChip = 'مسطرة الكسور';
  static const explainEqual = '= متساويان تمامًا';
  static const explainNotice = 'لاحظ: المساحة الملوّنة هي نفسها في الأشرطة!';
  static const explainTipTitle = 'فكرة رِزمة الذكية';
  static const explainNeedMoreNote =
      'لا بأس! أعد قراءة الخطوة، أو جرّب التدريب، فالخطأ جزء من التعلّم.';
  static const explainNextSummary = 'التالي: الملخص';
  static const explainNext = 'الخطوة التالية';
  static const explainRead = 'اقرأ الشرح بصوت عالٍ';

  static const summaryTitle = 'ملخص الدرس';
  static String summaryPoints(int n) => switch (n) {
    1 => 'نقطة واحدة',
    2 => 'نقطتان',
    >= 3 && <= 10 => '$n نقاط',
    _ => '$n نقطة',
  };
  static String summaryCardOf(int n, int total) => 'البطاقة $n من $total';
  static String summaryRule(int n) => 'القاعدة $n';
  static String summaryCardN(int n) => 'بطاقة $n';
  static const summaryCardsTitle = 'بطاقات الملخص';
  static const summaryNextCard = 'التالية';
  static const summaryPrevCard = 'السابقة';
  static const summaryPracticeNow = 'تدرّب الآن';
  static const summaryVideo = 'الفيديو';

  static const videoTitle = 'فيديو الشرح';
  static String videoKicker(String lesson, int minutes) =>
      '$lesson · ${minutesCount(minutes)}';
  static const videoUnavailable = 'الفيديو غير محمّل على هذا الجهاز.';
  static const videoUnavailableNote = 'يتوفّر مع حزمة الفيديو حين تُنزَّل.';
  static String videoDownload(String size) => 'تنزيل الفيديو ($size)';
  static String videoDownloading(int percent) =>
      'جارٍ تنزيل الفيديو · $percent٪';
  static const videoWaitingWifi =
      'سيُنزَّل حين يتوفّر Wi-Fi، ويكمل من حيث توقف.';
  static const videoPlayFailed = 'تعذّر تشغيل الفيديو على هذا الهاتف.';
  static const videoWatchNow = 'شاهد الآن';
  static const videoSkipBack = 'رجوع 10 ثوانٍ';
  static const videoSkipForward = 'تقديم 10 ثوانٍ';
  static const videoReplay = 'إعادة من البداية';
  static const videoSpeedLabel = 'سرعة التشغيل';
  static const videoFullscreen = 'ملء الشاشة';
  static const videoExitFullscreen = 'الخروج من ملء الشاشة';
  static const videoPosition = 'موضع الفيديو';
  static const videoStreamNote = 'يعمل من الإنترنت. نزّله لتشاهده دون اتصال.';
  static String videoMobileData(double mbPerMinute) =>
      'المشاهدة على بيانات الهاتف تستهلك حوالي ${mbPerMinute.toStringAsFixed(1)} MB للدقيقة.';
  static const videoNeedsInternet =
      'لا اتصال الآن. شاهده حين يعود الإنترنت، أو نزّله لتشاهده دون اتصال.';
  static const videoStreamFailed =
      'انقطع الاتصال أثناء المشاهدة. نزّل الفيديو لتشاهده دون إنترنت.';
  static const videoPlay = 'تشغيل';
  static const videoPause = 'إيقاف مؤقت';
  static String videoSize(double mb) =>
      'حجم الفيديو · ${mb.toStringAsFixed(0)} MB';
  static const videoParts = 'أجزاء الفيديو';
  static const videoPracticeNow = 'تدرّب الآن';
  static const videoWatch = 'شاهد وتعلّم';
  static const videoHintTitle = 'رِزمة يذكّرك';
  static const videoHintBody =
      'بعد المشاهدة جرّب التدريب لتثبيت الفكرة وجمع النجوم.';

  static const roundNoQuestions = 'لا توجد أسئلة لهذا الدرس بعد.';
  static String roundQuestionOf(int n, int total) => 'سؤال $n من $total';
  static String quizHeader(String unit) => 'تحدّي $unit';
  static String quizSubtitle(String lesson) =>
      '$lesson · خذ وقتك، لا يوجد مؤقّت';
  static const quizRulesChip = 'بلا مؤقّت · بلا تلميحات';
  static const quizNoHintsTitle = 'في الاختبار لا توجد تلميحات';
  static const quizNoHintsBody =
      'أجب بما تعرفه؛ نتيجتك تحدّد المفاهيم التي تحتاج مراجعتها.';
  static const roundStars = 'نجوم';
  static const roundClose = 'إغلاق';
  static const quitTitle = 'تريد الخروج؟';
  static const quitBody = 'لن تُحفظ هذه الجولة.';
  static const quitStay = 'أكمل';
  static const quitLeave = 'اخرج';

  static const kindChoice = 'اختيار من متعدد';
  static const kindTrueFalse = 'صح أو خطأ';
  static const kindDragDrop = 'اسحب وأفلت';
  static const kindMatch = 'وصّل';
  static const kindOrder = 'رتّب';
  static const kindListen = 'استمع واختر';

  static const answerTrue = 'صح';
  static const answerFalse = 'خطأ';
  static const confirmAnswer = 'تأكيد الإجابة';
  static const checkOrder = 'تحقّق من الترتيب';
  static const confirmDisabledNote = 'يتفعّل الزر بعد وضع بطاقة في الفراغ';
  static const nextQuestion = 'السؤال التالي';
  static const finishRound = 'إنهاء الجولة';

  static const dragCards = 'البطاقات';
  static const dragHint = 'اسحب البطاقة إلى المربع المنقّط · أو اضغطها';
  static String matchProgress(int n, int total) => '$n من $total أزواج';
  static const matchHint = 'اضغط عنصرًا من اليمين ثم ما يطابقه من اليسار';
  static const orderHint = 'اضغط مطوّلًا على البطاقة واسحبها إلى مكانها';
  static const listenAgain = 'أعد';
  static const listenSlow = 'ببطء';
  static const listenNote = 'الصوت من جهازك';

  static String correctTitle(int stars) => switch (stars) {
    >= 3 => 'رائع! +$stars نجوم',
    2 => 'أحسنت! نجمتان بعد التلميح',
    _ => 'أحسنت! نجمة بعد التلميحين',
  };
  static const revealedTitle = 'لا بأس، هذا هو الجواب';
  static const solutionTitle = 'الحل خطوة بخطوة';
  static const hintTitle = 'ليس بعد... خذ تلميحًا';
  static String hintStage(int k, int n) => 'تلميح $k من $n';
  static const tryAgain = 'حاول مرة أخرى';
  static const lastHint = 'التلميح الأخير: الحل خطوة بخطوة';

  static const roundEndTitle = 'انتهت الجولة!';
  static String roundEndSubtitle(String name, int correct, int total) =>
      'أحسنت يا $name، $correct من $total إجابات صحيحة.';
  static const roundEndStarsLabel = 'نجمة';
  static const roundEndCorrectLabel = 'صحيحة';
  static const roundEndToReview = 'تحتاج مراجعة';
  static String hintsLabel(int n) => switch (n) {
    0 => 'بلا تلميحات',
    1 => 'تلميح',
    2 => 'تلميحان',
    >= 3 && <= 10 => 'تلميحات',
    _ => 'تلميحًا',
  };
  static const roundEndGames = 'ألعاب هذه الجولة';
  static const roundEndNoNewStars = 'لا نجوم جديدة: نلت هذه النجوم من قبل.';
  static const roundEndNew = 'جولة جديدة';
  static const backToLesson = 'العودة إلى الدرس';

  static String resultHeadingGood(String name) => 'أحسنت يا $name!';
  static String resultHeadingTry(String name) => 'حاول مجددًا يا $name';
  static const resultMastered = 'مفاهيم أتقنتها';
  static const resultYourScore = 'نتيجتك';
  static const resultNeedsReview = 'تحتاج مراجعة';
  static const resultReviewNote = 'جهّزنا لك خطة مراجعة قصيرة.';
  static const resultStartReview = 'ابدأ خطة المراجعة';

  static const reviewKicker = 'خطة المراجعة';
  static const reviewTitle = 'ما الذي تحتاج إلى مراجعته؟';
  static const reviewCurrentLevel = 'مستوى الإتقان الحالي';
  static const reviewPriority = 'الأولوية الأولى';
  static const reviewGoal = 'الهدف: 60% أو أكثر';
  static const reviewSteps = 'خطواتك التالية';
  static const reviewStepExplain = 'مراجعة الشرح';
  static const reviewStepVideo = 'شاهد الفيديو';
  static String reviewStepPractice(int n) => '$n تمارين مخصّصة';
  static const reviewStepPracticeNote = 'مبنية على مفهومك الأضعف';
  static const reviewStepQuiz = 'أعد الاختبار';
  static const reviewStepQuizNote = 'قِس تحسّنك';
  static String reviewContinue(String step) => 'تابع: $step';
  static const reviewDoneTitle = 'أتقنت هذا الدرس';
  static const reviewDoneBody = 'لا شيء يحتاج مراجعة الآن. أحسنت!';
  static const reviewQuote = 'الخطأ جزء من التعلّم. خطوة واحدة كل مرة!';

  static String wordsKicker(
    String subject,
    int unitNumber,
    int index,
    int total,
  ) => '$subject · ${unitOrdinal(unitNumber)} · كلمة $index من $total';
  static String wordsCardOf(int n, int total) => 'الكلمة $n من $total';
  static const wordListen = 'استمع';
  static const wordSlow = 'ببطء';
  static const wordsLesson = 'كلمات الدرس';
  static const wordsAudioReady = 'الصوت يعمل دون اتصال';
  static const wordsGame = 'لعبة «استمع واختر»';
  static const wordsGameNote = 'اسمع الكلمة واختر صورتها';

  static const filesTitle = 'ملفات الدرس';
  static const filesOnPhone = 'على الهاتف، يفتح دون إنترنت';
  static const filesOnline = 'يفتح من الإنترنت';
  static String filesDownloading(int percent) => 'جارٍ التنزيل · $percent٪';
  static String filesDownload(String size) => 'تنزيل ($size)';
  static const filesRemove = 'حذف من الهاتف';
  static const filesOpening = 'جارٍ فتح الملف…';
  static const filesOffline =
      'الملف غير منزَّل ولا يوجد اتصال الآن. نزّله وأنت متصل لتفتحه دون إنترنت.';
  static const filesFailed = 'تعذّر فتح الملف. حاول مرة أخرى.';
  static const filesRetry = 'حاول مرة أخرى';
  static String filesPage(int page, int? count) =>
      count == null ? 'صفحة $page' : 'صفحة $page من $count';
}
