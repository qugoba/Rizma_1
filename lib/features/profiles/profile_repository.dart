import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/app_database.dart';
import '../../core/db/daos/settings_dao.dart';
import '../../core/utils/class_code.dart';
import '../../core/utils/pin_hasher.dart';
import '../../core/utils/student_code.dart';

enum PinCheck { ok, wrong, locked }

class PinVerification {
  const PinVerification(this.check, {this.lockedFor});

  final PinCheck check;

  final Duration? lockedFor;

  bool get isOk => check == PinCheck.ok;
}

class ProfileRepository {
  ProfileRepository(
    this._db, {
    DateTime Function()? now,
    Random? random,
    PinLockout Function()? lockoutFactory,
  }) : _now = now ?? DateTime.now,
       _random = random,
       _lockoutFactory = lockoutFactory ?? (() => PinLockout(now: now));

  final AppDatabase _db;
  final DateTime Function() _now;
  final Random? _random;
  final PinLockout Function() _lockoutFactory;
  final _uuid = const Uuid();
  final Map<String, PinLockout> _lockouts = {};

  Stream<List<Profile>> watchAll() => _db.profilesDao.watchAll();

  Future<List<Profile>> getAll() => _db.profilesDao.getAll();

  Future<Profile?> getById(String id) => _db.profilesDao.getById(id);

  Stream<Profile?> watchById(String id) => _db.profilesDao.watchById(id);

  Future<int> count() => _db.profilesDao.count();

  Future<Profile> create({
    required String name,
    required int grade,
    required ProfileColor color,
    String? pin,
    String? classCode,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError.value(name, 'name');
    if (grade < 1 || grade > 12) throw ArgumentError.value(grade, 'grade');

    String? pinHash;
    String? pinSalt;
    if (pin != null) {
      if (!PinHasher.isValidFormat(pin)) throw ArgumentError.value(pin, 'pin');
      pinSalt = PinHasher.generateSalt(_random);
      pinHash = PinHasher.hash(pin, pinSalt);
    }

    String? cleanClassCode;
    if (classCode != null && classCode.trim().isNotEmpty) {
      cleanClassCode = ClassCode.normalize(classCode);
      if (!ClassCode.isValid(cleanClassCode)) {
        throw ArgumentError.value(classCode, 'classCode');
      }
    }

    final code = await StudentCode.generateUnique(
      (c) async => await _db.profilesDao.getByStudentCode(c) != null,
      random: _random,
    );
    final now = _now();
    final id = _uuid.v4();

    await _db.profilesDao.insertProfile(
      ProfilesCompanion.insert(
        id: id,
        name: cleanName,
        grade: grade,
        color: color,
        pinHash: Value(pinHash),
        pinSalt: Value(pinSalt),
        studentCode: code,
        classCode: Value(cleanClassCode),
        createdAt: now,
        lastActiveAt: now,
      ),
    );
    await setActive(id);
    return (await getById(id))!;
  }

  Future<void> setActive(String id) async {
    await _db.profilesDao.touch(id, _now());
    await _db.settingsDao.write(SettingsDao.activeProfileKey, id);
  }

  Future<String?> readActiveId() async {
    final id = await _db.settingsDao.read(SettingsDao.activeProfileKey);
    if (id == null) return null;
    return await getById(id) == null ? null : id;
  }

  Future<PinVerification> verifyPin(String profileId, String pin) async {
    final profile = await getById(profileId);
    if (profile == null) throw StateError('ملف غير موجود');
    final hash = profile.pinHash;
    final salt = profile.pinSalt;
    if (hash == null || salt == null) {
      return const PinVerification(PinCheck.ok);
    }

    final lockout = _lockouts.putIfAbsent(profileId, _lockoutFactory);
    final locked = lockout.remaining;
    if (locked != null) {
      return PinVerification(PinCheck.locked, lockedFor: locked);
    }

    if (PinHasher.verify(pin, hash: hash, salt: salt)) {
      lockout.registerSuccess();
      return const PinVerification(PinCheck.ok);
    }
    lockout.registerFailure();
    final nowLocked = lockout.remaining;
    return nowLocked == null
        ? const PinVerification(PinCheck.wrong)
        : PinVerification(PinCheck.locked, lockedFor: nowLocked);
  }

  Future<void> setPin(String profileId, String pin) async {
    if (!PinHasher.isValidFormat(pin)) throw ArgumentError.value(pin, 'pin');
    final salt = PinHasher.generateSalt(_random);
    await _db.profilesDao.setPin(
      profileId,
      hash: PinHasher.hash(pin, salt),
      salt: salt,
    );
    _lockouts.remove(profileId);
  }

  Future<void> clearPin(String profileId) async {
    await _db.profilesDao.clearPin(profileId);
    _lockouts.remove(profileId);
  }

  Future<bool> matchesStudentCode(String profileId, String studentCode) async {
    final profile = await getById(profileId);
    if (profile == null) return false;
    return StudentCode.normalize(studentCode) == profile.studentCode;
  }

  Future<bool> resetPinWithStudentCode(
    String profileId,
    String studentCode, {
    String? newPin,
  }) async {
    final profile = await getById(profileId);
    if (profile == null) return false;
    if (StudentCode.normalize(studentCode) != profile.studentCode) {
      return false;
    }
    if (newPin == null) {
      await clearPin(profileId);
    } else {
      await setPin(profileId, newPin);
    }
    return true;
  }

  Future<int> delete(String profileId) async {
    await _db.transaction(() async {
      await _db.activityDao.clearActivity(profileId);
      await _db.settingsDao.removeByPrefix(
        SettingsDao.profilePrefsPrefix(profileId),
      );
      if (await readActiveIdRaw() == profileId) {
        await _db.settingsDao.remove(SettingsDao.activeProfileKey);
      }
      await _db.profilesDao.deleteById(profileId);
    });
    _lockouts.remove(profileId);
    return count();
  }

  Future<String?> readActiveIdRaw() =>
      _db.settingsDao.read(SettingsDao.activeProfileKey);

  Future<void> setGrade(String profileId, int grade) async {
    if (grade < 1 || grade > 12) throw ArgumentError.value(grade, 'grade');
    await _db.profilesDao.setGrade(profileId, grade);
  }

  Future<void> setClassCode(String profileId, String? classCode) async {
    if (classCode == null || classCode.trim().isEmpty) {
      await _db.profilesDao.setClassCode(profileId, null);
      return;
    }
    final normalized = ClassCode.normalize(classCode);
    if (!ClassCode.isValid(normalized)) {
      throw ArgumentError.value(classCode, 'classCode');
    }
    await _db.profilesDao.setClassCode(profileId, normalized);
  }
}
