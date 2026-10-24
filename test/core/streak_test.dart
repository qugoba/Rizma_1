import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/utils/streak.dart';

void main() {
  final now = DateTime(2026, 10, 8, 15);

  test('بلا نشاط السلسلة صفر', () {
    expect(currentStreak(const [], now), 0);
  });

  test('نشاط اليوم فقط = يوم واحد', () {
    expect(currentStreak([DateTime(2026, 10, 8, 9)], now), 1);
  });

  test('أيام متتالية حتى اليوم', () {
    final times = [
      DateTime(2026, 10, 8),
      DateTime(2026, 10, 7),
      DateTime(2026, 10, 6),
    ];
    expect(currentStreak(times, now), 3);
  });

  test('بلا نشاط اليوم تبقى السلسلة حيّة من أمس', () {
    final times = [DateTime(2026, 10, 7), DateTime(2026, 10, 6)];
    expect(currentStreak(times, now), 2);
  });

  test('فجوة يوم تقطع السلسلة', () {
    final times = [DateTime(2026, 10, 8), DateTime(2026, 10, 6)];
    expect(currentStreak(times, now), 1);
  });

  test('آخر نشاط قبل يومين = صفر', () {
    expect(currentStreak([DateTime(2026, 10, 6)], now), 0);
  });

  test('عدة أنشطة في اليوم نفسه تُحسب يومًا واحدًا', () {
    final times = [
      DateTime(2026, 10, 8, 8),
      DateTime(2026, 10, 8, 20),
      DateTime(2026, 10, 7, 1),
    ];
    expect(currentStreak(times, now), 2);
  });
}
