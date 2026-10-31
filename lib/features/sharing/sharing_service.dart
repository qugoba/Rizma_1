import 'dart:io';

import 'package:http/http.dart' as http;

import '../downloads/blob_store.dart';
import '../downloads/download_service.dart';
import 'rizma_package.dart';

class LocalSource {
  LocalSource({
    required this.baseUrl,
    required this.client,
    required this.grades,
    required this.blobs,
    this.idleTimeout,
  });

  factory LocalSource.package(PackageReader reader) => LocalSource(
    baseUrl: PackageClient.baseUrl,
    client: PackageClient(reader),
    grades: reader.grades,
    blobs: reader.blobs,
  );

  final Uri baseUrl;
  final http.Client client;

  final Set<int> grades;

  final Set<String> blobs;

  final Duration? idleTimeout;
}

class ReceivePlan {
  const ReceivePlan({required this.items, required this.accepted});

  final List<DownloadItem> items;

  final bool accepted;

  int get size => items.fold(0, (s, i) => s + i.size - i.received);
}

class SharingService {
  SharingService({
    required this.store,
    required this.downloads,
    required this.localDownloads,
  });

  final BlobStore store;

  final DownloadService downloads;

  final DownloadService Function(LocalSource source) localDownloads;

  Future<ShareInventory> inventory() => downloads.shareInventory();

  List<PackEntry> packEntries(ShareInventory inv, Set<String> mediaIds) {
    final blobs = <String, int>{...inv.core};
    for (final i in inv.media) {
      if (mediaIds.contains(i.id)) blobs.addAll(i.blobs);
    }
    return [
      for (final MapEntry(key: grade, value: (body, sig))
          in inv.manifests.entries) ...[
        PackEntry.bytes('v1/grades/$grade/manifest.json', body),
        PackEntry.bytes('v1/grades/$grade/manifest.json.sig', sig),
      ],
      for (final MapEntry(key: sha, value: size) in blobs.entries)
        PackEntry.file('v1/blobs/$sha', store.blob(sha), size),
    ];
  }

  Future<void> writePackage(
    File out,
    List<PackEntry> entries, {
    void Function(int written)? onProgress,
  }) => RizmaPackage.write(out, entries, onProgress: onProgress);

  Future<ReceivePlan> open(LocalSource source) async {
    final local = localDownloads(source);
    var accepted = false;
    for (final grade in source.grades) {
      final result = await local.checkGrade(
        grade,
        autoVideo: false,
        autoUpdate: false,
      );
      accepted |=
          result == CheckResult.updated || result == CheckResult.unchanged;
    }
    final items = [
      for (final i in await local.items())
        if (i.state != DownloadItemState.onPhone &&
            i.blobs.keys.every(source.blobs.contains))
          i,
    ];
    return ReceivePlan(items: items, accepted: accepted);
  }

  Future<RunResult> receive(
    LocalSource source,
    Set<String> itemIds, {
    bool Function()? mayContinue,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    final local = localDownloads(source);
    final shas = await local.enqueueItems(itemIds, only: source.blobs);
    return local.runQueue(
      only: shas,
      mayContinue: mayContinue,
      onProgress: onProgress,
    );
  }
}
