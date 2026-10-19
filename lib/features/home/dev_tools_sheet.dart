import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/app_database.dart';
import '../../core/db/daos/activity_dao.dart';
import '../../core/theme/app_text_styles.dart';
import '../catalog/catalog_models.dart';

Future<void> showDevToolsSheet(
  BuildContext context, {
  required AppDatabase db,
  required Profile profile,
  required Catalog catalog,
}) async {
  if (!kDebugMode) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _DevToolsSheet(
      db: db,
      profile: profile,
      catalog: catalog,
      parentContext: context,
    ),
  );
}

class _DevToolsSheet extends StatelessWidget {
  const _DevToolsSheet({
    required this.db,
    required this.profile,
    required this.catalog,
    required this.parentContext,
  });

  final AppDatabase db;
  final Profile profile;
  final Catalog catalog;
  final BuildContext parentContext;

  ActivityDao get _dao => db.activityDao;

  Future<CatalogLesson> _targetLesson() async {
    final progress = await _dao.watchLessonProgress(profile.id).first;
    final done = {
      for (final p in progress)
        if (p.status == LessonStatus.completed) p.lessonId,
    };
    return catalog.allLessons.firstWhere(
      (l) => !done.contains(l.id),
      orElse: () => catalog.allLessons.first,
    );
  }

  Future<void> _setStatus(LessonStatus status, double progress) async {
    final lesson = await _targetLesson();
    await _dao.upsertLessonProgress(
      profileId: profile.id,
      lessonId: lesson.id,
      status: status,
      progress: progress,
      now: DateTime.now(),
    );
  }

  Future<void> _practice() async {
    final lesson = await _targetLesson();
    await _dao.insertAttempt(
      profileId: profile.id,
      activityId: '${lesson.id}.practice',
      kind: AttemptKind.practice,
      score: 4,
      total: 5,
      starsEarned: 3,
      now: DateTime.now(),
    );
  }

  Future<void> _weakQuiz() async {
    final lesson = await _targetLesson();
    final now = DateTime.now();
    await _dao.insertAttempt(
      profileId: profile.id,
      activityId: '${lesson.id}.quiz',
      kind: AttemptKind.quiz,
      score: 2,
      total: 5,
      starsEarned: 1,
      now: now,
    );
    for (var i = 0; i < lesson.concepts.length; i++) {
      await _dao.upsertMastery(
        profileId: profile.id,
        conceptId: lesson.concepts[i].id,
        mastery: i == 0 ? 0.4 : 0.9,
        now: now,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget action(String label, Future<void> Function() run) {
      return ListTile(
        title: Text(label, style: AppTextStyles.body15),
        onTap: () async {
          Navigator.of(context).pop();
          await run();
        },
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'أدوات التطوير (debug فقط) · ${profile.name}',
                style: AppTextStyles.section18,
              ),
            ),
            action(
              'تحميل الدرس التالي',
              () => _setStatus(LessonStatus.downloaded, 0),
            ),
            action(
              'بدء الدرس التالي (50%)',
              () => _setStatus(LessonStatus.inProgress, 0.5),
            ),
            action(
              'إكمال الدرس التالي',
              () => _setStatus(LessonStatus.completed, 1),
            ),
            action('تدريب (+3 نجوم)', _practice),
            action('اختبار ضعيف (مفهوم يحتاج مراجعة)', _weakQuiz),
            action('مسح نشاط هذا الملف', () => _dao.clearActivity(profile.id)),
            ListTile(
              title: Text('تبديل الطالب', style: AppTextStyles.body15),
              onTap: () {
                Navigator.of(context).pop();
                parentContext.go(AppRoutes.profiles);
              },
            ),
          ],
        ),
      ),
    );
  }
}
