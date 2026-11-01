import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/rendering.dart' show OffsetLayer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/features/sync/sync_api.dart';

import '../../test/helpers/app_harness.dart';
import '../../test/helpers/fake_sync_server.dart';
import '../../test/helpers/load_fonts.dart';

const _dir = String.fromEnvironment('SHOTS_DIR', defaultValue: 'build/shots');
const _size = Size(390, 844);

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await tester.pumpAndSettle();
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final dpr = tester.view.devicePixelRatio;
  final bytes = await tester.runAsync(() async {
    final image = await layer.toImage(
      Offset.zero & (_size * dpr),
      pixelRatio: 1.5 / dpr,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File('$_dir/$name.png')..createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

Future<void> _go(WidgetTester tester, String location) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(RizmaApp)),
  );
  container.read(routerProvider).push(location);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadCairoFont);

  testWidgets('onboarding', (tester) {
    return scenario(tester, (db) async {
      await tester.binding.setSurfaceSize(_size);
      await _shot(tester, '01_welcome');
      await tester.tap(find.text(ArStrings.welcomeStart));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'أنس');
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await _shot(tester, '02_create_step1');
      await tester.ensureVisible(find.text(ArStrings.step1Next));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ArStrings.step1Next));
      await tester.pumpAndSettle();
      await _shot(tester, '03_create_step2');
    });
  });

  testWidgets('pin entry', (tester) {
    return scenario(
      tester,
      seed: (repo) async => repo.create(
        name: 'أنس',
        grade: 5,
        color: ProfileColor.teal,
        pin: '1234',
      ),
      (db) async {
        await tester.binding.setSurfaceSize(_size);
        await tester.tap(find.text('أنس'));
        await tester.pumpAndSettle();
        await _shot(tester, '05_pin');
        for (final d in '9999'.split('')) {
          await tester.tap(find.text(d).last);
          await tester.pump();
        }
        await tester.pump(const Duration(milliseconds: 300));
        await _shot(tester, '05b_pin_wrong');
      },
    );
  });

  testWidgets('grade 5', (tester) {
    return scenario(
      tester,
      seed: (repo) async {
        await repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
        await repo.create(name: 'ليان', grade: 2, color: ProfileColor.coral);
      },
      (db) async {
        await tester.binding.setSurfaceSize(_size);
        await _shot(tester, '04_picker');
        await tester.tap(find.text('أنس'));
        await tester.pumpAndSettle();
        await _shot(tester, '08_home');
        for (final (name, location) in [
          ('10_subjects', '/subjects'),
          ('11_units', '/subjects/math'),
          ('12_lessons', '/units/math.u3'),
          ('15_lesson_hub', '/lesson/math.u3.l3'),
          ('14_pack', '/lesson/math.u3.l3/pack'),
          ('16_explanation', '/lesson/math.u3.l3/explanation'),
          ('18_summary', '/lesson/math.u3.l3/summary'),
          ('19_video', '/lesson/math.u3.l3/video'),
          ('20_words', '/lesson/english.u2.l1/words'),
          ('21_round', '/learn/round/math.u3.l3'),
          ('29_quiz', '/learn/quiz/math.u3.l3'),
          ('32_review', '/learn/review/math.u3.l3'),
          ('34_progress', '/progress'),
          ('35_downloads', '/account/downloads'),
          ('38_account', '/account'),
          ('06_student_code', '/account/code'),
          ('39_wardrobe', '/account/wardrobe'),
        ]) {
          await _go(tester, location);
          await _shot(tester, name);
        }
      },
    );
  });

  for (final (grade, name) in [(5, '08b_home_active'), (7, '46b_home_calm')]) {
    testWidgets('active home $grade', (tester) {
      return scenario(
        tester,
        seed: (repo) async =>
            repo.create(name: 'أنس', grade: grade, color: ProfileColor.teal),
        (db) async {
          await tester.binding.setSurfaceSize(_size);
          final id = (await onDb(tester, db.profilesDao.getAll)).single.id;
          final now = DateTime.now();
          await onDb(
            tester,
            () => db.activityDao.upsertLessonProgress(
              profileId: id,
              lessonId: 'math.u1.l1',
              status: LessonStatus.inProgress,
              progress: 0.5,
              now: now,
            ),
          );
          await onDb(
            tester,
            () => db.activityDao.insertAttempt(
              profileId: id,
              activityId: 'math.u1.l1.quiz',
              kind: AttemptKind.quiz,
              score: 2,
              total: 5,
              starsEarned: 120,
              now: now,
            ),
          );
          await onDb(
            tester,
            () => db.activityDao.upsertMastery(
              profileId: id,
              conceptId: 'math.u1.l1.c1',
              mastery: 0.4,
              now: now,
            ),
          );
          await _shot(tester, name);
        },
      );
    });
  }

  testWidgets('result and round end', (tester) {
    return scenario(
      tester,
      seed: (repo) async =>
          repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal),
      (db) async {
        await tester.binding.setSurfaceSize(_size);
        final id = (await onDb(tester, db.profilesDao.getAll)).single.id;
        Map<String, Object> q(String qid, String c, bool ok, int wrongs) => {
          'id': qid,
          'concept': c,
          'kind': 'choice',
          'correct': ok,
          'wrongs': wrongs,
          'hints': wrongs,
        };
        String details(String mode, List<Map<String, Object>> qs) =>
            jsonEncode({
              'lessonId': 'math.u3.l3',
              'mode': mode,
              'rawStars': 20,
              'questions': qs,
              'masteryBefore': {'math.u3.l3.c1': null, 'math.u3.l3.c2': null},
              'masteryAfter': {'math.u3.l3.c1': 0.9, 'math.u3.l3.c2': 0.5},
            });
        final quiz = [
          for (var i = 1; i <= 10; i++)
            q(
              'math.u3.l3.q$i',
              i.isEven ? 'math.u3.l3.c2' : 'math.u3.l3.c1',
              i != 3 && i != 8,
              0,
            ),
        ];
        final quizId = await onDb(
          tester,
          () => db.activityDao.insertAttempt(
            profileId: id,
            activityId: 'math.u3.l3.quiz',
            kind: AttemptKind.quiz,
            score: 8,
            total: 10,
            starsEarned: 20,
            detailsJson: details('quiz', quiz),
            now: DateTime.now(),
          ),
        );
        final practice = [
          for (var i = 1; i <= 8; i++)
            q('math.u3.l3.p$i', 'math.u3.l3.c1', i != 5, i == 2 ? 1 : 0),
        ];
        final practiceId = await onDb(
          tester,
          () => db.activityDao.insertAttempt(
            profileId: id,
            activityId: 'math.u3.l3.practice',
            kind: AttemptKind.practice,
            score: 7,
            total: 8,
            starsEarned: 15,
            detailsJson: details('practice', practice),
            now: DateTime.now(),
          ),
        );
        await _go(tester, '/learn/result/$quizId');
        await _shot(tester, '30_result');
        await _go(tester, '/learn/round-end/$practiceId');
        await _shot(tester, '31_round_end');
        await _go(tester, '/learn/review/math.u3.l3');
        await _shot(tester, '32b_review_plan');
      },
    );
  });

  for (final (grade, name) in [(2, '45_home_kids'), (11, '46_home_teen')]) {
    testWidgets('grade $grade', (tester) {
      return scenario(
        tester,
        seed: (repo) async {
          await repo.create(
            name: 'سارة',
            grade: grade,
            color: ProfileColor.blue,
          );
        },
        (db) async {
          await tester.binding.setSurfaceSize(_size);
          await _shot(tester, name);
          if (grade == 2) {
            await _go(tester, '/kids/game');
            await _shot(tester, '28_kids_game');
          } else {
            await _go(tester, '/learn/round/math.u3.l3');
            await _shot(tester, '52_round_teen');
          }
        },
      );
    });
  }

  testWidgets('restore', (tester) {
    final server = FakeSyncServer()
      ..upload('old-phone', {
        'profile_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        'profile': {
          'base_revision': 0,
          'student_code': 'RZ-7K4M-9P2Q',
          'grade': 5,
          'color': 'purple',
          'equipped': '',
          'created_at': '2026-10-01T08:00:00Z',
        },
      });
    return scenario(
      tester,
      overrides: [syncApiProvider.overrideWithValue(server.device('phone'))],
      (db) async {
        await tester.binding.setSurfaceSize(_size);
        await tester.tap(find.text(ArStrings.welcomeHaveProfile));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'RZ-2222-2222');
        await tester.pump();
        await tester.tap(find.text(ArStrings.restoreCheck));
        await _shot(tester, '60_restore_wrong');
        await tester.enterText(find.byType(TextField), 'RZ-7K4M-9P2Q');
        await tester.pump();
        await tester.tap(find.text(ArStrings.restoreCheck));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'سارة');
        await _shot(tester, '61_restore_name');
      },
    );
  });

  testWidgets('delete with server', (tester) {
    final api = FakeSyncServer().device('phone')..offline = true;
    return scenario(
      tester,
      seed: (repo) async {
        final p = await repo.create(
          name: 'أنس',
          grade: 5,
          color: ProfileColor.teal,
        );
        await repo.setActive(p.id);
      },
      overrides: [syncApiProvider.overrideWithValue(api)],
      (db) async {
        await tester.binding.setSurfaceSize(_size);
        final p = (await tester.runAsync(db.profilesDao.getAll))!.single;
        await tester.runAsync(
          () => db.activityDao.insertAttempt(
            profileId: p.id,
            activityId: 'a',
            kind: AttemptKind.practice,
            score: 1,
            total: 1,
            starsEarned: 3,
            now: DateTime(2026, 10, 24),
          ),
        );
        await tester.tap(find.text(ArStrings.navProfile));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(ArStrings.accountDelete));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ArStrings.accountDelete));
        await _shot(tester, '62_delete_choose');
        await tester.tap(find.text(ArStrings.deleteRemoveOption));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await _shot(tester, '63_delete_unsynced');
      },
    );
  });
}
