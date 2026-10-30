import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/account/preferences_repository.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late ProfileRepository profiles;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    profiles = ProfileRepository(db);
  });

  tearDown(() => db.close());

  group('ProfilePrefs.fromMap', () {
    test('الخريطة الفارغة تعطي الافتراضيات', () {
      final p = ProfilePrefs.fromMap({});
      expect(p.fontSize, FontSizeChoice.medium);
      expect(p.gameSounds, isTrue);
    });

    test('قيمة غير مفهومة ترجع إلى الافتراضي بدل أن تفشل', () {
      final p = ProfilePrefs.fromMap({
        'fontSize': 'huge',
        'gameSounds': 'maybe',
      });
      expect(p.fontSize, FontSizeChoice.medium);
      expect(p.gameSounds, isTrue);
    });

    test('مقاييس الخط', () {
      expect(FontSizeChoice.small.scale, lessThan(1));
      expect(FontSizeChoice.medium.scale, 1);
      expect(FontSizeChoice.large.scale, greaterThan(1));
    });
  });

  group('PreferencesRepository', () {
    test('ملف جديد: الافتراضيات', () async {
      final p = await prefs.read('p1');
      expect(p.gameSounds, isTrue);
    });

    test('يحفظ كل تفضيل ويقرؤه', () async {
      await prefs.setFontSize('p1', FontSizeChoice.large);
      await prefs.setGameSounds('p1', false);

      final p = await prefs.read('p1');
      expect(p.fontSize, FontSizeChoice.large);
      expect(p.gameSounds, isFalse);
    });

    test('التفضيلات منفصلة لكل طالب', () async {
      await prefs.setFontSize('a', FontSizeChoice.large);
      await prefs.setGameSounds('a', false);

      final b = await prefs.read('b');
      expect(b.fontSize, FontSizeChoice.medium);
      expect(b.gameSounds, isTrue);
    });

    test('البث يتحدّث عند كل تغيير', () async {
      final emitted = <FontSizeChoice>[];
      final sub = prefs.watch('p1').listen((p) => emitted.add(p.fontSize));
      await pumpEventQueue();
      await prefs.setFontSize('p1', FontSizeChoice.small);
      await pumpEventQueue();
      await sub.cancel();

      expect(emitted.first, FontSizeChoice.medium);
      expect(emitted.last, FontSizeChoice.small);
    });

    test('معرّف يبدأ بمعرّف آخر لا يتداخل معه', () async {
      await prefs.setGameSounds('ab', false);
      expect((await prefs.read('a')).gameSounds, isTrue);
    });
  });

  group('إعدادا التنزيل (للهاتف كله، ADR 002 5.4)', () {
    test('الافتراضي: Wi-Fi فقط، والفيديو باختيار الطالب', () async {
      final d = await prefs.readDownloads();
      expect(d.wifiOnly, isTrue);
      expect(d.autoVideo, isFalse);
    });

    test('يُحفظان ويُقرآن، وقيمة غير مفهومة ترجع للافتراضي', () async {
      await prefs.setWifiOnly(false);
      await prefs.setAutoVideo(true);
      final d = await prefs.readDownloads();
      expect(d.wifiOnly, isFalse);
      expect(d.autoVideo, isTrue);

      expect(DownloadPrefs.fromMap({'device.wifiOnly': 'x'}).wifiOnly, isTrue);
    });

    test('لا يختلطان بتفضيلات أي طالب', () async {
      await prefs.setAutoVideo(true);
      await prefs.setGameSounds('a', false);
      expect((await prefs.read('b')).gameSounds, isTrue);
      expect((await prefs.readDownloads()).autoVideo, isTrue);
    });
  });

  group('ProfileRepository.setGrade', () {
    test('يغيّر الصف ويُبقي بقية الملف', () async {
      final p = await profiles.create(
        name: 'أنس',
        grade: 5,
        color: ProfileColor.teal,
      );
      await profiles.setGrade(p.id, 7);

      final after = (await profiles.getById(p.id))!;
      expect(after.grade, 7);
      expect(after.name, 'أنس');
      expect(after.studentCode, p.studentCode);
    });

    test('يرفض صفًّا خارج 1–12', () async {
      final p = await profiles.create(
        name: 'أنس',
        grade: 5,
        color: ProfileColor.teal,
      );
      expect(() => profiles.setGrade(p.id, 0), throwsArgumentError);
      expect(() => profiles.setGrade(p.id, 13), throwsArgumentError);
    });
  });
  group('ProfileRepository.delete', () {
    Future<Profile> make(String name) =>
        profiles.create(name: name, grade: 5, color: ProfileColor.teal);

    test('يحذف الملف مع نشاطه وتفضيلاته ولا يمسّ ملفًا آخر', () async {
      final a = await make('أ');
      final b = await make('ب');
      for (final p in [a, b]) {
        await db.activityDao.insertAttempt(
          profileId: p.id,
          activityId: 'x',
          kind: AttemptKind.practice,
          score: 1,
          total: 1,
          starsEarned: 1,
          now: DateTime(2026),
        );
        await db.activityDao.upsertMastery(
          profileId: p.id,
          conceptId: 'c',
          mastery: 0.5,
          now: DateTime(2026),
        );
        await prefs.setFontSize(p.id, FontSizeChoice.large);
      }

      final left = await profiles.delete(a.id);

      expect(left, 1);
      expect(await profiles.getById(a.id), isNull);
      expect(await profiles.getById(b.id), isNotNull);
      final attempts = await db.select(db.attempts).get();
      expect(attempts.map((r) => r.profileId), [b.id]);
      final mastery = await db.select(db.conceptMastery).get();
      expect(mastery.map((r) => r.profileId), [b.id]);
      expect((await prefs.read(a.id)).fontSize, FontSizeChoice.medium);
      expect((await prefs.read(b.id)).fontSize, FontSizeChoice.large);
    });

    test('حذف الملف النشط يمسح مؤشّر الملف النشط', () async {
      final a = await make('أ');
      final b = await make('ب');
      expect(await profiles.readActiveId(), b.id);

      await profiles.delete(b.id);

      expect(await profiles.readActiveId(), isNull);
      expect(await profiles.getById(a.id), isNotNull);
    });

    test('حذف ملف غير نشط يُبقي مؤشّر الملف النشط', () async {
      final a = await make('أ');
      final b = await make('ب');

      await profiles.delete(a.id);

      expect(await profiles.readActiveId(), b.id);
    });

    test('حذف آخر ملف يعيد 0', () async {
      final a = await make('أ');
      expect(await profiles.delete(a.id), 0);
    });
  });
}
