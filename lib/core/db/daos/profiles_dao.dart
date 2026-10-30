import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/bookmarks.dart';
import '../tables/profiles.dart';

part 'profiles_dao.g.dart';

@DriftAccessor(tables: [Profiles, Bookmarks])
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

  Future<void> _writeSynced(
    String id, {
    Expression<int>? grade,
    Expression<String>? color,
    Expression<String>? classCode,
    Expression<String>? equipped,
  }) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion.custom(
        grade: grade,
        color: color,
        classCode: classCode,
        equipped: equipped,
        localVersion: profiles.localVersion + const Constant(1),
        syncedAt: const Variable<DateTime>(null),
      ),
    );
  }

  Future<void> setGrade(String id, int grade) =>
      _writeSynced(id, grade: Variable(grade));

  Future<void> deleteById(String id) async {
    await (delete(profiles)..where((p) => p.id.equals(id))).go();
  }

  Future<void> touch(String id, DateTime when) async {
    await (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(lastActiveAt: Value(when)),
    );
  }

  Future<void> setColor(String id, ProfileColor color) =>
      _writeSynced(id, color: Variable(color.name));

  Future<void> setClassCode(String id, String? classCode) =>
      _writeSynced(id, classCode: Variable(classCode));

  Future<void> setEquipped(String id, Set<String> itemIds) =>
      _writeSynced(id, equipped: Variable(encodeEquipped(itemIds)));

  static String encodeEquipped(Set<String> itemIds) =>
      (itemIds.toList()..sort()).join(',');

  static Set<String> decodeEquipped(String raw) => {
    for (final id in raw.split(','))
      if (id.isNotEmpty) id,
  };

  Stream<Set<String>> watchBookmarks(String profileId) {
    return (select(bookmarks)
          ..where((b) => b.profileId.equals(profileId) & b.removedAt.isNull()))
        .watch()
        .map((rows) => {for (final r in rows) r.lessonId});
  }

  Future<void> setBookmark({
    required String profileId,
    required String lessonId,
    required bool saved,
    required DateTime now,
  }) {
    return transaction(() async {
      final row =
          await (select(bookmarks)..where(
                (b) =>
                    b.profileId.equals(profileId) & b.lessonId.equals(lessonId),
              ))
              .getSingleOrNull();
      if (row == null) {
        if (!saved) return;
        await into(bookmarks).insert(
          BookmarksCompanion.insert(
            profileId: profileId,
            lessonId: lessonId,
            updatedAt: now,
            localVersion: const Value(1),
          ),
        );
        return;
      }
      if ((row.removedAt == null) == saved) return;
      await (update(bookmarks)..where(
            (b) => b.profileId.equals(profileId) & b.lessonId.equals(lessonId),
          ))
          .write(
            BookmarksCompanion(
              removedAt: Value(saved ? null : now),
              updatedAt: Value(now),
              localVersion: Value(row.localVersion + 1),
              syncedAt: const Value(null),
            ),
          );
    });
  }
}
