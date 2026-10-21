import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/strings/ar.dart';

void main() {
  group('ArStrings.stars', () {
    test('صيغ الجمع العربية', () {
      expect(ArStrings.stars(0), '0 نجوم');
      expect(ArStrings.stars(1), 'نجمة واحدة');
      expect(ArStrings.stars(2), 'نجمتان');
      expect(ArStrings.stars(3), '3 نجوم');
      expect(ArStrings.stars(8), '8 نجوم');
      expect(ArStrings.stars(10), '10 نجوم');
      expect(ArStrings.stars(11), '11 نجمة');
      expect(ArStrings.stars(24), '24 نجمة');
      expect(ArStrings.stars(120), '120 نجمة');
    });
  });

  group('ArStrings.streakDays', () {
    test('صيغ الجمع العربية', () {
      expect(ArStrings.streakDays(1), 'يوم واحد متتالٍ');
      expect(ArStrings.streakDays(2), 'يومان متتاليان');
      expect(ArStrings.streakDays(5), '5 أيام متتالية');
      expect(ArStrings.streakDays(10), '10 أيام متتالية');
      expect(ArStrings.streakDays(11), '11 يومًا متتاليًا');
    });
  });

  group('ArStrings.codePending', () {
    test('صيغ الجمع العربية', () {
      expect(ArStrings.codePending(1), 'نتيجة واحدة بانتظار الاتصال');
      expect(ArStrings.codePending(2), 'نتيجتان بانتظار الاتصال');
      expect(ArStrings.codePending(3), '3 نتائج بانتظار الاتصال');
      expect(ArStrings.codePending(10), '10 نتائج بانتظار الاتصال');
      expect(ArStrings.codePending(11), '11 نتيجة بانتظار الاتصال');
    });
  });

  test('أسماء الصفوف 1 إلى 12', () {
    expect(ArStrings.gradeName(1), 'الصف الأول');
    expect(ArStrings.gradeName(5), 'الصف الخامس');
    expect(ArStrings.gradeName(11), 'الصف الحادي عشر');
    expect(ArStrings.gradeName(12), 'الصف الثاني عشر');
  });
}
