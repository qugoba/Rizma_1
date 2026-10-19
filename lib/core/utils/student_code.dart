import 'dart:math';

abstract final class StudentCode {
  static const prefix = 'RZ-';

  static const randomLength = 4;

  static const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  static String generate([Random? random]) {
    final rng = random ?? Random.secure();
    final body = List.generate(
      randomLength,
      (_) => alphabet[rng.nextInt(alphabet.length)],
    ).join();
    return '$prefix$body';
  }

  static String normalize(String input) {
    return input.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  static bool isValid(String code) {
    final pattern = RegExp(
      '^${RegExp.escape(prefix)}[$alphabet]{$randomLength}\$',
    );
    return pattern.hasMatch(code);
  }

  static Future<String> generateUnique(
    Future<bool> Function(String code) exists, {
    Random? random,
    int maxTries = 50,
  }) async {
    for (var i = 0; i < maxTries; i++) {
      final code = generate(random);
      if (!await exists(code)) return code;
    }
    throw StateError('تعذّر توليد رمز طالب غير مكرر');
  }
}
