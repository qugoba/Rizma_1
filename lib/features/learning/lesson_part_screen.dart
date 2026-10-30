import 'package:flutter/widgets.dart';

import '../../core/db/enums.dart';
import 'explanation_screen.dart';
import 'pack_screen.dart';
import 'summary_screen.dart';
import 'video_screen.dart';
import 'words_screen.dart';

Widget? lessonPartScreen(String lessonId, String partName) {
  final part = LessonPart.values.where((p) => p.name == partName).firstOrNull;
  return switch (part) {
    LessonPart.pack => PackScreen(lessonId: lessonId),
    LessonPart.explanation => ExplanationScreen(lessonId: lessonId),
    LessonPart.summary => SummaryScreen(lessonId: lessonId),
    LessonPart.video => VideoScreen(lessonId: lessonId),
    LessonPart.words => WordsScreen(lessonId: lessonId),
    _ => null,
  };
}
