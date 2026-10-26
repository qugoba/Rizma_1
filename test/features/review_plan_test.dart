import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/content/lesson_content.dart';
import 'package:rizma/features/learning/review_plan.dart';

void main() {
  final content = LessonContent.fromJson(
    jsonDecode(
          File('assets/content/lessons/math.u3.l3.json').readAsStringSync(),
        )
        as Map<String, dynamic>,
  );
  const concepts = ['a', 'b', 'c'];

  group('أضعف مفهوم', () {
    test('يختار الأدنى دون 80%', () {
      expect(
        ReviewPlanner.weakest(concepts, {'a': 0.9, 'b': 0.5, 'c': 0.3}),
        'c',
      );
    });

    test('المفهوم غير المقيس يُعدّ صفرًا', () {
      expect(ReviewPlanner.weakest(concepts, {'a': 0.9, 'b': 0.9}), 'c');
    });

    test('كلها متقنة ← null', () {
      expect(
        ReviewPlanner.weakest(concepts, {'a': 0.8, 'b': 1.0, 'c': 0.95}),
        isNull,
      );
    });

    test('التعادل يختار الأول', () {
      expect(
        ReviewPlanner.weakest(concepts, {'a': 0.5, 'b': 0.5, 'c': 0.9}),
        'a',
      );
    });
  });

  group('الخطة', () {
    ReviewPlan? plan(
      Set<LessonPart> done, {
      LessonContent? c,
      Map<String, double>? m,
    }) => ReviewPlanner.build(
      lessonId: 'math.u3.l3',
      lessonConcepts: concepts,
      mastery: m ?? {'a': 0.9, 'b': 0.9, 'c': 0.4},
      content: c ?? content,
      partsDone: done,
    );

    test('الخطوات بالترتيب: شرح، فيديو، تمارين مخصّصة، اختبار', () {
      final p = plan({})!;
      expect(p.conceptId, 'c');
      expect(p.mastery, 0.4);
      expect(p.steps.map((s) => s.part), [
        LessonPart.explanation,
        LessonPart.video,
        LessonPart.practice,
        LessonPart.quiz,
      ]);
      expect(p.current!.part, LessonPart.explanation);
    });

    test('الخطوة المنجزة تُتخطّى والحالية هي التالية', () {
      final p = plan({LessonPart.explanation})!;
      expect(p.steps.first.done, isTrue);
      expect(p.current!.part, LessonPart.video);
    });

    test('تمارين مخصّصة: مسار فيه المفهوم وعدد لا يتجاوز 5', () {
      final p = plan({})!;
      final practice = p.steps.firstWhere((s) => s.part == LessonPart.practice);
      expect(practice.route, contains('concept=c'));
      expect(practice.count, inInclusiveRange(1, ReviewPlanner.maxPractice));
    });

    test('بلا محتوى أو كلها متقنة ← لا خطة', () {
      expect(
        ReviewPlanner.build(
          lessonId: 'x',
          lessonConcepts: concepts,
          mastery: {'a': 1, 'b': 1, 'c': 1},
          content: content,
          partsDone: {},
        ),
        isNull,
      );
      expect(
        ReviewPlanner.build(
          lessonId: 'x',
          lessonConcepts: concepts,
          mastery: {},
          content: null,
          partsDone: {},
        ),
        isNull,
      );
    });
  });
}
