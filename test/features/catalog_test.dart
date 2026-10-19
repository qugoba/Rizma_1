import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/features/catalog/catalog_repository.dart';

void main() {
  late CatalogRepository repo;

  setUp(() {
    repo = CatalogRepository(loadString: (path) => File(path).readAsString());
  });

  test('يحمّل كتالوج الصف الخامس بست مواد', () async {
    final catalog = await repo.load();
    expect(catalog.grade, 5);
    expect(catalog.subjects.map((s) => s.id), [
      'math',
      'arabic',
      'english',
      'science',
      'social',
      'islamic',
    ]);
  });

  test('أول درس هو أول درس في أول مادة ولديه مدة', () async {
    final first = (await repo.load()).firstLesson!;
    expect(first.id, 'math.u1.l1');
    expect(first.estimatedMinutes, greaterThan(0));
  });

  test('معرّفات الدروس والمفاهيم فريدة وتتبع معرّف المادة', () async {
    final catalog = await repo.load();
    final lessonIds = catalog.allLessons.map((l) => l.id).toList();
    expect(lessonIds.toSet(), hasLength(lessonIds.length));

    final conceptIds = [
      for (final l in catalog.allLessons) ...l.concepts.map((c) => c.id),
    ];
    expect(conceptIds.toSet(), hasLength(conceptIds.length));
    for (final l in catalog.allLessons) {
      expect(l.id, startsWith('${l.subjectId}.'));
      expect(l.concepts, isNotEmpty);
    }
  });

  test('الدرس التالي والبحث عن مفهوم', () async {
    final catalog = await repo.load();
    final next = catalog.nextLessonInSubject(catalog.lessonById('math.u1.l1')!);
    expect(next!.id, 'math.u1.l2');

    final lastMath = catalog.subjectById('math')!.lessons.last;
    expect(catalog.nextLessonInSubject(lastMath), isNull);

    final hit = catalog.conceptById('math.u2.l2.c1')!;
    expect(hit.lesson.id, 'math.u2.l2');
  });
}
