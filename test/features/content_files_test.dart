import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/features/catalog/catalog_models.dart';
import 'package:rizma/features/content/lesson_content.dart';

void main() {
  final catalog = Catalog.fromJson(
    jsonDecode(File('assets/content/catalog_grade5.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final lessonIds = {for (final l in catalog.allLessons) l.id};
  final files = [
    for (final f in Directory('assets/content/lessons').listSync())
      if (f is File && f.path.endsWith('.json')) f,
  ];

  test('في التطبيق ملفات دروس', () => expect(files, isNotEmpty));

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    test(name, () {
      final content = LessonContent.fromJson(
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
      );
      expect('${content.lessonId}.json', name);
      expect(lessonIds, contains(content.lessonId), reason: 'ليس في الكتالوج');
      expect(content.parts, isNotEmpty);
    });
  }
}
