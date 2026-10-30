import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/content.dart';

part 'content_dao.g.dart';

@DriftAccessor(
  tables: [ContentManifests, ContentLessons, ContentBlobs, ContentDownloads],
)
class ContentDao extends DatabaseAccessor<AppDatabase> with _$ContentDaoMixin {
  ContentDao(super.db);

  static const maxFailures = 3;

  static Map<String, String> decodeFiles(String? json) => json == null
      ? const {}
      : (jsonDecode(json) as Map<String, dynamic>).cast<String, String>();

  static String? encodeSizes(Map<String, int> sizes) =>
      sizes.isEmpty ? null : jsonEncode(sizes);

  static Map<String, int> decodeSizes(String? json) => json == null
      ? const {}
      : (jsonDecode(json) as Map<String, dynamic>).cast<String, int>();

  static String encodeFiles(Map<String, String> files) => jsonEncode(
    Map.fromEntries(
      files.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ),
  );

  Future<ContentManifest?> manifest(int grade) => (select(
    contentManifests,
  )..where((m) => m.grade.equals(grade))).getSingleOrNull();

  Future<List<ContentManifest>> allManifests() => (select(
    contentManifests,
  )..orderBy([(m) => OrderingTerm.asc(m.grade)])).get();

  Future<bool> acceptManifest({
    required int grade,
    required int sequence,
    required String body,
    String? signature,
    required String? catalogSha256,
    required DateTime now,
  }) => transaction(() async {
    final current = await manifest(grade);
    if (current != null && sequence < current.sequence) return false;
    final pendingCatalog =
        catalogSha256 == null || catalogSha256 == current?.catalogSha256
        ? null
        : catalogSha256;
    await into(contentManifests).insertOnConflictUpdate(
      ContentManifestsCompanion.insert(
        grade: Value(grade),
        sequence: sequence,
        body: body,
        signature: Value(signature),
        catalogSha256: Value(current?.catalogSha256),
        pendingCatalogSha256: Value(pendingCatalog),
        fetchedAt: now,
      ),
    );
    return true;
  });

  Future<ContentLesson?> lesson(String lessonId) => (select(
    contentLessons,
  )..where((l) => l.lessonId.equals(lessonId))).getSingleOrNull();

  Stream<List<ContentLesson>> watchLessons() => select(contentLessons).watch();

  Future<bool> planLesson({
    required String lessonId,
    required int version,
    required int contentFormat,
    required Map<String, String> files,
    String? videoSha256,
    int? videoSize,
    Map<String, int> attachments = const {},
  }) => transaction(() async {
    final current = await lesson(lessonId);
    if (current != null &&
        (current.version >= version ||
            (current.pendingVersion ?? 0) >= version)) {
      return false;
    }
    await into(contentLessons).insert(
      ContentLessonsCompanion.insert(
        lessonId: lessonId,
        pendingVersion: Value(version),
        pendingContentFormat: Value(contentFormat),
        pendingFiles: Value(encodeFiles(files)),
        pendingVideoSha256: Value(videoSha256),
        pendingVideoSize: Value(videoSize),
        pendingAttachments: Value(encodeSizes(attachments)),
      ),
      onConflict: DoUpdate(
        (_) => ContentLessonsCompanion(
          pendingVersion: Value(version),
          pendingContentFormat: Value(contentFormat),
          pendingFiles: Value(encodeFiles(files)),
          pendingVideoSha256: Value(videoSha256),
          pendingVideoSize: Value(videoSize),
          pendingAttachments: Value(encodeSizes(attachments)),
        ),
      ),
    );
    return true;
  });

  Future<List<String>> activateReady(DateTime now) => transaction(() async {
    final present = {
      for (final b in await select(contentBlobs).get()) b.sha256,
    };

    for (final m in await (select(
      contentManifests,
    )..where((m) => m.pendingCatalogSha256.isNotNull())).get()) {
      if (present.contains(m.pendingCatalogSha256)) {
        await (update(
          contentManifests,
        )..where((r) => r.grade.equals(m.grade))).write(
          ContentManifestsCompanion(
            catalogSha256: Value(m.pendingCatalogSha256),
            pendingCatalogSha256: const Value(null),
          ),
        );
      }
    }

    final activated = <String>[];
    for (final l in await (select(
      contentLessons,
    )..where((l) => l.pendingVersion.isNotNull())).get()) {
      final files = decodeFiles(l.pendingFiles);
      if (!files.values.every(present.contains)) continue;
      await (update(
        contentLessons,
      )..where((r) => r.lessonId.equals(l.lessonId))).write(
        ContentLessonsCompanion(
          version: Value(l.pendingVersion!),
          contentFormat: Value(l.pendingContentFormat ?? 1),
          files: Value(l.pendingFiles!),
          videoSha256: Value(l.pendingVideoSha256),
          videoSize: Value(l.pendingVideoSize),
          attachments: Value(l.pendingAttachments),
          installedAt: Value(now),
          pendingVersion: const Value(null),
          pendingContentFormat: const Value(null),
          pendingFiles: const Value(null),
          pendingVideoSha256: const Value(null),
          pendingVideoSize: const Value(null),
          pendingAttachments: const Value(null),
        ),
      );
      activated.add(l.lessonId);
    }
    return activated;
  });

  Future<void> forgetInstalled(String lessonId) =>
      (update(contentLessons)..where((l) => l.lessonId.equals(lessonId))).write(
        const ContentLessonsCompanion(
          version: Value(0),
          files: Value('{}'),
          videoSha256: Value(null),
          videoSize: Value(null),
          attachments: Value(null),
          installedAt: Value(null),
        ),
      );

  Future<bool> hasBlob(String sha256) async =>
      await (select(
        contentBlobs,
      )..where((b) => b.sha256.equals(sha256))).getSingleOrNull() !=
      null;

  Stream<List<ContentBlob>> watchBlobs() => select(contentBlobs).watch();

  Future<List<ContentBlob>> unreferencedBlobs() async {
    final used = <String>{};
    for (final l in await select(contentLessons).get()) {
      used
        ..addAll(decodeFiles(l.files).values)
        ..addAll(decodeFiles(l.pendingFiles).values);
      if (l.videoSha256 != null) used.add(l.videoSha256!);
      if (l.pendingVideoSha256 != null) used.add(l.pendingVideoSha256!);
      used
        ..addAll(decodeSizes(l.attachments).keys)
        ..addAll(decodeSizes(l.pendingAttachments).keys);
    }
    for (final m in await select(contentManifests).get()) {
      if (m.catalogSha256 != null) used.add(m.catalogSha256!);
      if (m.pendingCatalogSha256 != null) used.add(m.pendingCatalogSha256!);
    }
    return [
      for (final b in await select(contentBlobs).get())
        if (!used.contains(b.sha256)) b,
    ];
  }

  Future<void> removeBlob(String sha256) =>
      (delete(contentBlobs)..where((b) => b.sha256.equals(sha256))).go();

  Future<void> enqueue({
    required String sha256,
    required int size,
    required BlobKind kind,
    required int priority,
    required DateTime now,
  }) => transaction(() async {
    if (await hasBlob(sha256)) return;
    final current = await (select(
      contentDownloads,
    )..where((d) => d.sha256.equals(sha256))).getSingleOrNull();
    if (current == null) {
      await into(contentDownloads).insert(
        ContentDownloadsCompanion.insert(
          sha256: sha256,
          size: size,
          kind: kind,
          priority: priority,
          createdAt: now,
        ),
      );
      return;
    }
    await (update(
      contentDownloads,
    )..where((d) => d.sha256.equals(sha256))).write(
      ContentDownloadsCompanion(
        priority: Value(
          priority < current.priority ? priority : current.priority,
        ),
        failures: const Value(0),
        lastError: const Value(null),
      ),
    );
  });

  Future<ContentDownload?> nextDownload() =>
      (select(contentDownloads)
            ..where((d) => d.failures.isSmallerThanValue(maxFailures))
            ..orderBy([
              (d) => OrderingTerm.asc(d.priority),
              (d) => OrderingTerm.asc(d.createdAt),
              (d) => OrderingTerm.asc(d.sha256),
            ])
            ..limit(1))
          .getSingleOrNull();

  Stream<List<ContentDownload>> watchDownloads() =>
      select(contentDownloads).watch();

  Future<void> recordProgress(String sha256, int received) =>
      (update(contentDownloads)..where((d) => d.sha256.equals(sha256))).write(
        ContentDownloadsCompanion(received: Value(received)),
      );

  Future<void> recordInterruption(String sha256, String error) =>
      (update(contentDownloads)..where((d) => d.sha256.equals(sha256))).write(
        ContentDownloadsCompanion(lastError: Value(error)),
      );

  Future<void> recordCorrupt(String sha256, String error) =>
      transaction(() async {
        final current = await (select(
          contentDownloads,
        )..where((d) => d.sha256.equals(sha256))).getSingleOrNull();
        if (current == null) return;
        await (update(
          contentDownloads,
        )..where((d) => d.sha256.equals(sha256))).write(
          ContentDownloadsCompanion(
            received: const Value(0),
            failures: Value(current.failures + 1),
            lastError: Value(error),
          ),
        );
      });

  Future<void> completeDownload({
    required String sha256,
    required int size,
    required BlobKind kind,
    required DateTime now,
  }) => transaction(() async {
    await into(contentBlobs).insertOnConflictUpdate(
      ContentBlobsCompanion.insert(
        sha256: sha256,
        size: size,
        kind: kind,
        verifiedAt: now,
      ),
    );
    await (delete(
      contentDownloads,
    )..where((d) => d.sha256.equals(sha256))).go();
  });

  Future<void> cancelDownload(String sha256) =>
      (delete(contentDownloads)..where((d) => d.sha256.equals(sha256))).go();

  Future<int> pendingBytes() async {
    var total = 0;
    for (final d in await (select(
      contentDownloads,
    )..where((d) => d.failures.isSmallerThanValue(maxFailures))).get()) {
      total += d.size - d.received;
    }
    return total;
  }
}
