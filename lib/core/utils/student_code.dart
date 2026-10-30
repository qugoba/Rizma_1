import 'dart:math';

abstract final class StudentCode {
  static const prefix = 'RZ-';

  static const randomLength = 8;

  static const groupLength = 4;

  static const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  static const length = 12;

  static String generate([Random? random]) {
    final rng = random ?? Random.secure();
    final body = List.generate(
      randomLength,
      (_) => alphabet[rng.nextInt(alphabet.length)],
    ).join();
    return _format(body);
  }

  static String _format(String body) =>
      '$prefix${body.substring(0, groupLength)}-${body.substring(groupLength)}';

  static String normalize(String input) {
    final compact = input.replaceAll(RegExp(r'[\s-]+'), '').toUpperCase();
    if (compact.startsWith('RZ') && compact.length == 2 + randomLength) {
      return _format(compact.substring(2));
    }
    return input.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  static bool isValid(String code) {
    final group = '[$alphabet]{$groupLength}';
    return RegExp('^${RegExp.escape(prefix)}$group-$group\$').hasMatch(code);
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
