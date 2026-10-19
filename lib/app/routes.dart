abstract final class AppRoutes {
  static const launch = '/';
  static const welcome = '/welcome';
  static const createStep1 = '/create/step1';
  static const createStep2 = '/create/step2';
  static const profiles = '/profiles';
  static const pinPattern = '/pin/:id';
  static const home = '/home';
  static const account = '/account';
  static const studentCode = '/account/code';
  static const downloads = '/account/downloads';
  static const wardrobe = '/account/wardrobe';

  static const subjects = '/subjects';
  static const unitsPattern = '/subjects/:subjectId';
  static const lessonsPattern = '/units/:unitId';
  static const lessonPattern = '/lesson/:lessonId';
  static const partPattern = '/lesson/:lessonId/:part';
  static const progress = '/progress';
  static const kidsGame = '/kids/game';
  static const roundPattern = '/learn/round/:lessonId';
  static const quizPattern = '/learn/quiz/:lessonId';
  static const resultPattern = '/learn/result/:attemptId';
  static const roundEndPattern = '/learn/round-end/:attemptId';
  static const reviewPattern = '/learn/review/:lessonId';

  static String pin(String profileId) => '/pin/$profileId';
  static String units(String subjectId) => '/subjects/$subjectId';
  static String lessons(String unitId) => '/units/$unitId';
  static String lesson(String lessonId) => '/lesson/$lessonId';

  static String lessonPart(String lessonId, String part) =>
      '/lesson/$lessonId/$part';
  static String round(String lessonId) => '/learn/round/$lessonId';
  static String quiz(String lessonId) => '/learn/quiz/$lessonId';
  static String result(int attemptId) => '/learn/result/$attemptId';
  static String roundEnd(int attemptId) => '/learn/round-end/$attemptId';
  static String review(String lessonId) => '/learn/review/$lessonId';
}
