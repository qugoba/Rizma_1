import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class ManifestBlob {
  const ManifestBlob({required this.sha256, required this.size});

  final String sha256;
  final int size;
}

class ManifestFile extends ManifestBlob {
  const ManifestFile({
    required this.path,
    required super.sha256,
    required super.size,
  });

  final String path;
}

class ManifestLesson {
  const ManifestLesson({
    required this.id,
    required this.version,
    required this.contentFormat,
    required this.files,
    this.video,
    this.videoMinutes,
    this.attachments = const [],
  });

  final String id;
  final int version;
  final int contentFormat;
  final List<ManifestFile> files;
  final ManifestBlob? video;
  final int? videoMinutes;

  final List<ManifestBlob> attachments;

  Map<String, int> get attachmentSizes => {
    for (final a in attachments) a.sha256: a.size,
  };

  Map<String, String> get fileMap => {for (final f in files) f.path: f.sha256};
}

class Manifest {
  const Manifest({
    required this.format,
    required this.grade,
    required this.sequence,
    required this.publishedAt,
    required this.lessons,
    this.catalog,
  });

  static const supportedFormat = 1;

  static const maxCoreFileSize = 20 * 1024 * 1024;
  static const maxVideoSize = 400 * 1024 * 1024;
  static const maxAttachmentSize = 50 * 1024 * 1024;
  static const maxAttachments = 20;

  final int format;
  final int grade;
  final int sequence;
  final DateTime publishedAt;
  final ManifestBlob? catalog;
  final List<ManifestLesson> lessons;

  static final _sha = RegExp(r'^[0-9a-f]{64}$');
  static final _id = RegExp(r'^[a-z0-9]+(\.[a-z0-9]+)*$');
  static final _path = RegExp(r'^[a-z0-9_\-]+(/[a-z0-9_\-]+)*\.[a-z0-9]+$');

  static Manifest parse(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const FormatException('manifest: not JSON');
    }
    final json = _map(decoded, 'manifest');
    final format = _int(json['format'], 'format', min: 1);
    if (format > supportedFormat) {
      throw FormatException('manifest: format $format is newer than this app');
    }
    final catalog = json['catalog'];
    return Manifest(
      format: format,
      grade: _int(json['grade'], 'grade', min: 1, max: 12),
      sequence: _int(json['sequence'], 'sequence', min: 1),
      publishedAt: _date(json['published_at']),
      catalog: catalog == null
          ? null
          : _blob(_map(catalog, 'catalog'), 'catalog', maxCoreFileSize),
      lessons: _lessons(json['lessons']),
    );
  }

  static List<ManifestLesson> _lessons(Object? raw) {
    if (raw is! List) throw const FormatException('manifest: lessons');
    final seen = <String>{};
    return [
      for (final item in raw)
        () {
          final l = _map(item, 'lesson');
          final id = _string(l['id'], 'lesson.id');
          if (!_id.hasMatch(id) || !seen.add(id)) {
            throw FormatException('manifest: bad or repeated lesson id $id');
          }
          final files = l['files'];
          if (files is! List || files.isEmpty) {
            throw FormatException('manifest: $id has no files');
          }
          final paths = <String>{};
          final parsed = [
            for (final f in files)
              () {
                final m = _map(f, '$id file');
                final path = _string(m['path'], '$id path');
                if (!_path.hasMatch(path) || !paths.add(path)) {
                  throw FormatException('manifest: bad path $path in $id');
                }
                final b = _blob(m, '$id/$path', maxCoreFileSize);
                return ManifestFile(path: path, sha256: b.sha256, size: b.size);
              }(),
          ];
          if (!paths.contains('lesson.json')) {
            throw FormatException('manifest: $id has no lesson.json');
          }
          final rawAttachments = l['attachments'] ?? const <Object?>[];
          if (rawAttachments is! List ||
              rawAttachments.length > maxAttachments) {
            throw FormatException('manifest: $id attachments');
          }
          final attachments = [
            for (final a in rawAttachments)
              _blob(
                _map(a, '$id attachment'),
                '$id attachment',
                maxAttachmentSize,
              ),
          ];
          final video = l['video'];
          final videoMap = video == null ? null : _map(video, '$id video');
          return ManifestLesson(
            id: id,
            version: _int(l['version'], '$id version', min: 1),
            contentFormat: _int(l['content_format'], '$id format', min: 1),
            files: parsed,
            video: videoMap == null
                ? null
                : _blob(videoMap, '$id video', maxVideoSize),
            videoMinutes: videoMap == null || videoMap['minutes'] == null
                ? null
                : _int(videoMap['minutes'], '$id minutes', min: 0),
            attachments: attachments,
          );
        }(),
    ];
  }

  static ManifestBlob _blob(Map<String, dynamic> m, String what, int max) {
    final sha = _string(m['sha256'], '$what sha256');
    if (!_sha.hasMatch(sha)) throw FormatException('manifest: $what sha256');
    return ManifestBlob(
      sha256: sha,
      size: _int(m['size'], '$what size', min: 1, max: max),
    );
  }

  static Map<String, dynamic> _map(Object? v, String what) {
    if (v is Map<String, dynamic>) return v;
    throw FormatException('manifest: $what is not an object');
  }

  static String _string(Object? v, String what) {
    if (v is String && v.isNotEmpty) return v;
    throw FormatException('manifest: $what');
  }

  static int _int(Object? v, String what, {int? min, int? max}) {
    if (v is! int || (min != null && v < min) || (max != null && v > max)) {
      throw FormatException('manifest: $what');
    }
    return v;
  }

  static DateTime _date(Object? v) {
    final d = v is String ? DateTime.tryParse(v) : null;
    if (d == null) throw const FormatException('manifest: published_at');
    return d;
  }
}

class ManifestVerifier {
  ManifestVerifier(this.publicKeys);

  final List<List<int>> publicKeys;
  final _ed25519 = Ed25519();

  Future<bool> verify(List<int> body, List<int> signature) async {
    if (signature.length != 64) return false;
    for (final key in publicKeys) {
      if (key.length != 32) continue;
      final ok = await _ed25519.verify(
        body,
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(key, type: KeyPairType.ed25519),
        ),
      );
      if (ok) return true;
    }
    return false;
  }
}
