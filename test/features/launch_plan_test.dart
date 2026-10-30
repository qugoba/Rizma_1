import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/launch/launch_plan.dart';

Profile profile(String id, {String? pinHash}) {
  final t = DateTime(2026, 1, 1);
  return Profile(
    id: id,
    name: 'اسم $id',
    grade: 5,
    color: ProfileColor.teal,
    pinHash: pinHash,
    pinSalt: pinHash == null ? null : 'salt',
    studentCode: 'RZ-$id',
    classCode: null,
    equipped: '',
    createdAt: t,
    lastActiveAt: t,
    revision: 0,
    localVersion: 0,
  );
}

void main() {
  group('decideLaunchPlan', () {
    test('لا ملفات ← الترحيب', () {
      expect(decideLaunchPlan(const []).target, LaunchTarget.welcome);
    });

    test('ملف واحد بلا رمز سري ← الرئيسية مباشرة', () {
      final plan = decideLaunchPlan([profile('AAAA')]);
      expect(plan.target, LaunchTarget.home);
      expect(plan.profileId, 'AAAA');
    });

    test('ملف واحد عليه رمز سري ← اختيار الملف', () {
      final plan = decideLaunchPlan([profile('AAAA', pinHash: 'h')]);
      expect(plan.target, LaunchTarget.picker);
      expect(plan.profileId, isNull);
    });

    test('أكثر من ملف ← اختيار الملف حتى بلا رموز سرية', () {
      final plan = decideLaunchPlan([profile('AAAA'), profile('BBBB')]);
      expect(plan.target, LaunchTarget.picker);
    });
  });
}
