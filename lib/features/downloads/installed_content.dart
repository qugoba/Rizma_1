import '../../core/db/app_database.dart';
import '../../core/db/daos/content_dao.dart';
import 'blob_store.dart';

abstract interface class InstalledContent {
  Future<Set<String>> lessonIds();

  Future<String?> lessonFile(String lessonId, String path);

  Future<String?> catalog(int grade);

  Future<void> markBroken(String lessonId);
}

class DbInstalledContent implements InstalledContent {
  DbInstalledContent(this._db, this._store);

  final AppDatabase _db;

  final Future<BlobStore> Function() _store;

  ContentDao get _dao => _db.contentDao;

  @override
  Future<Set<String>> lessonIds() async => {
    for (final l in await _dao.watchLessons().first)
      if (l.version > 0) l.lessonId,
  };

  @override
  Future<String?> lessonFile(String lessonId, String path) async {
    final l = await _dao.lesson(lessonId);
    if (l == null || l.version == 0) return null;
    final sha = ContentDao.decodeFiles(l.files)[path];
    if (sha == null) return null;
    return _read(sha, onFail: () => markBroken(lessonId));
  }

  @override
  Future<String?> catalog(int grade) async {
    final sha = (await _dao.manifest(grade))?.catalogSha256;
    if (sha == null) return null;
    return _read(sha);
  }

  Future<String?> _read(String sha, {Future<void> Function()? onFail}) async {
    try {
      return await (await _store()).readString(sha);
    } catch (_) {
      await onFail?.call();
      return null;
    }
  }

  @override
  Future<void> markBroken(String lessonId) async {
    final l = await _dao.lesson(lessonId);
    if (l == null) return;
    await _dao.forgetInstalled(lessonId);
    final store = await _store();
    for (final sha in ContentDao.decodeFiles(l.files).values) {
      if (!await store.hasBlob(sha)) await _dao.removeBlob(sha);
    }
  }
}
