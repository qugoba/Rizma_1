import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/db/daos/profiles_dao.dart';
import 'package:rizma/features/content/lesson_content.dart';
import 'package:rizma/features/content/question.dart';
import 'package:rizma/features/learning/learning_repository.dart';
import 'package:rizma/features/learning/round_engine.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/wardrobe/wardrobe_repository.dart';

void main() {
  late AppDatabase db;
  late String profileId;
  var clock = DateTime(2026, 10, 24, 9);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 10, 24, 9);
    profileId = (await ProfileRepository(
      db,
      now: () => clock,
    ).create(name: 'أنس', grade: 5, color: ProfileColor.teal)).id;
  });

  tearDown(() => db.close());

  LessonContent lesson(String id) => LessonContent.fromJson(
    jsonDecode(File('assets/content/lessons/$id.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  List<QuestionResult> results(String concept, List<int> wrongs) => [
    for (final (i, w) in wrongs.indexed)
      QuestionResult(
        questionId: '$concept.q$i',
        fingerprint: 'fp$i',
        concept: concept,
        kind: QuestionKind.choice,
        correct: w < 3,
        wrongs: w,
        hints: w,
      ),
  ];

  Future<Map<String, double>> mastery() async => {
    for (final m in await db.activityDao.getMastery(profileId))
      m.conceptId: m.mastery,
  };

  Future<Map<String, (LessonStatus, double)>> progress() async => {
    for (final p in await db.activityDao.watchLessonProgress(profileId).first)
      p.lessonId: (p.status, p.progress),
  };

  group('إعادة حساب الإتقان والتقدّم', () {
    test('تطابق ما حسبه recordRound وcompletePart تدريجيًا', () async {
      final repo = LearningRepository(db, now: () => clock);
      final a = lesson('math.u3.l3');
      final b = lesson('math.u1.l1');
      Future<void> step() async =>
          clock = clock.add(const Duration(minutes: 7));

      await repo.completePart(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        part: LessonPart.explanation,
        content: a,
      );
      await step();
      await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.practice,
        results: [
          ...results('c1', [0, 1, 3]),
          ...results('c2', [0, 0]),
        ],
        content: a,
      );
      await step();
      await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.quiz,
        results: [
          ...results('c1', [0, 0, 0]),
          ...results('c3', [3, 0]),
        ],
        content: a,
      );
      await step();
      await repo.completePart(
        profileId: profileId,
        lessonId: 'math.u1.l1',
        part: LessonPart.pack,
        content: b,
      );
      await step();
      await repo.recordGame(
        profileId: profileId,
        activityId: 'kids.counting',
        results: results('fruit', [0, 1]),
        starsCap: 60,
      );

      final masteryBefore = await mastery();
      final progressBefore = await progress();
      expect(masteryBefore, isNotEmpty);
      expect(progressBefore.keys, {'math.u3.l3', 'math.u1.l1'});

      await repo.recomputeProgress(
        profileId,
        contentFor: (id) async => {'math.u3.l3': a, 'math.u1.l1': b}[id],
      );

      expect(await mastery(), masteryBefore);
      expect(await progress(), progressBefore);
    });

    test(
      'تبني الإتقان والتقدّم من الصفر بعد مسحهما (حالة الاستعادة)',
      () async {
        final repo = LearningRepository(db, now: () => clock);
        final a = lesson('math.u3.l3');
        await repo.recordRound(
          profileId: profileId,
          lessonId: 'math.u3.l3',
          mode: RoundMode.practice,
          results: results('c1', [0, 1]),
          content: a,
        );
        final expectedMastery = await mastery();
        final expectedProgress = await progress();

        await db.activityDao.clearDerived(profileId);
        expect(await mastery(), isEmpty);

        await repo.recomputeProgress(profileId, contentFor: (_) async => a);
        expect(await mastery(), expectedMastery);
        expect(await progress(), expectedProgress);
      },
    );
  });

  group('المحاولات', () {
    test('معرّفها UUID فريد، وكل سؤال يحفظ بصمة محتواه', () async {
      final repo = LearningRepository(db, now: () => clock);
      final first = await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.practice,
        results: results('c1', [0]),
        content: null,
      );
      final second = await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.practice,
        results: results('c1', [0]),
        content: null,
      );
      final uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-');
      expect(first.attemptId, matches(uuid));
      expect(second.attemptId, isNot(first.attemptId));

      final loaded = (await repo.loadAttempt(profileId, first.attemptId))!;
      expect(loaded.details.results.single.fingerprint, 'fp0');
      expect(loaded.attempt.syncedAt, isNull);
    });

    test('بصمة السؤال تتغيّر إذا تغيّر محتواه فقط', () {
      final json = {
        'id': 'q1',
        'concept': 'c1',
        'type': 'choice',
        'prompt': 'كم؟',
        'choices': ['1', '2'],
        'answer': 0,
      };
      final same = Question.fromJson({...json});
      final edited = Question.fromJson({...json, 'prompt': 'كم العدد؟'});
      expect(Question.fromJson(json).fingerprint, same.fingerprint);
      expect(edited.fingerprint, isNot(same.fingerprint));
      expect(same.fingerprint.length, 16);
    });
  });

  group('المفضّلة', () {
    Future<Bookmark> row(String lessonId) =>
        (db.select(db.bookmarks)..where(
              (b) =>
                  b.profileId.equals(profileId) & b.lessonId.equals(lessonId),
            ))
            .getSingle();

    test('الإزالة تضع علامة ولا تحذف الصف، والإضافة من جديد تفرّغها', () async {
      final dao = db.profilesDao;
      Future<void> set(bool saved) => dao.setBookmark(
        profileId: profileId,
        lessonId: 'math.u1.l1',
        saved: saved,
        now: clock,
      );

      await set(true);
      expect(await dao.watchBookmarks(profileId).first, {'math.u1.l1'});
      expect((await row('math.u1.l1')).localVersion, 1);

      await set(false);
      expect(await dao.watchBookmarks(profileId).first, isEmpty);
      final removed = await row('math.u1.l1');
      expect(removed.removedAt, clock);
      expect(removed.localVersion, 2);
      expect(removed.syncedAt, isNull);

      await set(false);
      expect((await row('math.u1.l1')).localVersion, 2);

      await set(true);
      final back = await row('math.u1.l1');
      expect(back.removedAt, isNull);
      expect(back.localVersion, 3);
    });

    test('أي تعديل على صف مرفوع يرجّعه «غير مرفوع»', () async {
      final dao = db.profilesDao;
      await dao.setBookmark(
        profileId: profileId,
        lessonId: 'math.u1.l1',
        saved: true,
        now: clock,
      );
      await (db.update(
        db.bookmarks,
      )).write(BookmarksCompanion(syncedAt: Value(clock)));
      await dao.setBookmark(
        profileId: profileId,
        lessonId: 'math.u1.l1',
        saved: false,
        now: clock,
      );
      expect((await row('math.u1.l1')).syncedAt, isNull);
    });
  });

  group('ملف الطالب', () {
    Future<Profile> profile() async =>
        (await db.profilesDao.getById(profileId))!;

    Future<void> markSynced() => (db.update(
      db.profiles,
    )).write(ProfilesCompanion(syncedAt: Value(clock)));

    test('تعديل ما يُرفع يزيد localVersion ويفرّغ syncedAt', () async {
      final dao = db.profilesDao;
      final start = (await profile()).localVersion;

      await markSynced();
      await dao.setGrade(profileId, 6);
      var p = await profile();
      expect(p.grade, 6);
      expect(p.localVersion, start + 1);
      expect(p.syncedAt, isNull);

      await markSynced();
      await dao.setColor(profileId, ProfileColor.coral);
      await dao.setClassCode(profileId, 'GZ-5A');
      await dao.setEquipped(profileId, {'scarf', 'cap'});
      p = await profile();
      expect(p.color, ProfileColor.coral);
      expect(p.classCode, 'GZ-5A');
      expect(p.equipped, 'cap,scarf');
      expect(ProfilesDao.decodeEquipped(p.equipped), {'cap', 'scarf'});
      expect(p.localVersion, start + 4);
      expect(p.syncedAt, isNull);
    });

    test(
      'الرقم السري ووقت آخر نشاط لا يُرفعان فلا يغيّران حالة المزامنة',
      () async {
        final repo = ProfileRepository(db, now: () => clock);
        await markSynced();
        final before = await profile();
        await repo.setPin(profileId, '1234');
        await repo.clearPin(profileId);
        await db.profilesDao.touch(
          profileId,
          clock.add(const Duration(hours: 1)),
        );
        final after = await profile();
        expect(after.localVersion, before.localVersion);
        expect(after.syncedAt, isNotNull);
      },
    );
  });

  group('رصيد النجوم', () {
    test(
      'لا يظهر سالبًا بعد دمج مشتريات من جهازين، ويمنع الشراء حتى يُسدَّد',
      () async {
        final wardrobe = WardrobeRepository(db, now: () => clock);
        await db.activityDao.insertAttempt(
          profileId: profileId,
          activityId: 'a',
          kind: AttemptKind.practice,
          score: 1,
          total: 1,
          starsEarned: 30,
          now: clock,
        );
        for (final item in ['scarf', 'glasses']) {
          await db.wardrobeDao.insertPurchase(
            profileId: profileId,
            itemId: item,
            cost: 30,
            now: clock,
          );
        }
        final owned = await db.wardrobeDao.getOwned(profileId);
        expect(WardrobeRepository.rawBalance(stars: 30, owned: owned), -30);
        expect(WardrobeRepository.balance(stars: 30, owned: owned), 0);
        expect(owned.length, 2, reason: 'القطع المشتراة لا تُسحب');

        await db.activityDao.insertAttempt(
          profileId: profileId,
          activityId: 'b',
          kind: AttemptKind.practice,
          score: 1,
          total: 1,
          starsEarned: 40,
          now: clock,
        );
        final stars = await db.activityDao.totalStars(profileId);
        expect(WardrobeRepository.balance(stars: stars, owned: owned), 10);
        expect(
          await wardrobe.buy(profileId, 'color.coral'),
          PurchaseResult.notEnoughStars,
        );
      },
    );
  });

  test('الترقية من الإصدار 2 تمسح الجداول القديمة وتعيد إنشاءها', () async {
    final old = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('CREATE TABLE profiles (id TEXT PRIMARY KEY)');
          raw.execute(
            'CREATE TABLE attempts (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'profile_id TEXT)',
          );
          raw.execute('CREATE TABLE sync_queue (id INTEGER PRIMARY KEY)');
          raw.execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(old.close);

    final tables = await old
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(tables, isNot(contains('sync_queue')));
    expect(tables, containsAll(['attempts', 'bookmarks', 'profiles']));

    final id = (await ProfileRepository(
      old,
    ).create(name: 'ليان', grade: 2, color: ProfileColor.amber)).id;
    final attemptId = await old.activityDao.insertAttempt(
      profileId: id,
      activityId: 'a',
      kind: AttemptKind.practice,
      score: 1,
      total: 1,
      starsEarned: 3,
      now: DateTime(2026, 10, 24),
    );
    expect(attemptId, isNotEmpty);
  });
}
