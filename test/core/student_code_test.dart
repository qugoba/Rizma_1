import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/utils/student_code.dart';

void main() {
  group('StudentCode', () {
    test('يولّد رمزًا بصيغة RZ-XXXX', () {
      final code = StudentCode.generate(Random(1));
      expect(code, matches(RegExp(r'^RZ-[A-Z2-9]{4}$')));
      expect(StudentCode.isValid(code), isTrue);
    });

    test('لا يستخدم أحرفًا ملتبسة 0 O 1 I L', () {
      final rng = Random(7);
      for (var i = 0; i < 2000; i++) {
        final body = StudentCode.generate(rng).substring(3);
        expect(body, isNot(matches(RegExp('[01OIL]'))));
      }
    });

    test('يرفض رموزًا غير صحيحة', () {
      expect(StudentCode.isValid('RZ-0000'), isFalse);
      expect(StudentCode.isValid('RZ-ABC'), isFalse);
      expect(StudentCode.isValid('XX-ABCD'), isFalse);
      expect(StudentCode.isValid('rz-abcd'), isFalse);
    });

    test('normalize يوحّد الأحرف والمسافات', () {
      expect(StudentCode.normalize(' rz- 7k4m '), 'RZ-7K4M');
    });

    test('generateUnique يتخطى الرموز المستخدمة', () async {
      final used = <String>{};
      final rng = Random(3);
      final first = await StudentCode.generateUnique(
        (c) async => used.contains(c),
        random: rng,
      );
      used.add(first);
      final second = await StudentCode.generateUnique(
        (c) async => used.contains(c),
        random: Random(3),
      );
      expect(second, isNot(first));
    });

    test('generateUnique يفشل إن كانت كل المحاولات مستخدمة', () {
      expect(
        StudentCode.generateUnique((_) async => true, maxTries: 3),
        throwsStateError,
      );
    });
  });
}
