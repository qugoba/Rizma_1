abstract final class ClassCode {
  static const maxLength = 16;

  static String normalize(String input) {
    return input.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  static bool isValid(String normalized) {
    if (normalized.isEmpty || normalized.length > maxLength) return false;
    return RegExp(r'^[A-Z0-9]+(-[A-Z0-9]+)*$').hasMatch(normalized);
  }
}
