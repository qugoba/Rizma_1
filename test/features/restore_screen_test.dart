import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/features/sync/sync_api.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_sync_server.dart';

const _profileId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _code = 'RZ-7K4M-9P2Q';

FakeSyncServer _serverWithStudent() {
  final server = FakeSyncServer();
  server.upload('old-phone', {
    'profile_id': _profileId,
    'profile': {
      'base_revision': 0,
      'student_code': _code,
      'grade': 5,
      'color': 'purple',
      'class_code': 'GZ-5A',
      'equipped': 'scarf',
      'created_at': '2026-10-01T08:00:00Z',
    },
    'attempts': [
      {
        'id': 'b0000000-0000-4000-8000-000000000001',
        'activity_id': 'math.u1.l1.practice',
        'kind': 'practice',
        'score': 3,
        'total': 3,
        'stars_earned': 9,
        'hints_used': 0,
        'details': null,
        'created_at': '2026-10-02T08:00:00Z',
      },
    ],
    'bookmarks': [
      {
        'lesson_id': 'math.u1.l2',
        'removed_at': null,
        'updated_at': '2026-10-02T08:05:00Z',
      },
    ],
  });
  return server;
}

void main() {
  testWidgets(
    'الاستعادة من شاشة الترحيب: الرمز ثم الاسم ثم الرئيسية بنتائج الطالب',
    (tester) {
      final server = _serverWithStudent();
      return scenario(
        tester,
        overrides: [
          syncApiProvider.overrideWithValue(server.device('new-phone')),
        ],
        (db) async {
          await tester.tap(find.text(ArStrings.welcomeHaveProfile));
          await tester.pumpAndSettle();
          expect(find.text(ArStrings.restoreHeading), findsOneWidget);

          await tester.enterText(find.byType(TextField), 'rz7k4m9p2q');
          await tester.pump();
          await tester.tap(find.text(ArStrings.restoreCheck));
          await tester.pumpAndSettle();
          expect(find.text(ArStrings.restoreFoundTitle), findsOneWidget);
          expect(find.text(ArStrings.restoreNameNote), findsOneWidget);

          await tester.enterText(find.byType(TextField), 'سارة');
          await tester.pump();
          await tester.tap(find.text(ArStrings.restoreFinish));
          await tester.pumpAndSettle();

          final p = (await onDb(
            tester,
            () => db.profilesDao.getById(_profileId),
          ))!;
          expect(p.name, 'سارة');
          expect(p.color, ProfileColor.purple);
          expect(p.studentCode, _code);
          expect(
            await onDb(tester, () => db.activityDao.totalStars(_profileId)),
            9,
          );
          expect(
            await onDb(
              tester,
              () => db.profilesDao.watchBookmarks(_profileId).first,
            ),
            {'math.u1.l2'},
          );
          expect(server.links.contains((_profileId, 'new-phone')), isTrue);
          expect(find.textContaining('سارة'), findsWidgets);
        },
      );
    },
  );

  testWidgets('رمز خاطئ يعرض رسالة ولا ينتقل', (tester) {
    final server = _serverWithStudent();
    return scenario(
      tester,
      overrides: [
        syncApiProvider.overrideWithValue(server.device('new-phone')),
      ],
      (db) async {
        await tester.tap(find.text(ArStrings.welcomeHaveProfile));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'RZ-2222-2222');
        await tester.pump();
        await tester.tap(find.text(ArStrings.restoreCheck));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.restoreWrongCode), findsOneWidget);
        expect(find.text(ArStrings.restoreFoundTitle), findsNothing);
      },
    );
  });

  testWidgets('دون إنترنت: رسالة صادقة', (tester) {
    final api = _serverWithStudent().device('new-phone')..offline = true;
    return scenario(
      tester,
      overrides: [syncApiProvider.overrideWithValue(api)],
      (db) async {
        await tester.tap(find.text(ArStrings.welcomeHaveProfile));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), _code);
        await tester.pump();
        await tester.tap(find.text(ArStrings.restoreCheck));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.restoreOffline), findsOneWidget);
      },
    );
  });
}
