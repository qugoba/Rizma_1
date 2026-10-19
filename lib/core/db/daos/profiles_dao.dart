import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/profiles.dart';

part 'profiles_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  Stream<List<Profile>> watchAll() {
    return (select(
      profiles,
    )..orderBy([(p) => OrderingTerm.desc(p.lastActiveAt)])).watch();
  }

  Future<List<Profile>> getAll() {
    return (select(
      profiles,
    )..orderBy([(p) => OrderingTerm.desc(p.lastActiveAt)])).get();
  }

  Future<Profile?> getById(String id) {
    return (select(profiles)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Stream<Profile?> watchById(String id) {
    return (select(
      profiles,
    )..where((p) => p.id.equals(id))).watchSingleOrNull();
  }

  Future<Profile?> getByStudentCode(String code) {
    return (select(
      profiles,
    )..where((p) => p.studentCode.equals(code))).getSingleOrNull();
  }

  Future<int> count() async {
    final countExp = profiles.id.count();
    final row = await (selectOnly(
      profiles,
    )..addColumns([countExp])).getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> insertProfile(ProfilesCompanion entry) async {
    await into(profiles).insert(entry);
  }

  Future<void> setPin(
    String id, {
    required String hash,
    required String salt,
  }) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(pinHash: Value(hash), pinSalt: Value(salt)),
    );
  }

  Future<void> clearPin(String id) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      const ProfilesCompanion(pinHash: Value(null), pinSalt: Value(null)),
    );
  }

  Future<void> setGrade(String id, int grade) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(grade: Value(grade)),
    );
  }

  Future<void> deleteById(String id) async {
    await (delete(profiles)..where((p) => p.id.equals(id))).go();
  }

  Future<void> touch(String id, DateTime when) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(lastActiveAt: Value(when)),
    );
  }

  Future<void> setColor(String id, ProfileColor color) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(color: Value(color)),
    );
  }

  Future<void> setClassCode(String id, String? classCode) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(classCode: Value(classCode)),
    );
  }
}
