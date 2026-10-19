import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class PinHasher {
  static const pinLength = 4;

  static bool isValidFormat(String pin) {
    return RegExp('^\\d{$pinLength}\$').hasMatch(pin);
  }

  static String generateSalt([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static bool verify(String pin, {required String hash, required String salt}) {
    final candidate = PinHasher.hash(pin, salt);
    if (candidate.length != hash.length) return false;
    var diff = 0;
    for (var i = 0; i < candidate.length; i++) {
      diff |= candidate.codeUnitAt(i) ^ hash.codeUnitAt(i);
    }
    return diff == 0;
  }
}

class PinLockout {
  PinLockout({
    this.maxAttempts = 5,
    this.lockDuration = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final int maxAttempts;
  final Duration lockDuration;
  final DateTime Function() _now;

  int _failures = 0;
  DateTime? _lockedUntil;

  Duration? get remaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(_now());
    if (left <= Duration.zero) {
      _lockedUntil = null;
      _failures = 0;
      return null;
    }
    return left;
  }

  bool get isLocked => remaining != null;

  int get failures => _failures;

  void registerSuccess() {
    _failures = 0;
    _lockedUntil = null;
  }

  void registerFailure() {
    _failures++;
    if (_failures >= maxAttempts) {
      _lockedUntil = _now().add(lockDuration);
    }
  }
}
