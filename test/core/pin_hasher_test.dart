import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/utils/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('يقبل 4 أرقام فقط', () {
      expect(PinHasher.isValidFormat('1234'), isTrue);
      expect(PinHasher.isValidFormat('123'), isFalse);
      expect(PinHasher.isValidFormat('12345'), isFalse);
      expect(PinHasher.isValidFormat('12a4'), isFalse);
    });

    test('التجزئة لا تحتوي الرمز نصًّا والتحقق يعمل', () {
      final salt = PinHasher.generateSalt(Random(1));
      final hash = PinHasher.hash('4321', salt);
      expect(hash, isNot(contains('4321')));
      expect(PinHasher.verify('4321', hash: hash, salt: salt), isTrue);
      expect(PinHasher.verify('1234', hash: hash, salt: salt), isFalse);
    });

    test('salt مختلف يعطي تجزئة مختلفة لنفس الرمز', () {
      final a = PinHasher.generateSalt(Random(1));
      final b = PinHasher.generateSalt(Random(2));
      expect(a, isNot(b));
      expect(PinHasher.hash('1111', a), isNot(PinHasher.hash('1111', b)));
    });
  });

  group('PinLockout', () {
    late DateTime clock;
    late PinLockout lockout;

    setUp(() {
      clock = DateTime(2026, 1, 1, 12);
      lockout = PinLockout(now: () => clock);
    });

    test('لا يُقفل قبل 5 محاولات خاطئة', () {
      for (var i = 0; i < 4; i++) {
        lockout.registerFailure();
      }
      expect(lockout.isLocked, isFalse);
    });

    test('يُقفل 30 ثانية بعد 5 محاولات خاطئة', () {
      for (var i = 0; i < 5; i++) {
        lockout.registerFailure();
      }
      expect(lockout.isLocked, isTrue);
      expect(lockout.remaining, const Duration(seconds: 30));
    });

    test('يُفتح بعد انتهاء المدة ويبدأ العدّ من جديد', () {
      for (var i = 0; i < 5; i++) {
        lockout.registerFailure();
      }
      clock = clock.add(const Duration(seconds: 31));
      expect(lockout.isLocked, isFalse);
      expect(lockout.failures, 0);
    });

    test('النجاح يصفّر العدّ', () {
      for (var i = 0; i < 4; i++) {
        lockout.registerFailure();
      }
      lockout.registerSuccess();
      lockout.registerFailure();
      expect(lockout.failures, 1);
      expect(lockout.isLocked, isFalse);
    });
  });
}
