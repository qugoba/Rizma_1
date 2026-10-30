import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/content/lesson_content.dart';
import 'package:rizma/features/content/question.dart';
import 'package:rizma/features/learning/learning_repository.dart';
import 'package:rizma/features/learning/round_engine.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/sync/sync_service.dart';

import '../helpers/fake_sync_server.dart';

final _contents = <String, LessonContent>{};

LessonContent? _content(String id) => _contents.putIfAbsent(
  id,
  () => LessonContent.fromJson(
    jsonDecode(File('assets/content/lessons/$id.json').readAsStringSync())
        as Map<String, dynamic>,
  ),
);

class Phone {
  Phone(FakeSyncServer server, String userId)
    : db = AppDatabase(NativeDatabase.memory()),
      api = server.device(userId) {
    learning = LearningRepository(db, now: tick);
    profiles = ProfileRepository(db, now: tick);
    sync = SyncService(
      db,
      api,
      recompute: (id) => learning.recomputeProgress(
        id,
        contentFor: (lesson) async => _content(lesson),
      ),
      removeLocal: (id) => profiles.delete(id),
      now: tick,
    );
  }

  final AppDatabase db;
  final FakeSyncApi api;
  late final LearningRepository learning;
  late final ProfileRepository profiles;
  late final SyncService sync;

  static var _clock = DateTime.utc(2026, 10, 24, 8);

  static DateTime tick() => _clock = _clock.add(const Duration(minutes: 1));

  Future<Map<String, double>> mastery(String id) async => {
    for (final m in await db.activityDao.getMastery(id)) m.conceptId: m.mastery,
  };

  Future<Map<String, (LessonStatus, double)>> progress(String id) async => {
    for (final p in await db.activityDao.watchLessonProgress(id).first)
      p.lessonId: (p.status, p.progress),
  };

  Future<int> unsynced(String table) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $table WHERE synced_at IS NULL',
        )
        .getSingle();
    return row.read<int>('c');
  }
}

List<QuestionResult> results(String concept, List<int> wrongs) => [
  for (final (i, w) in wrongs.indexed)
    QuestionResult(
      questionId: '$concept.q$i',
      fingerprint: 'fp$concept$i',
      concept: concept,
      kind: QuestionKind.choice,
      correct: w < 3,
      wrongs: w,
      hints: w,
    ),
];

void main() {
  late FakeSyncServer server;
  late Phone a;
  late Phone b;
  late String id;

  setUp(() async {
    server = FakeSyncServer();
    a = Phone(server, 'user-a');
    b = Phone(server, 'user-b');
    id = (await a.profiles.create(
      name: 'أنس',
      grade: 5,
      color: ProfileColor.teal,
      classCode: 'GZ-5A',
    )).id;
  });

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  Future<void> learnOnA() async {
    await a.learning.completePart(
      profileId: id,
      lessonId: 'math.u3.l3',
      part: LessonPart.explanation,
      content: _content('math.u3.l3'),
    );
    await a.learning.recordRound(
      profileId: id,
      lessonId: 'math.u3.l3',
      mode: RoundMode.practice,
      results: [
        ...results('c1', [0, 1, 3]),
        ...results('c2', [0]),
      ],
      content: _content('math.u3.l3'),
    );
    await a.learning.recordRound(
      profileId: id,
      lessonId: 'math.u3.l3',
      mode: RoundMode.quiz,
      results: results('c1', [0, 0, 0]),
      content: _content('math.u3.l3'),
    );
    await a.db.wardrobeDao.insertPurchase(
      profileId: id,
      itemId: 'scarf',
      cost: 20,
      now: Phone.tick(),
    );
    await a.db.profilesDao.setEquipped(id, {'scarf'});
    await a.db.profilesDao.setBookmark(
      profileId: id,
      lessonId: 'math.u1.l2',
      saved: true,
      now: Phone.tick(),
    );
  }

  Future<void> restoreOnB() async {
    final code = (await a.db.profilesDao.getById(id))!.studentCode;
    final r = await b.sync.restore(code.toLowerCase().replaceAll('-', ''));
    expect(r.status, RestoreStatus.restored);
    await b.sync.completeRestore(profileId: r.profileId!, name: 'أنس');
  }

  test('الرفع يعلّم كل شيء «مرفوعًا» ويُنشئ الطالب على الخادم', () async {
    await learnOnA();
    expect(await a.sync.syncProfile(id), SyncOutcome.done);

    for (final t in [
      'attempts',
      'owned_items',
      'lesson_part_progress',
      'bookmarks',
    ]) {
      expect(await a.unsynced(t), 0, reason: t);
    }
    final p = (await a.db.profilesDao.getById(id))!;
    expect(p.syncedAt, isNotNull);
    expect(p.revision, greaterThanOrEqualTo(1));
    expect(server.attempts.length, 2);
    expect(server.profiles[id]!['equipped'], 'scarf');
    expect(
      server.profiles[id]!.containsKey('name'),
      isFalse,
      reason: 'الاسم لا يُرفع أبدًا',
    );
  });

  test('هاتف جديد يستعيد الطالب برمزه ويحصل على التقدّم نفسه بالضبط', () async {
    await learnOnA();
    await a.sync.syncProfile(id);
    await restoreOnB();

    final restored = (await b.db.profilesDao.getById(id))!;
    expect(restored.name, 'أنس');
    expect(restored.pinHash, isNull, reason: 'الرقم السري لا يُستعاد');
    expect(restored.classCode, 'GZ-5A');
    expect(restored.equipped, 'scarf');
    expect(await b.mastery(id), await a.mastery(id));
    expect(await b.progress(id), await a.progress(id));
    expect(await b.db.profilesDao.watchBookmarks(id).first, {'math.u1.l2'});
    expect(
      await b.db.activityDao.totalStars(id),
      await a.db.activityDao.totalStars(id),
    );
    expect((await b.db.wardrobeDao.getOwned(id)).single.itemId, 'scarf');
    expect(await b.unsynced('attempts'), 0, reason: 'ما سُحب لا يُرفع ثانية');
  });

  test('ما يتعلّمه الطالب على هاتف يصل إلى الآخر ويعيد حساب إتقانه', () async {
    await learnOnA();
    await a.sync.syncProfile(id);
    await restoreOnB();

    await b.learning.recordRound(
      profileId: id,
      lessonId: 'math.u3.l3',
      mode: RoundMode.practice,
      results: results('c2', [3, 3]),
      content: _content('math.u3.l3'),
    );
    expect(await b.sync.syncProfile(id), SyncOutcome.done);
    expect(await a.sync.syncProfile(id), SyncOutcome.done);

    expect((await a.db.activityDao.getAttemptsInOrder(id)).length, 3);
    expect(await a.mastery(id), await b.mastery(id));
  });

  test('إزالة المفضّلة تنتقل ولا يرجع الدرس من الهاتف الآخر', () async {
    await learnOnA();
    await a.sync.syncProfile(id);
    await restoreOnB();

    await b.db.profilesDao.setBookmark(
      profileId: id,
      lessonId: 'math.u1.l2',
      saved: false,
      now: Phone.tick(),
    );
    await b.sync.syncProfile(id);
    await a.sync.syncProfile(id);
    await b.sync.syncProfile(id);

    expect(await a.db.profilesDao.watchBookmarks(id).first, isEmpty);
    expect(await b.db.profilesDao.watchBookmarks(id).first, isEmpty);
  });

  test('تعارض على الملف: كل حقل عدّله طالب على هاتفه يبقى', () async {
    await a.sync.syncProfile(id);
    await restoreOnB();

    await a.db.profilesDao.setGrade(id, 6);
    await b.db.profilesDao.setColor(id, ProfileColor.coral);

    expect(await a.sync.syncProfile(id), SyncOutcome.done);
    expect(await b.sync.syncProfile(id), SyncOutcome.done);
    expect(await a.sync.syncProfile(id), SyncOutcome.done);

    for (final phone in [a, b]) {
      final p = (await phone.db.profilesDao.getById(id))!;
      expect(p.grade, 6);
      expect(p.color, ProfileColor.coral);
      expect(p.syncedAt, isNotNull);
    }
    expect(server.profiles[id]!['grade'], 6);
    expect(server.profiles[id]!['color'], 'coral');
  });

  test(
    'تعديل صف أثناء رفعه يبقيه «غير مرفوع» ويُرفع في المرة التالية',
    () async {
      await a.db.profilesDao.setBookmark(
        profileId: id,
        lessonId: 'math.u1.l1',
        saved: true,
        now: Phone.tick(),
      );
      a.api.whileUploading = () => a.db.profilesDao.setBookmark(
        profileId: id,
        lessonId: 'math.u1.l1',
        saved: false,
        now: Phone.tick(),
      );
      await a.sync.syncProfile(id);
      a.api.whileUploading = null;

      final row = await (a.db.select(
        a.db.bookmarks,
      )..where((r) => r.lessonId.equals('math.u1.l1'))).getSingle();
      expect(row.syncedAt, isNull, reason: 'الإزالة لم تصل للخادم بعد');
      expect(server.bookmarks[(id, 'math.u1.l1')]!['removed_at'], isNull);

      await a.sync.syncProfile(id);
      expect(await a.unsynced('bookmarks'), 0);
      expect(server.bookmarks[(id, 'math.u1.l1')]!['removed_at'], isNotNull);
    },
  );

  test(
    'الرفع على دفعات: انقطاع الشبكة في المنتصف لا يضيّع ولا يكرّر شيئًا',
    () async {
      for (var i = 0; i < 250; i++) {
        await a.db.activityDao.insertAttempt(
          profileId: id,
          activityId: 'a$i',
          kind: AttemptKind.practice,
          score: 1,
          total: 1,
          starsEarned: 1,
          now: Phone.tick(),
        );
      }
      a.api.failUploadsAfter = 1;
      expect(await a.sync.syncProfile(id), SyncOutcome.offline);
      expect(
        await a.unsynced('attempts'),
        50,
        reason: 'الدفعة الأولى (200) وصلت',
      );

      a.api.failUploadsAfter = null;
      expect(await a.sync.syncProfile(id), SyncOutcome.done);
      expect(await a.unsynced('attempts'), 0);
      expect(server.attempts.length, 250);
    },
  );

  test('دون إنترنت: لا شيء يتغيّر والنتيجة «offline»', () async {
    await learnOnA();
    a.api.offline = true;
    expect(await a.sync.syncProfile(id), SyncOutcome.offline);
    expect(await a.unsynced('attempts'), 2);
    expect(server.profiles, isEmpty);
  });

  test(
    'الحذف النهائي من هاتف يزيل الطالب من الهاتف الآخر عند مزامنته',
    () async {
      await a.sync.syncProfile(id);
      await restoreOnB();
      final code = (await a.db.profilesDao.getById(id))!.studentCode;

      expect(await a.sync.requestDeletion(id, 'RZ-2222-2222'), isFalse);
      expect(await a.sync.requestDeletion(id, code), isTrue);

      expect(await b.sync.syncProfile(id), SyncOutcome.removed);
      expect(await b.db.profilesDao.getById(id), isNull);
      expect((await b.db.activityDao.getAttemptsInOrder(id)), isEmpty);
    },
  );

  test(
    'إن نسي الخادم الطالب (مُسح لعدم النشاط) يُرفع كل شيء من جديد',
    () async {
      await learnOnA();
      await a.sync.syncProfile(id);
      server
        ..profiles.clear()
        ..attempts.clear()
        ..owned.clear()
        ..parts.clear()
        ..bookmarks.clear()
        ..links.clear();

      expect(await a.sync.syncProfile(id), SyncOutcome.done);
      expect(server.profiles.containsKey(id), isTrue);
      expect(server.attempts.length, 2);
      expect(await a.unsynced('attempts'), 0);
    },
  );

  test('الاستعادة: رمز خاطئ، ثم قفل الرمز بعد 5 محاولات', () async {
    await a.sync.syncProfile(id);
    expect(
      (await b.sync.restore('RZ-2222-2222')).status,
      RestoreStatus.wrongCode,
    );
    for (var i = 0; i < 4; i++) {
      await b.sync.restore('RZ-2222-2222');
    }
    final locked = await b.sync.restore('RZ-2222-2222');
    expect(locked.status, RestoreStatus.codeLocked);
    expect(locked.retryAt, isNotNull);

    b.api.offline = true;
    expect(
      (await b.sync.restore('RZ-2222-2222')).status,
      RestoreStatus.offline,
    );
  });

  test('هاتف غير مرتبط بالطالب يُطلب منه الاستعادة', () async {
    await a.sync.syncProfile(id);
    final p = (await a.db.profilesDao.getById(id))!;
    await b.db.profilesDao.insertProfile(
      ProfilesCompanion.insert(
        id: id,
        name: 'نسخة',
        grade: p.grade,
        color: p.color,
        studentCode: p.studentCode,
        createdAt: p.createdAt,
        lastActiveAt: p.lastActiveAt,
        revision: const Value(1),
        syncedAt: Value(p.createdAt),
      ),
    );
    expect(await b.sync.syncProfile(id), SyncOutcome.needsRestore);
  });
}
