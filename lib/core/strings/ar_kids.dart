abstract final class ArKids {
  static String greeting(String name) => 'أهلًا $name! ماذا نلعب اليوم؟';
  static const listen = 'استمع';
  static const todayGame = 'لعبة اليوم';
  static const todayGameNote = 'نعدّ الفواكه معًا';

  static const gameTitle = 'لعبة العدّ';
  static const listenQuestion = 'استمع للسؤال';
  static String gameChallenge(int n, int total) => 'تحدٍّ $n من $total';
  static const tapToCount = 'اضغط كل فاكهة لتعدّها';
  static String countSoFar(int n) => 'العدد: $n';
  static const recount = 'إعادة العدّ';
  static const pickNumber = 'اختر الرقم الصحيح:';
  static const tipTitle = 'تلميح رِزمة';
  static const tipBody = 'المس كل فاكهة بإصبعك لتعدّها واحدة واحدة!';

  static String? numberWord(int n) => switch (n) {
    1 => 'واحد',
    2 => 'اثنان',
    3 => 'ثلاثة',
    4 => 'أربعة',
    5 => 'خمسة',
    6 => 'ستة',
    7 => 'سبعة',
    8 => 'ثمانية',
    9 => 'تسعة',
    10 => 'عشرة',
    _ => null,
  };
  static const gameHint = 'عدّ الفواكه بإصبعك: واحدة، اثنتان، ثلاث…';
  static String gameCorrect(String phrase) => 'صحيح! $phrase.';
  static String gameCorrectStar(String phrase) => 'صحيح! $phrase. نجمة جديدة!';
  static String gameRevealed(String phrase) => 'العدد الصحيح: $phrase.';
  static const gameEndTitle = 'أحسنت!';
  static String gameEndBody(int correct, int total) =>
      '$correct من $total إجابات صحيحة.';
  static String gameEndStars(int n) =>
      n == 0 ? 'لا نجوم جديدة هذه المرة' : '+$n نجوم';
  static const gameAgain = 'العب مرة أخرى';
  static const gameBackHome = 'العودة للرئيسية';
  static const gameNoSpeech = 'النطق الصوتي غير متاح على هذا الجهاز.';

  static String howMany(String singular) => 'كم $singular هنا؟';

  static String examKicker(String grade) => 'الصف $grade';
  static const examTitle = 'الاستعداد للامتحان';
  static const readiness = 'جاهزيتك للامتحان';
  static String readinessBased(int n) => switch (n) {
    1 => 'بناءً على آخر اختبار',
    2 => 'بناءً على آخر اختبارين',
    _ => 'بناءً على آخر $n اختبارات',
  };
  static const readinessNone = 'ابدأ أول اختبار لنقيس جاهزيتك';
  static const tileSummaries = 'ملخّصات';
  static String tileSummariesNote(int n) => switch (n) {
    0 => 'قريبًا',
    1 => 'درس واحد',
    2 => 'درسان',
    >= 3 && <= 10 => '$n دروس',
    _ => '$n درسًا',
  };
  static const tileMock = 'امتحان تجريبي';
  static String tileMockNote(int questions) => switch (questions) {
    0 => 'قريبًا',
    1 => 'سؤال واحد',
    2 => 'سؤالان',
    >= 3 && <= 10 => '$questions أسئلة',
    _ => '$questions سؤالًا',
  };
  static const tileBank = 'بنك الأسئلة';
  static const tileBankNote = 'حسب المفهوم';
  static const weakTitle = 'تحليل نقاط الضعف';
  static const weakEmpty = 'بعد أول اختبار تظهر هنا مفاهيمك الأضعف.';
  static const planTitle = 'خطة هذا الأسبوع';
  static const planToday = 'اليوم';
  static const planTomorrow = 'غدًا';
  static const planAfter = 'بعد غد';
  static String planReview(String concept) => 'مراجعة: $concept';
  static String planPractice(int n) => '$n تمارين مخصّصة';
  static const planQuiz = 'اختبار قصير';
  static const planStart = 'ابدأ بأول درس';
}
