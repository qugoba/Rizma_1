import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/content/lesson_content.dart';
import 'package:rizma/features/learning/round_engine.dart';
import 'package:rizma/features/learning/widgets/question_context.dart';
import 'package:rizma/features/learning/widgets/question_view.dart';

import 'helpers/app_harness.dart';
import 'helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  final lessons = {
    for (final f in Directory(
      'assets/content/lessons',
    ).listSync().whereType<File>())
      f.uri.pathSegments.last.replaceAll('.json', ''): LessonContent.fromJson(
        jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
      ),
  };

  for (final scale in [1.0, 1.5]) {
    for (final phase in RoundPhase.values) {
      testWidgets('كل أسئلة المحتوى (${phase.name}) على 320×568 وخط ×$scale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        var shown = 0;
        for (final entry in lessons.entries) {
          for (final mode in RoundMode.values) {
            final questions = mode == RoundMode.practice
                ? entry.value.practice
                : entry.value.quiz;
            final state = RoundEngine.start(
              mode: mode,
              questions: questions,
              random: Random(7),
            );
            for (var i = 0; i < questions.length; i++) {
              await tester.pumpWidget(
                MaterialApp(
                  locale: const Locale('ar'),
                  builder: (context, child) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  ),
                  home: Scaffold(
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: QuestionView(
                        data: QuestionContext(
                          question: questions[i],
                          layout: state.layouts[i],
                          mode: mode,
                          phase: phase,
                          lastAnswer: null,
                          number: i + 1,
                          total: questions.length,
                          onAnswer: (_) {},
                          onSpeak: (_, {slow = false}) {},
                        ),
                      ),
                    ),
                  ),
                ),
              );
              await tester.pump();
              expect(
                tester.takeException(),
                isNull,
                reason: '${entry.key} ${mode.name} ${questions[i].id}',
              );
              shown++;
            }
          }
        }
        expect(shown, greaterThan(100));
      });
    }
  }

  for (final scale in [1.0, 1.5]) {
    testWidgets('شاشات التعلّم على 320×568 وخط ×$scale', (tester) {
      return scenario(
        tester,
        seed: (repo) async {
          await repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
        },
        (db) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final container = ProviderScope.containerOf(
            tester.element(find.byType(RizmaApp)),
          );
          final router = container.read(routerProvider);

          for (final location in [
            '/subjects',
            '/subjects/math',
            '/units/math.u3',
            '/lesson/math.u3.l3',
            '/lesson/math.u3.l3/pack',
            '/lesson/math.u3.l3/explanation',
            '/lesson/math.u3.l3/summary',
            '/lesson/math.u3.l3/video',
            '/lesson/english.u2.l1/words',
            '/learn/round/math.u3.l3',
            '/learn/quiz/math.u3.l3',
            '/learn/review/math.u3.l3',
            '/progress',
            '/account/downloads',
            '/account/wardrobe',
          ]) {
            router.push(location);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: location);
          }
        },
      );
    });
  }

  for (final scale in [1.0, 1.5]) {
    for (final grade in [2, 11]) {
      testWidgets('رئيسية الصف $grade على 320×568 وخط ×$scale', (tester) {
        return scenario(
          tester,
          seed: (repo) async {
            await repo.create(
              name: 'ليان',
              grade: grade,
              color: ProfileColor.coral,
            );
          },
          (db) async {
            await tester.binding.setSurfaceSize(const Size(320, 568));
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'home');
            if (grade == 2) {
              final container = ProviderScope.containerOf(
                tester.element(find.byType(RizmaApp)),
              );
              container.read(routerProvider).push('/kids/game');
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: 'kids game');
            }
          },
        );
      });
    }
  }
}
