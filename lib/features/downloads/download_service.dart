import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../../core/db/app_database.dart';
import '../../core/db/daos/content_dao.dart';
import 'blob_store.dart';
import 'manifest.dart';

class ContentConfig {
  ContentConfig({required this.baseUrl, required this.publicKeys});

  final Uri baseUrl;
  final List<List<int>> publicKeys;

  Uri manifestUrl(int grade) =>
      baseUrl.resolve('v1/grades/$grade/manifest.json');
  Uri signatureUrl(int grade) =>
      baseUrl.resolve('v1/grades/$grade/manifest.json.sig');
  Uri blobUrl(String sha256) => baseUrl.resolve('v1/blobs/$sha256');

  static const publishedKeys = <String>[
    's1AlaQMvUWDGvu1X9XZIIIwgqnpKGgjOXPg2PsUhxf0=',
  ];

  static ContentConfig? fromEnvironment() {
    if (const String.fromEnvironment('RIZMA_CONTENT') == 'off') return null;
    const url = String.fromEnvironment(
      'RIZMA_CONTENT_URL',
      defaultValue: 'https://pub-dcb55d59ed024859b4a16e487625b9dd.r2.dev/',
    );
    if (url.isEmpty || publishedKeys.isEmpty) return null;
    return ContentConfig(
      baseUrl: Uri.parse(url.endsWith('/') ? url : '$url/'),
      publicKeys: [for (final k in publishedKeys) base64.decode(k)],
    );
  }
}

enum CheckResult { updated, unchanged, offline, rejected }

enum DownloadItemKind { lesson, video, attachment }

enum DownloadItemState { onPhone, queued, available }

class DownloadItem {
  DownloadItem._({
    required this.lessonId,
    required this.kind,
    required this.blobs,
    required Map<String, ContentDownload> queue,
    required Set<String> present,
    this.isNew = false,
  }) : received = blobs.keys.fold(0, (s, k) => s + (queue[k]?.received ?? 0)),
       state = blobs.keys.every(present.contains)
           ? DownloadItemState.onPhone
           : blobs.keys.any(queue.containsKey)
           ? DownloadItemState.queued
           : DownloadItemState.available;

  @visibleForTesting
  DownloadItem.test({
    required this.lessonId,
    required this.kind,
    required this.blobs,
    this.state = DownloadItemState.available,
    this.received = 0,
    this.isNew = false,
  });

  final String lessonId;
  final DownloadItemKind kind;

  final Map<String, int> blobs;

  final bool isNew;

  final DownloadItemState state;

  final int received;

  String get id => '${kind.name}:$lessonId';
  int get size => blobs.values.fold(0, (s, v) => s + v);
}

class DownloadProgress {
  const DownloadProgress({
    required this.sha256,
    required this.received,
    required this.size,
  });

  final String sha256;
  final int received;
  final int size;
}

class ShareInventory {
  const ShareInventory({
    required this.manifests,
    required this.core,
    required this.media,
  });

  final Map<int, (List<int>, List<int>)> manifests;

  final Map<String, int> core;

  final List<DownloadItem> media;

  Set<String> get blobs => {
    ...core.keys,
    for (final i in media) ...i.blobs.keys,
  };
}

enum RunResult { done, offline, stopped, storageFull }

class DownloadService {
  DownloadService(
    this._db,
    this._store,
    this._config, {
    http.Client? client,
    DateTime Function()? now,
    this.bundledLessonFile,
    this.bundledCatalog,
    this.idleTimeout = const Duration(seconds: 30),
    this.supportedContentFormat = 1,
    this.localSource = false,
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now,
       _verifier = ManifestVerifier(_config.publicKeys);

  final AppDatabase _db;
  final BlobStore _store;
  final ContentConfig _config;
  final http.Client _client;
  final DateTime Function() _now;
  final ManifestVerifier _verifier;

  final Future<List<int>?> Function(String lessonId, String path)?
  bundledLessonFile;

  final Future<List<int>?> Function(int grade)? bundledCatalog;

  final Duration idleTimeout;

  final int supportedContentFormat;

  final bool localSource;

  ContentDao get _dao => _db.contentDao;

  static const catalogPriority = 0;
  static const lessonPriority = 2;
  static const videoPriority = 3;

  static const attachmentPriority = 2;

  static BlobKind _blobKind(DownloadItemKind kind) => switch (kind) {
    DownloadItemKind.lesson => BlobKind.core,
    DownloadItemKind.video => BlobKind.video,
    DownloadItemKind.attachment => BlobKind.attachment,
  };

  static int _priority(DownloadItemKind kind) => switch (kind) {
    DownloadItemKind.lesson => lessonPriority,
    DownloadItemKind.video => videoPriority,
    DownloadItemKind.attachment => attachmentPriority,
  };

  Future<CheckResult> checkGrade(
    int grade, {
    required bool autoVideo,
    bool autoUpdate = true,
  }) async {
    final List<int> body;
    final List<int> signature;
    try {
      final res = await _client
          .get(_config.manifestUrl(grade))
          .timeout(idleTimeout);
      if (res.statusCode == 404) return CheckResult.unchanged;
      final sig = await _client
          .get(_config.signatureUrl(grade))
          .timeout(idleTimeout);
      if (res.statusCode != 200 || sig.statusCode != 200) {
        return CheckResult.offline;
      }
      body = res.bodyBytes;
      signature = sig.bodyBytes;
    } on Exception {
      return CheckResult.offline;
    }

    if (!await _verifier.verify(body, signature)) return CheckResult.rejected;
    final Manifest manifest;
    final String text;
    try {
      text = utf8.decode(body);
      manifest = Manifest.parse(text);
    } on FormatException {
      return CheckResult.rejected;
    }
    if (manifest.grade != grade) return CheckResult.rejected;

    final accepted = await _dao.acceptManifest(
      grade: grade,
      sequence: manifest.sequence,
      body: text,
      signature: base64Encode(signature),
      catalogSha256: manifest.catalog?.sha256,
      now: _now(),
    );
    if (!accepted) return CheckResult.rejected;

    var changed = false;
    final catalog = manifest.catalog;
    if (catalog != null && !await _dao.hasBlob(catalog.sha256)) {
      changed = true;
      final seeded = await _seed(
        catalog,
        () async => bundledCatalog?.call(grade),
      );
      if (!seeded) {
        await _enqueue(catalog, BlobKind.core, catalogPriority);
      }
    }

    for (final lesson in manifest.lessons) {
      if (lesson.contentFormat > supportedContentFormat) continue;
      changed |= await _dao.planLesson(
        lessonId: lesson.id,
        version: lesson.version,
        contentFormat: lesson.contentFormat,
        files: lesson.fileMap,
        videoSha256: lesson.video?.sha256,
        videoSize: lesson.video?.size,
        attachments: lesson.attachmentSizes,
      );
      final row = await _dao.lesson(lesson.id);
      if (row?.pendingVersion == lesson.version) {
        for (final f in lesson.files) {
          if (await _dao.hasBlob(f.sha256)) continue;
          final seeded = await _seed(
            f,
            () async => bundledLessonFile?.call(lesson.id, f.path),
          );
          if (!seeded && autoUpdate) {
            await _enqueue(f, BlobKind.core, lessonPriority);
          }
        }
      }
      final video = lesson.video;
      if (autoVideo && video != null && !await _dao.hasBlob(video.sha256)) {
        await _enqueue(video, BlobKind.video, videoPriority);
      }
    }

    changed |= (await _dao.activateReady(_now())).isNotEmpty;
    return changed ? CheckResult.updated : CheckResult.unchanged;
  }

  Future<bool> _seed(
    ManifestBlob blob,
    Future<List<int>?> Function() read,
  ) async {
    final List<int>? bytes;
    try {
      bytes = await read();
    } catch (_) {
      return false;
    }
    if (bytes == null || bytes.length > blob.size) return false;
    if (sha256.convert(bytes).toString() != blob.sha256) return false;
    await _store.writeBlob(blob.sha256, bytes);
    await _dao.completeDownload(
      sha256: blob.sha256,
      size: bytes.length,
      kind: BlobKind.core,
      now: _now(),
    );
    return true;
  }

  Future<void> _enqueue(ManifestBlob blob, BlobKind kind, int priority) =>
      _dao.enqueue(
        sha256: blob.sha256,
        size: blob.size,
        kind: kind,
        priority: priority,
        now: _now(),
      );

  Future<bool> requestVideo(String lessonId) async {
    final l = await _dao.lesson(lessonId);
    final sha = l?.videoSha256 ?? l?.pendingVideoSha256;
    final size = l?.videoSha256 != null ? l?.videoSize : l?.pendingVideoSize;
    if (sha == null || size == null) return false;
    await _dao.enqueue(
      sha256: sha,
      size: size,
      kind: BlobKind.video,
      priority: videoPriority,
      now: _now(),
    );
    return true;
  }

  Future<bool> requestAttachment(String lessonId, String sha256) async {
    final l = await _dao.lesson(lessonId);
    final size =
        ContentDao.decodeSizes(l?.attachments)[sha256] ??
        ContentDao.decodeSizes(l?.pendingAttachments)[sha256];
    if (size == null) return false;
    await _dao.enqueue(
      sha256: sha256,
      size: size,
      kind: BlobKind.attachment,
      priority: attachmentPriority,
      now: _now(),
    );
    return true;
  }

  Future<List<DownloadItem>> items() async {
    final present = {for (final b in await _dao.watchBlobs().first) b.sha256};
    final queue = {
      for (final d in await _dao.watchDownloads().first)
        if (d.failures < ContentDao.maxFailures) d.sha256: d,
    };
    final result = <DownloadItem>[];
    for (final m in await _dao.allManifests()) {
      final Manifest manifest;
      try {
        manifest = Manifest.parse(m.body);
      } on FormatException {
        continue;
      }
      for (final lesson in manifest.lessons) {
        if (lesson.contentFormat > supportedContentFormat) continue;
        final row = await _dao.lesson(lesson.id);
        if (row?.pendingVersion == lesson.version) {
          final missing = [
            for (final f in lesson.files)
              if (!present.contains(f.sha256)) f,
          ];
          if (missing.isNotEmpty) {
            result.add(
              DownloadItem._(
                lessonId: lesson.id,
                kind: DownloadItemKind.lesson,
                blobs: {for (final f in missing) f.sha256: f.size},
                isNew: (row?.version ?? 0) == 0,
                queue: queue,
                present: present,
              ),
            );
          }
        }
        final video = lesson.video;
        if (video != null) {
          result.add(
            DownloadItem._(
              lessonId: lesson.id,
              kind: DownloadItemKind.video,
              blobs: {video.sha256: video.size},
              queue: queue,
              present: present,
            ),
          );
        }
        if (lesson.attachments.isNotEmpty) {
          result.add(
            DownloadItem._(
              lessonId: lesson.id,
              kind: DownloadItemKind.attachment,
              blobs: lesson.attachmentSizes,
              queue: queue,
              present: present,
            ),
          );
        }
      }
    }
    return result;
  }

  Future<void> applySelection(Set<String> selectedIds) async {
    final all = await items();
    final wanted = <String>{
      for (final i in all)
        if (selectedIds.contains(i.id)) ...i.blobs.keys,
    };
    for (final i in all) {
      final kind = _blobKind(i.kind);
      final priority = _priority(i.kind);
      for (final MapEntry(key: sha, value: size) in i.blobs.entries) {
        if (wanted.contains(sha)) {
          await _dao.enqueue(
            sha256: sha,
            size: size,
            kind: kind,
            priority: priority,
            now: _now(),
          );
        } else {
          await _dao.cancelDownload(sha);
          await _store.deletePart(sha);
        }
      }
    }
  }

  Future<Set<String>> enqueueItems(
    Set<String> selectedIds, {
    Set<String>? only,
  }) async {
    final added = <String>{};
    for (final i in await items()) {
      if (!selectedIds.contains(i.id)) continue;
      for (final MapEntry(key: sha, value: size) in i.blobs.entries) {
        if (only != null && !only.contains(sha)) continue;
        if (await _dao.hasBlob(sha)) continue;
        await _dao.enqueue(
          sha256: sha,
          size: size,
          kind: _blobKind(i.kind),
          priority: _priority(i.kind),
          now: _now(),
        );
        added.add(sha);
      }
    }
    return added;
  }

  Future<ShareInventory> shareInventory() async {
    final present = {for (final b in await _dao.watchBlobs().first) b.sha256};
    final manifests = <int, (List<int>, List<int>)>{};
    final core = <String, int>{};
    final media = <DownloadItem>[];
    for (final m in await _dao.allManifests()) {
      final signature = m.signature;
      if (signature == null) continue;
      final Manifest manifest;
      try {
        manifest = Manifest.parse(m.body);
      } on FormatException {
        continue;
      }
      manifests[m.grade] = (utf8.encode(m.body), base64.decode(signature));
      final catalog = manifest.catalog;
      if (catalog != null && present.contains(catalog.sha256)) {
        core[catalog.sha256] = catalog.size;
      }
      for (final lesson in manifest.lessons) {
        if (lesson.files.every((f) => present.contains(f.sha256))) {
          for (final f in lesson.files) {
            core[f.sha256] = f.size;
          }
        }
        final video = lesson.video;
        if (video != null && present.contains(video.sha256)) {
          media.add(
            DownloadItem._(
              lessonId: lesson.id,
              kind: DownloadItemKind.video,
              blobs: {video.sha256: video.size},
              queue: const {},
              present: present,
            ),
          );
        }
        final files = {
          for (final a in lesson.attachments)
            if (present.contains(a.sha256)) a.sha256: a.size,
        };
        if (files.isNotEmpty) {
          media.add(
            DownloadItem._(
              lessonId: lesson.id,
              kind: DownloadItemKind.attachment,
              blobs: files,
              queue: const {},
              present: present,
            ),
          );
        }
      }
    }
    return ShareInventory(manifests: manifests, core: core, media: media);
  }

  Future<void> removeVideo(String lessonId) async {
    final sha = (await _dao.lesson(lessonId))?.videoSha256;
    if (sha == null) return;
    await _dao.cancelDownload(sha);
    await _store.deleteBlob(sha);
    await _store.deletePart(sha);
    await _dao.removeBlob(sha);
  }

  Future<void> removeAttachment(String sha256) async {
    await _dao.cancelDownload(sha256);
    await _store.deleteBlob(sha256);
    await _store.deletePart(sha256);
    await _dao.removeBlob(sha256);
  }

  Future<RunResult> runQueue({
    bool Function()? mayContinue,
    void Function(DownloadProgress progress)? onProgress,
    Set<String>? only,
  }) async {
    _onProgress = onProgress;
    try {
      return only == null
          ? await _run(mayContinue)
          : await _runOnly(mayContinue, only);
    } finally {
      _onProgress = null;
    }
  }

  void Function(DownloadProgress progress)? _onProgress;

  Future<RunResult> _run(bool Function()? mayContinue) async {
    while (true) {
      if (mayContinue != null && !mayContinue()) return RunResult.stopped;
      final next = await _dao.nextDownload();
      if (next == null) {
        await collectGarbage();
        return RunResult.done;
      }
      final stop = await _downloadOne(next);
      if (stop != null) return stop;
    }
  }

  Future<RunResult> _runOnly(
    bool Function()? mayContinue,
    Set<String> only,
  ) async {
    final tried = <String>{};
    while (true) {
      if (mayContinue != null && !mayContinue()) return RunResult.stopped;
      final queue =
          (await _dao.watchDownloads().first)
              .where(
                (d) =>
                    only.contains(d.sha256) &&
                    !tried.contains(d.sha256) &&
                    d.failures < ContentDao.maxFailures,
              )
              .toList()
            ..sort(
              (a, b) => a.priority != b.priority
                  ? a.priority.compareTo(b.priority)
                  : a.createdAt != b.createdAt
                  ? a.createdAt.compareTo(b.createdAt)
                  : a.sha256.compareTo(b.sha256),
            );
      if (queue.isEmpty) {
        await collectGarbage();
        return RunResult.done;
      }
      tried.add(queue.first.sha256);
      final stop = await _downloadOne(queue.first);
      if (stop != null) return stop;
    }
  }

  Future<RunResult?> _downloadOne(ContentDownload d) async {
    final sha = d.sha256;
    var have = await _store.partLength(sha);
    if (have > d.size) return _corrupt(sha, 'larger than the manifest');

    if (have < d.size) {
      final request = http.Request('GET', _config.blobUrl(sha));
      if (have > 0) request.headers['Range'] = 'bytes=$have-';
      final http.StreamedResponse res;
      try {
        res = await _client.send(request).timeout(idleTimeout);
      } on Exception catch (e) {
        await _dao.recordInterruption(sha, '$e');
        return RunResult.offline;
      }

      switch (res.statusCode) {
        case 200:
          have = 0;
        case 206:
          if (!(res.headers['content-range'] ?? '').startsWith(
            'bytes $have-',
          )) {
            await _drain(res);
            await _store.deletePart(sha);
            await _dao.recordInterruption(sha, 'unexpected range');
            return null;
          }
        case 404:
        case 416:
          await _drain(res);
          if (localSource) return null;
          return _corrupt(sha, 'http ${res.statusCode}');
        default:
          await _drain(res);
          await _dao.recordInterruption(sha, 'http ${res.statusCode}');
          return RunResult.offline;
      }

      switch (await _receive(d, res, from: have)) {
        case _Received():
          break;
        case _Handled():
          return null;
        case _Stop(:final result):
          return result;
      }
    }

    final length = await _store.partLength(sha);
    if (length == 0) {
      await _dao.recordInterruption(sha, 'nothing received');
      return RunResult.offline;
    }
    if (await _store.partSha256(sha) != sha) {
      if (length < d.size) {
        await _dao.recordProgress(sha, length);
        await _dao.recordInterruption(sha, 'incomplete');
        return RunResult.offline;
      }
      return _corrupt(sha, 'sha256 mismatch');
    }
    await _store.promote(sha);
    await _dao.completeDownload(
      sha256: sha,
      size: length,
      kind: d.kind,
      now: _now(),
    );
    await _dao.activateReady(_now());
    return null;
  }

  Future<_ReceiveOutcome> _receive(
    ContentDownload d,
    http.StreamedResponse res, {
    required int from,
  }) async {
    final sha = d.sha256;
    final IOSink sink;
    try {
      sink = await _store.openPart(sha, append: from > 0);
    } on FileSystemException {
      await _drain(res);
      return const _Stop(RunResult.storageFull);
    }
    var total = from;
    var saved = from;
    try {
      await for (final chunk in res.stream.timeout(idleTimeout)) {
        total += chunk.length;
        if (total > d.size) throw const _TooLarge();
        sink.add(chunk);
        _onProgress?.call(
          DownloadProgress(sha256: sha, received: total, size: d.size),
        );
        if (total - saved >= 256 * 1024) {
          await sink.flush();
          await _dao.recordProgress(sha, total);
          saved = total;
        }
      }
      await sink.close();
      return const _Received();
    } on _TooLarge {
      await _closeQuietly(sink);
      await _corrupt(sha, 'larger than the manifest');
      return const _Handled();
    } on FileSystemException {
      await _closeQuietly(sink);
      await _dao.recordProgress(sha, await _store.partLength(sha));
      return const _Stop(RunResult.storageFull);
    } on Exception catch (e) {
      await _closeQuietly(sink);
      await _dao.recordProgress(sha, await _store.partLength(sha));
      await _dao.recordInterruption(sha, '$e');
      return const _Stop(RunResult.offline);
    }
  }

  Future<RunResult?> _corrupt(String sha, String why) async {
    await _store.deletePart(sha);
    if (localSource) {
      await _dao.recordProgress(sha, 0);
      await _dao.recordInterruption(sha, 'local source: $why');
    } else {
      await _dao.recordCorrupt(sha, why);
    }
    return null;
  }

  static Future<void> _drain(http.StreamedResponse res) async {
    try {
      await res.stream.drain<void>();
    } catch (_) {}
  }

  static Future<void> _closeQuietly(IOSink sink) async {
    try {
      await sink.close();
    } catch (_) {}
  }

  Future<void> collectGarbage() async {
    for (final b in await _dao.unreferencedBlobs()) {
      await _store.deleteBlob(b.sha256);
      await _dao.removeBlob(b.sha256);
    }
    final queued = {
      for (final d in await _dao.watchDownloads().first) d.sha256,
    };
    await _store.deleteStrayParts(queued);
  }
}

class _TooLarge implements Exception {
  const _TooLarge();
}

sealed class _ReceiveOutcome {
  const _ReceiveOutcome();
}

class _Received extends _ReceiveOutcome {
  const _Received();
}

class _Handled extends _ReceiveOutcome {
  const _Handled();
}

class _Stop extends _ReceiveOutcome {
  const _Stop(this.result);
  final RunResult result;
}
