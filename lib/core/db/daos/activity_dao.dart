import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/attempts.dart';
import '../tables/concept_mastery.dart';
import '../tables/lesson_part_progress.dart';
import '../tables/lesson_progress.dart';
import '../tables/sync_queue.dart';

part 'activity_dao.g.dart';

@DriftAccessor(
  tables: [
    LessonProgress,
    LessonPartProgress,
    Attempts,
    ConceptMastery,
    SyncQueue,
  ],
)
class ActivityDao extends DatabaseAccessor<AppDatabase>
    with _$ActivityDaoMixin {
  ActivityDao(super.db);

  Stream<List<LessonProgressEntry>> watchLessonProgress(String profileId) {
    return (select(
      lessonProgress,
    )..where((r) => r.profileId.equals(profileId))).watch();
  }

  Future<void> upsertLessonProgress({
    required String profileId,
    required String lessonId,
    required LessonStatus status,
    required double progress,
    required DateTime now,
  }) async {
    await into(lessonProgress).insertOnConflictUpdate(
      LessonProgressCompanion.insert(
        profileId: profileId,
        lessonId: lessonId,
        status: status,
        progress: Value(progress),
        updatedAt: now,
      ),
    );
  }

  Stream<List<LessonPartEntry>> watchLessonParts(String profileId) {
    return (select(
      lessonPartProgress,
    )..where((r) => r.profileId.equals(profileId))).watch();
  }

  Future<List<LessonPartEntry>> getLessonParts(String profileId) {
    return (select(
      lessonPartProgress,
    )..where((r) => r.profileId.equals(profileId))).get();
  }

  Future<void> markPartDone({
    required String profileId,
    required String lessonId,
    required LessonPart part,
    required DateTime now,
  }) async {
    await into(lessonPartProgress).insert(
      LessonPartProgressCompanion.insert(
        profileId: profileId,
        lessonId: lessonId,
        part: part,
        completedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Stream<List<Attempt>> watchAttempts(String profileId) {
    return (select(
      attempts,
    )..where((a) => a.profileId.equals(profileId))).watch();
  }

  Future<int> insertAttempt({
    required String profileId,
    required String activityId,
    required AttemptKind kind,
    required int score,
    required int total,
    required int starsEarned,
    required DateTime now,
    int hintsUsed = 0,
    String? detailsJson,
  }) {
    return into(attempts).insert(
      AttemptsCompanion.insert(
        profileId: profileId,
        activityId: activityId,
        kind: kind,
        score: score,
        total: total,
        starsEarned: Value(starsEarned),
        hintsUsed: Value(hintsUsed),
        detailsJson: Value(detailsJson),
        createdAt: now,
      ),
    );
  }

  Future<int> starsForActivity(String profileId, String activityId) async {
    final total = attempts.starsEarned.sum();
    final row =
        await (selectOnly(attempts)
              ..addColumns([total])
              ..where(
                attempts.profileId.equals(profileId) &
                    attempts.activityId.equals(activityId),
              ))
            .getSingle();
    return row.read(total) ?? 0;
  }

  Future<int> totalStars(String profileId) async {
    final total = attempts.starsEarned.sum();
    final row =
        await (selectOnly(attempts)
              ..addColumns([total])
              ..where(attempts.profileId.equals(profileId)))
            .getSingle();
    return row.read(total) ?? 0;
  }

  Future<Attempt?> getAttempt(String profileId, int id) {
    return (select(attempts)
          ..where((a) => a.profileId.equals(profileId) & a.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<ConceptMasteryEntry>> getMastery(String profileId) {
    return (select(
      conceptMastery,
    )..where((r) => r.profileId.equals(profileId))).get();
  }

  Stream<List<ConceptMasteryEntry>> watchMastery(String profileId) {
    return (select(
      conceptMastery,
    )..where((r) => r.profileId.equals(profileId))).watch();
  }

  Future<void> upsertMastery({
    required String profileId,
    required String conceptId,
    required double mastery,
    required DateTime now,
  }) async {
    await into(conceptMastery).insertOnConflictUpdate(
      ConceptMasteryCompanion.insert(
        profileId: profileId,
        conceptId: conceptId,
        mastery: mastery,
        updatedAt: now,
      ),
    );
  }

  Stream<Map<String, int>> watchStarsByProfile() {
    final total = attempts.starsEarned.sum();
    final query = selectOnly(attempts)
      ..addColumns([attempts.profileId, total])
      ..groupBy([attempts.profileId]);
    return query
        .map(
          (row) =>
              MapEntry(row.read(attempts.profileId)!, row.read(total) ?? 0),
        )
        .watch()
        .map(Map.fromEntries);
  }

  Future<void> clearActivity(String profileId) async {
    await (delete(
      lessonProgress,
    )..where((r) => r.profileId.equals(profileId))).go();
    await (delete(
      lessonPartProgress,
    )..where((r) => r.profileId.equals(profileId))).go();
    await (delete(attempts)..where((r) => r.profileId.equals(profileId))).go();
    await (delete(
      conceptMastery,
    )..where((r) => r.profileId.equals(profileId))).go();
  }

  Future<void> enqueueSync({
    required String entity,
    required String payloadJson,
    required DateTime now,
  }) async {
    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entity: entity,
        payloadJson: payloadJson,
        createdAt: now,
      ),
    );
  }

  Stream<int> watchPendingSyncCount() {
    final countExp = syncQueue.id.count();
    return (selectOnly(syncQueue)..addColumns([countExp]))
        .map((row) => row.read(countExp) ?? 0)
        .watchSingle();
  }
}
