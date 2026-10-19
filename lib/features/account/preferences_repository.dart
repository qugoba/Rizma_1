import '../../core/db/app_database.dart';
import '../../core/db/daos/settings_dao.dart';

enum FontSizeChoice {
  small(0.9),
  medium(1.0),
  large(1.15);

  const FontSizeChoice(this.scale);

  final double scale;
}

class ProfilePrefs {
  const ProfilePrefs({
    this.fontSize = FontSizeChoice.medium,
    this.gameSounds = true,
    this.wifiOnly = true,
    this.autoVideo = false,
  });

  factory ProfilePrefs.fromMap(Map<String, String> raw) {
    bool flag(String key, bool fallback) => switch (raw[key]) {
      'true' => true,
      'false' => false,
      _ => fallback,
    };

    const defaults = ProfilePrefs();
    return ProfilePrefs(
      fontSize: FontSizeChoice.values.firstWhere(
        (c) => c.name == raw[PreferencesRepository.fontSizeKey],
        orElse: () => defaults.fontSize,
      ),
      gameSounds: flag(
        PreferencesRepository.gameSoundsKey,
        defaults.gameSounds,
      ),
      wifiOnly: flag(PreferencesRepository.wifiOnlyKey, defaults.wifiOnly),
      autoVideo: flag(PreferencesRepository.autoVideoKey, defaults.autoVideo),
    );
  }

  final FontSizeChoice fontSize;

  final bool gameSounds;

  final bool wifiOnly;

  final bool autoVideo;
}

class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  static const fontSizeKey = 'fontSize';
  static const gameSoundsKey = 'gameSounds';
  static const wifiOnlyKey = 'wifiOnly';
  static const autoVideoKey = 'autoVideo';

  static String _prefix(String profileId) =>
      SettingsDao.profilePrefsPrefix(profileId);

  Stream<ProfilePrefs> watch(String profileId) {
    final prefix = _prefix(profileId);
    return _db.settingsDao
        .watchByPrefix(prefix)
        .map(
          (rows) => ProfilePrefs.fromMap({
            for (final e in rows.entries)
              e.key.substring(prefix.length): e.value,
          }),
        );
  }

  Future<ProfilePrefs> read(String profileId) => watch(profileId).first;

  static const _bookmarkPart = 'bookmark.';

  Stream<Set<String>> watchBookmarks(String profileId) {
    final prefix = '${_prefix(profileId)}$_bookmarkPart';
    return _db.settingsDao
        .watchByPrefix(prefix)
        .map((rows) => {for (final k in rows.keys) k.substring(prefix.length)});
  }

  Future<void> setBookmarked(
    String profileId,
    String lessonId,
    bool saved,
  ) async {
    final key = '${_prefix(profileId)}$_bookmarkPart$lessonId';
    if (saved) {
      await _db.settingsDao.write(key, 'true');
    } else {
      await _db.settingsDao.remove(key);
    }
  }

  Future<void> setFontSize(String profileId, FontSizeChoice choice) =>
      _write(profileId, fontSizeKey, choice.name);

  Future<void> setGameSounds(String profileId, bool value) =>
      _write(profileId, gameSoundsKey, '$value');

  Future<void> setWifiOnly(String profileId, bool value) =>
      _write(profileId, wifiOnlyKey, '$value');

  Future<void> setAutoVideo(String profileId, bool value) =>
      _write(profileId, autoVideoKey, '$value');

  Future<void> _write(String profileId, String name, String value) {
    return _db.settingsDao.write('${_prefix(profileId)}$name', value);
  }
}
