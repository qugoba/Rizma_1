import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

void main() {
  late AppDatabase db;
  late DateTime clock;
  late ProfileRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 10, 8, 10);
    repo = ProfileRepository(db, now: () => clock, random: Random(5));
  });

  tearDown(() => db.close());

  Future<Profile> make(String name, {int grade = 5, String? pin}) {
    return repo.create(
      name: name,
      grade: grade,
      color: ProfileColor.teal,
      pin: pin,
    );
  }

  group('create', () {
    test('ينشئ ملفًا برمز طالب صحيح ويجعله نشطًا', () async {
      final p = await make('أنس');
      expect(p.name, 'أنس');
      expect(p.grade, 5);
      expect(p.studentCode, matches(RegExp(r'^RZ-[A-Z2-9]{4}$')));
      expect(p.pinHash, isNull);
      expect(await repo.readActiveId(), p.id);
    });

    test('يقصّ الاسم ويرفض الفارغ والصف خارج 1-12', () async {
      expect((await make('  ليان  ')).name, 'ليان');
      expect(() => make('   '), throwsArgumentError);
      expect(() => make('أنس', grade: 0), throwsArgumentError);
      expect(() => make('أنس', grade: 13), throwsArgumentError);
    });

    test('يخزّن الرمز السري مجزّأً لا نصًّا', () async {
      final p = await make('أنس', pin: '1234');
      expect(p.pinHash, isNotNull);
      expect(p.pinSalt, isNotNull);
      expect(p.pinHash, isNot(contains('1234')));
    });

    test('يوحّد رمز الصف ويرفض الصيغة الخاطئة', () async {
      final ok = await repo.create(
        name: 'أنس',
        grade: 5,
        color: ProfileColor.teal,
        classCode: ' gz-5a ',
      );
      expect(ok.classCode, 'GZ-5A');
      expect(
        () => repo.create(
          name: 'ليان',
          grade: 2,
          color: ProfileColor.coral,
          classCode: 'غير صالح!',
        ),
        throwsArgumentError,
      );
    });

    test('رموز الطلاب فريدة بين 3 ملفات', () async {
      final a = await make('أ');
      final b = await make('ب');
      final c = await make('ج');
      expect({a.studentCode, b.studentCode, c.studentCode}, hasLength(3));
      expect(await repo.count(), 3);
    });
  });

  group('الملف النشط', () {
    test('لا يوجد ملف نشط على جهاز نظيف', () async {
      expect(await repo.readActiveId(), isNull);
    });

    test('setActive يحدّث lastActiveAt ويحفظ الاختيار', () async {
      final a = await make('أ');
      final b = await make('ب');
      clock = clock.add(const Duration(hours: 1));
      await repo.setActive(a.id);
      expect(await repo.readActiveId(), a.id);
      final reloaded = await repo.getById(a.id);
      expect(reloaded!.lastActiveAt, clock);
      expect((await repo.getById(b.id))!.lastActiveAt.isBefore(clock), isTrue);
    });
  });

  group('الرمز السري', () {
    test('ملف بلا رمز يقبل أي إدخال', () async {
      final p = await make('أنس');
      expect((await repo.verifyPin(p.id, '0000')).isOk, isTrue);
    });

    test('الرمز الصحيح ينجح والخاطئ يفشل', () async {
      final p = await make('أنس', pin: '1234');
      expect((await repo.verifyPin(p.id, '1234')).isOk, isTrue);
      expect((await repo.verifyPin(p.id, '9999')).check, PinCheck.wrong);
    });

    test('بعد 5 محاولات خاطئة يُقفل 30 ثانية حتى مع الرمز الصحيح', () async {
      final p = await make('أنس', pin: '1234');
      for (var i = 0; i < 4; i++) {
        expect((await repo.verifyPin(p.id, '0000')).check, PinCheck.wrong);
      }
      final fifth = await repo.verifyPin(p.id, '0000');
      expect(fifth.check, PinCheck.locked);
      expect(fifth.lockedFor, const Duration(seconds: 30));

      final correctWhileLocked = await repo.verifyPin(p.id, '1234');
      expect(correctWhileLocked.check, PinCheck.locked);

      clock = clock.add(const Duration(seconds: 31));
      expect((await repo.verifyPin(p.id, '1234')).isOk, isTrue);
    });

    test('القفل خاص بكل ملف', () async {
      final a = await make('أ', pin: '1111');
      final b = await make('ب', pin: '2222');
      for (var i = 0; i < 5; i++) {
        await repo.verifyPin(a.id, '0000');
      }
      expect((await repo.verifyPin(a.id, '1111')).check, PinCheck.locked);
      expect((await repo.verifyPin(b.id, '2222')).isOk, isTrue);
    });

    test('setPin وclearPin', () async {
      final p = await make('أنس');
      await repo.setPin(p.id, '4321');
      expect((await repo.verifyPin(p.id, '4321')).isOk, isTrue);
      expect((await repo.verifyPin(p.id, '1111')).check, PinCheck.wrong);
      await repo.clearPin(p.id);
      expect((await repo.getById(p.id))!.pinHash, isNull);
      expect(() => repo.setPin(p.id, '12'), throwsArgumentError);
    });

    test('نسيت الرمز: رمز الطالب الصحيح فقط يسمح بإعادة التعيين', () async {
      final p = await make('أنس', pin: '1234');
      expect(
        await repo.resetPinWithStudentCode(p.id, 'RZ-XXXX', newPin: '5555'),
        isFalse,
      );
      expect(
        await repo.resetPinWithStudentCode(
          p.id,
          p.studentCode.toLowerCase(),
          newPin: '5555',
        ),
        isTrue,
      );
      expect((await repo.verifyPin(p.id, '5555')).isOk, isTrue);
      expect(await repo.resetPinWithStudentCode(p.id, p.studentCode), isTrue);
      expect((await repo.getById(p.id))!.pinHash, isNull);
    });
  });

  group('فصل البيانات بين الملفات', () {
    test('النجوم والتقدّم والإتقان لا تتسرّب من طالب لآخر', () async {
      final a = await make('أ');
      final b = await make('ب');
      await db.activityDao.insertAttempt(
        profileId: a.id,
        activityId: 'x',
        kind: AttemptKind.quiz,
        score: 4,
        total: 5,
        starsEarned: 3,
        now: clock,
      );
      await db.activityDao.upsertLessonProgress(
        profileId: a.id,
        lessonId: 'math.u1.l1',
        status: LessonStatus.inProgress,
        progress: 0.5,
        now: clock,
      );
      await db.activityDao.upsertMastery(
        profileId: a.id,
        conceptId: 'c1',
        mastery: 0.3,
        now: clock,
      );

      expect(await db.activityDao.watchAttempts(a.id).first, hasLength(1));
      expect(await db.activityDao.watchAttempts(b.id).first, isEmpty);
      expect(await db.activityDao.watchLessonProgress(b.id).first, isEmpty);
      expect(await db.activityDao.watchMastery(b.id).first, isEmpty);
    });
  });
}
