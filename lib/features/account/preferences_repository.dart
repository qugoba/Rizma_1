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
  });

  factory ProfilePrefs.fromMap(Map<String, String> raw) {
    const defaults = ProfilePrefs();
    return ProfilePrefs(
      fontSize: FontSizeChoice.values.firstWhere(
        (c) => c.name == raw[PreferencesRepository.fontSizeKey],
        orElse: () => defaults.fontSize,
      ),
      gameSounds: _flag(
        raw[PreferencesRepository.gameSoundsKey],
        defaults.gameSounds,
      ),
    );
  }

  final FontSizeChoice fontSize;

  final bool gameSounds;
}

bool _flag(String? raw, bool fallback) => switch (raw) {
  'true' => true,
  'false' => false,
  _ => fallback,
};

class DownloadPrefs {
  const DownloadPrefs({
    this.wifiOnly = true,
    this.autoVideo = false,
    this.autoUpdate = true,
  });

  factory DownloadPrefs.fromMap(Map<String, String> raw) {
    const defaults = DownloadPrefs();
    return DownloadPrefs(
      wifiOnly: _flag(raw[SettingsDao.wifiOnlyKey], defaults.wifiOnly),
      autoVideo: _flag(raw[SettingsDao.autoVideoKey], defaults.autoVideo),
      autoUpdate: _flag(raw[SettingsDao.autoUpdateKey], defaults.autoUpdate),
    );
  }

  final bool wifiOnly;

  final bool autoVideo;

  final bool autoUpdate;
}

class PreferencesRepository {
  PreferencesRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const fontSizeKey = 'fontSize';
  static const gameSoundsKey = 'gameSounds';

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

  Stream<Set<String>> watchBookmarks(String profileId) =>
      _db.profilesDao.watchBookmarks(profileId);

  Future<void> setBookmarked(String profileId, String lessonId, bool saved) =>
      _db.profilesDao.setBookmark(
        profileId: profileId,
        lessonId: lessonId,
        saved: saved,
        now: _now(),
      );

  Future<void> setFontSize(String profileId, FontSizeChoice choice) =>
      _write(profileId, fontSizeKey, choice.name);

  Future<void> setGameSounds(String profileId, bool value) =>
      _write(profileId, gameSoundsKey, '$value');

  Stream<DownloadPrefs> watchDownloads() => _db.settingsDao
      .watchByPrefix(SettingsDao.devicePrefix)
      .map(DownloadPrefs.fromMap);

  Future<DownloadPrefs> readDownloads() => watchDownloads().first;

  Future<void> setWifiOnly(bool value) =>
      _db.settingsDao.write(SettingsDao.wifiOnlyKey, '$value');

  Future<void> setAutoVideo(bool value) =>
      _db.settingsDao.write(SettingsDao.autoVideoKey, '$value');

  Future<void> setAutoUpdate(bool value) =>
      _db.settingsDao.write(SettingsDao.autoUpdateKey, '$value');

  Future<void> _write(String profileId, String name, String value) {
    return _db.settingsDao.write('${_prefix(profileId)}$name', value);
  }
}
