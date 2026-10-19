import 'dart:convert';

import '../../core/db/app_database.dart';
import '../content/lesson_content.dart';
import 'round_engine.dart';

class RoundRecord {
  const RoundRecord({required this.attemptId, required this.earned});

  final int attemptId;

  final int earned;
}

class AttemptDetails {
  const AttemptDetails({
    required this.lessonId,
    required this.mode,
    required this.results,
    required this.rawStars,
    required this.masteryBefore,
    required this.masteryAfter,
  });

  factory AttemptDetails.fromJson(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    Map<String, double?> mastery(String key) => {
      for (final e in (j[key] as Map<String, dynamic>).entries)
        e.key: (e.value as num?)?.toDouble(),
    };
    return AttemptDetails(
      lessonId: j['lessonId'] as String,
      mode: RoundMode.values.byName(j['mode'] as String),
      results: [
        for (final r in j['questions'] as List<dynamic>)
          QuestionResult.fromJson(r as Map<String, dynamic>),
      ],
      rawStars: j['rawStars'] as int,
      masteryBefore: mastery('masteryBefore'),
      masteryAfter: mastery('masteryAfter'),
    );
  }

  final String lessonId;
  final RoundMode mode;
  final List<QuestionResult> results;

  final int rawStars;

  final Map<String, double?> masteryBefore;
  final Map<String, double?> masteryAfter;
}

class LearningRepository {
  LearningRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const quizPassPercent = 60;

  static String activityId(String lessonId, RoundMode mode) =>
      '$lessonId.${mode.name}';

  Future<void> completePart({
    required String profileId,
    required String lessonId,
    required LessonPart part,
    required LessonContent? content,
  }) async {
    final now = _now();
    await _db.activityDao.markPartDone(
      profileId: profileId,
      lessonId: lessonId,
      part: part,
      now: now,
    );
    final done = {
      for (final p in await _db.activityDao.getLessonParts(profileId))
        if (p.lessonId == lessonId) p.part,
    };
    final available = content?.parts ?? [part];
    final finished = available.where(done.contains).length;
    final total = available.isEmpty ? 1 : available.length;
    final fraction = (finished / total).clamp(0.0, 1.0);
    await _db.activityDao.upsertLessonProgress(
      profileId: profileId,
      lessonId: lessonId,
      status: fraction >= 1 ? LessonStatus.completed : LessonStatus.inProgress,
      progress: fraction,
      now: now,
    );
  }

  Future<RoundRecord> recordRound({
    required String profileId,
    required String lessonId,
    required RoundMode mode,
    required List<QuestionResult> results,
    required LessonContent? content,
  }) {
    return _db.transaction(() async {
      final now = _now();
      final dao = _db.activityDao;
      final activity = activityId(lessonId, mode);

      final raw = RoundEngine.starsEarned(results);
      final already = await dao.starsForActivity(profileId, activity);
      final earned = (raw - already).clamp(0, raw);

      final current = {
        for (final m in await dao.getMastery(profileId)) m.conceptId: m.mastery,
      };
      final before = <String, double?>{};
      final after = <String, double?>{};
      final running = {...current};
      for (final r in results) {
        before.putIfAbsent(r.concept, () => current[r.concept]);
        running[r.concept] = RoundEngine.nextMastery(
          running[r.concept],
          r.value,
        );
        after[r.concept] = running[r.concept];
      }
      for (final e in after.entries) {
        await dao.upsertMastery(
          profileId: profileId,
          conceptId: e.key,
          mastery: e.value!,
          now: now,
        );
      }

      final correct = results.where((r) => r.correct).length;
      final id = await dao.insertAttempt(
        profileId: profileId,
        activityId: activity,
        kind: mode == RoundMode.quiz ? AttemptKind.quiz : AttemptKind.practice,
        score: correct,
        total: results.length,
        starsEarned: earned,
        hintsUsed: results.fold(0, (a, r) => a + r.hints),
        detailsJson: jsonEncode({
          'lessonId': lessonId,
          'mode': mode.name,
          'rawStars': raw,
          'questions': [for (final r in results) r.toJson()],
          'masteryBefore': before,
          'masteryAfter': after,
        }),
        now: now,
      );

      final passed =
          mode == RoundMode.practice ||
          RoundEngine.percent(results) >= quizPassPercent;
      if (passed) {
        await completePart(
          profileId: profileId,
          lessonId: lessonId,
          part: mode == RoundMode.quiz ? LessonPart.quiz : LessonPart.practice,
          content: content,
        );
      }
      return RoundRecord(attemptId: id, earned: earned);
    });
  }

  Future<RoundRecord> recordGame({
    required String profileId,
    required String activityId,
    required List<QuestionResult> results,
    required int starsCap,
  }) {
    return _db.transaction(() async {
      final dao = _db.activityDao;
      final raw = RoundEngine.starsEarned(results);
      final already = await dao.starsForActivity(profileId, activityId);
      final earned = raw.clamp(0, (starsCap - already).clamp(0, starsCap));
      final id = await dao.insertAttempt(
        profileId: profileId,
        activityId: activityId,
        kind: AttemptKind.practice,
        score: results.where((r) => r.correct).length,
        total: results.length,
        starsEarned: earned,
        hintsUsed: results.fold(0, (a, r) => a + r.hints),
        now: _now(),
      );
      return RoundRecord(attemptId: id, earned: earned);
    });
  }

  Future<({Attempt attempt, AttemptDetails details})?> loadAttempt(
    String profileId,
    int attemptId,
  ) async {
    final a = await _db.activityDao.getAttempt(profileId, attemptId);
    final raw = a?.detailsJson;
    if (a == null || raw == null) return null;
    return (attempt: a, details: AttemptDetails.fromJson(raw));
  }
}
