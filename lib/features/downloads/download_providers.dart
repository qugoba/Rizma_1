import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/db/app_database.dart';
import '../../core/db/daos/content_dao.dart';
import '../../core/db/database_provider.dart';
import '../account/account_providers.dart';
import 'blob_store.dart';
import 'download_service.dart';
import 'installed_content.dart';

final contentConfigProvider = Provider<ContentConfig?>(
  (ref) => ContentConfig.fromEnvironment(),
);

final blobStoreProvider = FutureProvider<BlobStore>((ref) async {
  final dir = await getApplicationSupportDirectory();
  return BlobStore(Directory('${dir.path}/content'));
});

final installedContentProvider = Provider<InstalledContent>((ref) {
  return DbInstalledContent(
    ref.watch(appDatabaseProvider),
    () => ref.read(blobStoreProvider.future),
  );
});

final downloadServiceProvider = FutureProvider<DownloadService?>((ref) async {
  final config = ref.watch(contentConfigProvider);
  if (config == null || kIsWeb) return null;
  return buildDownloadService(
    ref,
    await ref.watch(blobStoreProvider.future),
    config,
  );
});

DownloadService buildDownloadService(
  Ref ref,
  BlobStore store,
  ContentConfig config, {
  http.Client? client,
  bool localSource = false,
  Duration? idleTimeout,
}) => DownloadService(
  ref.read(appDatabaseProvider),
  store,
  config,
  client: client,
  localSource: localSource,
  idleTimeout: idleTimeout ?? const Duration(seconds: 30),
  now: ref.read(clockProvider),
  bundledLessonFile: (id, path) => path == 'lesson.json'
      ? _asset('assets/content/lessons/$id.json')
      : Future.value(null),
  bundledCatalog: (grade) => _asset('assets/content/catalog_grade$grade.json'),
);

Future<List<int>?> _asset(String path) async {
  try {
    return (await rootBundle.load(path)).buffer.asUint8List();
  } catch (_) {
    return null;
  }
}

const manifestCheckInterval = Duration(hours: 24);

String manifestCheckedKey(int grade) => 'content.checkedAt.$grade';

bool downloadAllowed(
  List<ConnectivityResult> network, {
  required bool wifiOnly,
}) {
  if (network.contains(ConnectivityResult.none) || network.isEmpty) {
    return false;
  }
  if (!wifiOnly) return true;
  return network.contains(ConnectivityResult.wifi) ||
      network.contains(ConnectivityResult.ethernet);
}

final networkProvider = StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

final downloadQueueProvider = StreamProvider<List<ContentDownload>>(
  (ref) => ref.watch(appDatabaseProvider).contentDao.watchDownloads(),
);

final contentLessonsProvider = StreamProvider<List<ContentLesson>>(
  (ref) => ref.watch(appDatabaseProvider).contentDao.watchLessons(),
);

final contentBlobsProvider = StreamProvider<Set<String>>(
  (ref) => ref
      .watch(appDatabaseProvider)
      .contentDao
      .watchBlobs()
      .map((rows) => {for (final b in rows) b.sha256}),
);

sealed class VideoStatus {
  const VideoStatus();
}

class VideoNone extends VideoStatus {
  const VideoNone();
}

class VideoNotDownloaded extends VideoStatus {
  const VideoNotDownloaded(this.size, {required this.sha256});
  final int size;
  final String sha256;
}

class VideoQueued extends VideoStatus {
  const VideoQueued({
    required this.received,
    required this.size,
    required this.sha256,
  });
  final int received;
  final int size;
  final String sha256;

  double get fraction => size == 0 ? 0 : (received / size).clamp(0.0, 1.0);
}

class VideoDownloaded extends VideoStatus {
  const VideoDownloaded({required this.sha256, required this.size});
  final String sha256;
  final int size;
}

final videoStatusProvider = Provider.family<VideoStatus, String>((
  ref,
  lessonId,
) {
  final lessons = ref.watch(contentLessonsProvider).value ?? const [];
  final row = lessons.where((l) => l.lessonId == lessonId).firstOrNull;
  if (row == null) return const VideoNone();
  final installed = row.videoSha256 != null;
  final sha = installed ? row.videoSha256 : row.pendingVideoSha256;
  final size = installed ? row.videoSize : row.pendingVideoSize;
  if (sha == null || size == null) return const VideoNone();
  final blobs = ref.watch(contentBlobsProvider).value ?? const <String>{};
  if (blobs.contains(sha)) return VideoDownloaded(sha256: sha, size: size);
  final queue = ref.watch(downloadQueueProvider).value ?? const [];
  final queued = queue.where((d) => d.sha256 == sha).firstOrNull;
  if (queued != null && queued.failures < ContentDao.maxFailures) {
    return VideoQueued(received: queued.received, size: size, sha256: sha);
  }
  return VideoNotDownloaded(size, sha256: sha);
});

final videoStreamUrlProvider = Provider.family<Uri?, String>((ref, lessonId) {
  final config = ref.watch(contentConfigProvider);
  if (config == null) return null;
  return switch (ref.watch(videoStatusProvider(lessonId))) {
    VideoNotDownloaded(:final sha256) ||
    VideoQueued(:final sha256) => config.blobUrl(sha256),
    _ => null,
  };
});

final videoFileProvider = FutureProvider.family<File?, String>((
  ref,
  lessonId,
) async {
  final status = ref.watch(videoStatusProvider(lessonId));
  if (status is! VideoDownloaded) return null;
  final file = (await ref.watch(blobStoreProvider.future)).blob(status.sha256);
  return await file.exists() ? file : null;
});

typedef AttachmentRef = ({String lessonId, String sha256});

sealed class AttachmentStatus {
  const AttachmentStatus();
}

class AttachmentNotDownloaded extends AttachmentStatus {
  const AttachmentNotDownloaded(this.size);
  final int? size;
}

class AttachmentQueued extends AttachmentStatus {
  const AttachmentQueued({required this.received, required this.size});
  final int received;
  final int size;

  double get fraction => size == 0 ? 0 : (received / size).clamp(0.0, 1.0);
}

class AttachmentDownloaded extends AttachmentStatus {
  const AttachmentDownloaded();
}

final attachmentStatusProvider =
    Provider.family<AttachmentStatus, AttachmentRef>((ref, a) {
      final blobs = ref.watch(contentBlobsProvider).value ?? const <String>{};
      if (blobs.contains(a.sha256)) return const AttachmentDownloaded();
      final lessons = ref.watch(contentLessonsProvider).value ?? const [];
      final row = lessons.where((l) => l.lessonId == a.lessonId).firstOrNull;
      final size =
          ContentDao.decodeSizes(row?.attachments)[a.sha256] ??
          ContentDao.decodeSizes(row?.pendingAttachments)[a.sha256];
      final queue = ref.watch(downloadQueueProvider).value ?? const [];
      final queued = queue.where((d) => d.sha256 == a.sha256).firstOrNull;
      if (queued != null && queued.failures < ContentDao.maxFailures) {
        return AttachmentQueued(
          received: queued.received,
          size: size ?? queued.size,
        );
      }
      return AttachmentNotDownloaded(size);
    });

final attachmentBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, String>((ref, sha) async {
      if (!kIsWeb) {
        final file = (await ref.watch(blobStoreProvider.future)).blob(sha);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (sha256.convert(bytes).toString() == sha) return bytes;
        }
      }
      final config = ref.watch(contentConfigProvider);
      if (config == null) throw const AttachmentUnavailable();
      final http.Response res;
      try {
        res = await http
            .get(config.blobUrl(sha))
            .timeout(const Duration(seconds: 60));
      } on Exception {
        throw const AttachmentUnavailable(offline: true);
      }
      if (res.statusCode != 200 ||
          sha256.convert(res.bodyBytes).toString() != sha) {
        throw const AttachmentUnavailable();
      }
      return res.bodyBytes;
    });

class AttachmentUnavailable implements Exception {
  const AttachmentUnavailable({this.offline = false});
  final bool offline;
}

class DownloadStatus {
  const DownloadStatus({
    this.running = false,
    this.last,
    this.current,
    this.bytesPerSecond,
  });

  final bool running;

  final RunResult? last;

  final DownloadProgress? current;

  final double? bytesPerSecond;

  Duration? get remaining {
    final c = current;
    final speed = bytesPerSecond;
    if (c == null || speed == null || speed <= 0) return null;
    return Duration(seconds: ((c.size - c.received) / speed).ceil());
  }
}

String formatDownloadSpeed(double bytesPerSecond) {
  final kb = bytesPerSecond / 1024;
  return kb < 1024
      ? '${kb.round()} KB/s'
      : '${(kb / 1024).toStringAsFixed(1)} MB/s';
}

String formatRemaining(Duration d) =>
    d.inSeconds < 60 ? '${d.inSeconds} ث' : '${(d.inSeconds / 60).ceil()} د';

final downloadItemsProvider = FutureProvider.autoDispose<List<DownloadItem>>((
  ref,
) async {
  ref.watch(downloadQueueProvider);
  ref.watch(contentBlobsProvider);
  ref.watch(contentLessonsProvider);
  final service = await ref.watch(downloadServiceProvider.future);
  return service == null ? const [] : service.items();
});

class DownloadController extends Notifier<DownloadStatus> {
  Future<void>? _busy;

  @override
  DownloadStatus build() => const DownloadStatus();

  bool get available => ref.read(contentConfigProvider) != null && !kIsWeb;

  Future<void> refresh({bool force = false}) => _exclusive(() async {
    final service = await ref.read(downloadServiceProvider.future);
    if (service == null) return;
    final network = await ref.read(networkProvider.future);
    if (network.isEmpty || network.contains(ConnectivityResult.none)) return;

    final db = ref.read(appDatabaseProvider);
    final prefs = await ref.read(preferencesRepositoryProvider).readDownloads();
    final now = ref.read(clockProvider)();
    final grades = {for (final p in await db.profilesDao.getAll()) p.grade};
    for (final grade in grades) {
      final last = DateTime.tryParse(
        await db.settingsDao.read(manifestCheckedKey(grade)) ?? '',
      );
      if (!force &&
          last != null &&
          now.difference(last) < manifestCheckInterval) {
        continue;
      }
      final result = await service.checkGrade(
        grade,
        autoVideo: prefs.autoVideo,
        autoUpdate: prefs.autoUpdate,
      );
      if (result != CheckResult.offline) {
        await db.settingsDao.write(
          manifestCheckedKey(grade),
          now.toIso8601String(),
        );
      }
    }
    await _runQueue(service, allowMobile: false);
  });

  Future<void> runNow({bool allowMobile = false}) => _exclusive(() async {
    final service = await ref.read(downloadServiceProvider.future);
    if (service == null) return;
    await _runQueue(service, allowMobile: allowMobile);
  });

  Future<void> requestVideo(String lessonId) async {
    final service = await ref.read(downloadServiceProvider.future);
    if (service == null) return;
    if (await service.requestVideo(lessonId)) await runNow();
  }

  Future<void> removeVideo(String lessonId) async {
    final service = await ref.read(downloadServiceProvider.future);
    await service?.removeVideo(lessonId);
  }

  Future<void> requestAttachment(String lessonId, String sha256) async {
    final service = await ref.read(downloadServiceProvider.future);
    if (service == null) return;
    if (await service.requestAttachment(lessonId, sha256)) await runNow();
  }

  Future<void> removeAttachment(String sha256) async {
    final service = await ref.read(downloadServiceProvider.future);
    await service?.removeAttachment(sha256);
  }

  Future<RunResult?> receiveFrom(
    Future<RunResult> Function(
      void Function(DownloadProgress progress) onProgress,
    )
    receive,
  ) async {
    while (_busy != null) {
      await _busy;
    }
    RunResult? result;
    await _exclusive(() async {
      result = await _tracked((onProgress) => receive(onProgress));
    });
    return result;
  }

  Future<void> applySelection(
    Set<String> itemIds, {
    bool allowMobile = false,
  }) async {
    final service = await ref.read(downloadServiceProvider.future);
    if (service == null) return;
    await service.applySelection(itemIds);
    await runNow(allowMobile: allowMobile);
  }

  Future<void> _runQueue(
    DownloadService service, {
    required bool allowMobile,
  }) async {
    final prefs = await ref.read(preferencesRepositoryProvider).readDownloads();
    await _tracked(
      (onProgress) => service.runQueue(
        mayContinue: () => downloadAllowed(
          ref.read(networkProvider).value ?? const [],
          wifiOnly: prefs.wifiOnly && !allowMobile,
        ),
        onProgress: onProgress,
      ),
    );
  }

  Future<RunResult?> _tracked(
    Future<RunResult> Function(
      void Function(DownloadProgress progress) onProgress,
    )
    run,
  ) async {
    state = DownloadStatus(running: true, last: state.last);
    RunResult? result;
    String? sha;
    var lastBytes = 0;
    final clock = Stopwatch()..start();
    var lastMs = 0;
    double? speed;
    void onProgress(DownloadProgress p) {
      if (p.sha256 != sha) {
        sha = p.sha256;
        lastBytes = p.received;
        lastMs = clock.elapsedMilliseconds;
        state = DownloadStatus(
          running: true,
          last: state.last,
          current: p,
          bytesPerSecond: speed,
        );
        return;
      }
      final dt = clock.elapsedMilliseconds - lastMs;
      if (dt < 500) return;
      final now = (p.received - lastBytes) * 1000 / dt;
      speed = speed == null ? now : speed! * 0.6 + now * 0.4;
      lastBytes = p.received;
      lastMs = clock.elapsedMilliseconds;
      state = DownloadStatus(
        running: true,
        last: state.last,
        current: p,
        bytesPerSecond: speed,
      );
    }

    try {
      result = await run(onProgress);
    } finally {
      state = DownloadStatus(last: result ?? state.last);
    }
    return result;
  }

  Future<void> _exclusive(Future<void> Function() body) async {
    final current = _busy;
    if (current != null) return current;
    final run = () async {
      try {
        await body();
      } catch (_) {}
    }();
    _busy = run;
    try {
      await run;
    } finally {
      _busy = null;
    }
  }
}

final downloadControllerProvider =
    NotifierProvider<DownloadController, DownloadStatus>(
      DownloadController.new,
    );

class DownloadScheduler extends ConsumerStatefulWidget {
  const DownloadScheduler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DownloadScheduler> createState() => _DownloadSchedulerState();
}

class _DownloadSchedulerState extends ConsumerState<DownloadScheduler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (!ref.read(downloadControllerProvider.notifier).available) return;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() => ref.read(downloadControllerProvider.notifier).refresh();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
