import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/core/widgets/fraction_bar.dart';
import 'package:rizma/features/content/speech_service.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  Future<void> seedProfile(ProfileRepository repo) =>
      repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal, pin: null);

  Future<void> open(WidgetTester tester, String location) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RizmaApp)),
    );
    container.read(routerProvider).push(location);
    await tester.pumpAndSettle();
  }

  Future<Set<LessonPart>> doneParts(
    WidgetTester tester,
    AppDatabase db,
    String lessonId,
  ) async {
    final profile = (await tester.runAsync(
      () => db.profilesDao.getAll(),
    ))!.single;
    final rows = (await tester.runAsync(
      () => db.activityDao.getLessonParts(profile.id),
    ))!;
    return {
      for (final r in rows)
        if (r.lessonId == lessonId) r.part,
    };
  }

  testWidgets(
    'الرزمة: صفحة من صفحة، والوصول للأخيرة يُنجز الجزء',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u3.l3/pack');
      expect(find.text(ArLearn.packTitle), findsOneWidget);
      expect(find.text(ArLearn.packPage(1, 3)), findsOneWidget);
      expect(await doneParts(tester, db, 'math.u3.l3'), isEmpty);

      await tester.tap(find.text(ArLearn.next));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.packPage(2, 3)), findsOneWidget);
      await tester.tap(find.text(ArLearn.next));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.packPage(3, 3)), findsOneWidget);
      await tester.pumpAndSettle();
      expect(await doneParts(tester, db, 'math.u3.l3'), {LessonPart.pack});
    }),
  );

  testWidgets(
    'الرزمة من صفحة واحدة تُنجز بمجرد الفتح',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u1.l1/pack');
      await tester.pumpAndSettle();
      expect(await doneParts(tester, db, 'math.u1.l1'), {LessonPart.pack});
    }),
  );

  testWidgets(
    'الشرح: ينتقل بين الخطوات ويرسم الأشرطة ثم ينجز ويذهب للملخص',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u3.l1/explanation');
      expect(find.text(ArLearn.explainStep(1, 3)), findsOneWidget);
      expect(find.text(ArLearn.explainNext), findsOneWidget);

      await tester.tap(find.text(ArLearn.explainNext));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.explainStep(2, 3)), findsOneWidget);

      await tester.ensureVisible(find.text(ArLearn.explainNeedMore));
      await tester.tap(find.text(ArLearn.explainNeedMore));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.explainNeedMoreNote), findsOneWidget);
      expect(find.text(ArLearn.explainStep(2, 3)), findsOneWidget);

      await tester.tap(find.text(ArLearn.explainNext));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.explainStep(3, 3)), findsOneWidget);
      expect(find.text(ArLearn.explainNextSummary), findsOneWidget);
      expect(await doneParts(tester, db, 'math.u3.l1'), isEmpty);

      await tester.tap(find.text(ArLearn.explainNextSummary));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.summaryTitle), findsOneWidget);
      expect(await doneParts(tester, db, 'math.u3.l1'), {
        LessonPart.explanation,
        LessonPart.summary,
      });
    }),
  );

  testWidgets(
    'الشرح يعرض أشرطة الكسور حين تكون في الخطوة',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u3.l1/explanation');
      for (
        var i = 0;
        i < 2 && find.byType(FractionBar).evaluate().isEmpty;
        i++
      ) {
        await tester.tap(find.text(ArLearn.explainNext));
        await tester.pumpAndSettle();
      }
      expect(find.byType(FractionBar), findsWidgets);
    }),
  );

  testWidgets('الشرح: زر الصوت ينطق بالعربية، وغياب المحرّك يعرض رسالة', (
    tester,
  ) {
    final speech = FakeSpeech(available: false);
    return scenario(
      tester,
      seed: seedProfile,
      overrides: [speechServiceProvider.overrideWithValue(speech)],
      (db) async {
        await open(tester, '/lesson/math.u1.l1/explanation');
        await tester.tap(find.bySemanticsLabel(ArLearn.explainRead));
        await tester.pumpAndSettle();
        expect(speech.languages, ['ar']);
        expect(find.text(ArLearn.speechUnavailable), findsOneWidget);
      },
    );
  });

  testWidgets(
    'الملخص: يعرض النقاط ويُنجز عند الفتح',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u1.l2/summary');
      expect(find.text(ArLearn.summaryPoints(3)), findsOneWidget);
      expect(find.text(ArLearn.summaryCardOf(1, 3)), findsOneWidget);
      expect(find.text(ArLearn.summaryCardN(3)), findsOneWidget);

      await tester.tap(find.text(ArLearn.summaryNextCard));
      await tester.pumpAndSettle();
      expect(find.text(ArLearn.summaryCardOf(2, 3)), findsOneWidget);
      expect(find.text(ArLearn.summaryPracticeNow), findsOneWidget);
      expect(await doneParts(tester, db, 'math.u1.l2'), {LessonPart.summary});
    }),
  );

  testWidgets(
    'الفيديو: مشغّل صادق عن عدم توفر الملف، والأجزاء قابلة للاختيار',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u3.l3/video');
      expect(find.text(ArLearn.videoUnavailable), findsOneWidget);
      expect(find.text(ArLearn.videoParts), findsOneWidget);
      expect(await doneParts(tester, db, 'math.u3.l3'), isEmpty);
    }),
  );

  testWidgets(
    'الكلمات: نطق عادي وبطيء بالإنجليزية، وإنجاز بعد رؤية كل الكلمات',
    (tester) {
      final speech = FakeSpeech();
      return scenario(
        tester,
        seed: seedProfile,
        overrides: [speechServiceProvider.overrideWithValue(speech)],
        (db) async {
          await open(tester, '/lesson/english.u2.l1/words');
          expect(find.text('Apple'), findsWidgets);

          await tester.tap(find.text(ArLearn.wordListen).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text(ArLearn.wordSlow));
          await tester.pumpAndSettle();
          expect(speech.spoken, ['Apple', 'Apple']);
          expect(speech.languages, ['en-US', 'en-US']);
          expect(speech.slowFlags, [false, true]);

          expect(await doneParts(tester, db, 'english.u2.l1'), isEmpty);
          final list = find.byType(InkWell);
          expect(list, findsWidgets);
          for (final w in [
            'Orange',
            'Banana',
            'Grapes',
            'Lemon',
            'Strawberry',
          ]) {
            final tile = find.text(w).last;
            await tester.ensureVisible(tile);
            await tester.tap(tile);
            await tester.pumpAndSettle();
          }
          expect(await doneParts(tester, db, 'english.u2.l1'), {
            LessonPart.words,
          });
        },
      );
    },
  );

  testWidgets(
    'جزء لا محتوى له يعرض رسالة بدل شاشة فارغة، واسم جزء خاطئ يرجع للدرس',
    (tester) => scenario(tester, seed: seedProfile, (db) async {
      await open(tester, '/lesson/math.u1.l1/words');
      expect(find.text(ArLearn.partUnavailable), findsOneWidget);

      await open(tester, '/lesson/math.u1.l1/nonsense');
      expect(find.text(ArLearn.partUnavailable), findsNothing);
      expect(find.text(ArLearn.lessonChoose), findsOneWidget);
    }),
  );
}
