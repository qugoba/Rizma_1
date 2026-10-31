import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/daos/content_dao.dart';
import '../../../core/strings/ar_progress.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/rizma_button.dart';
import '../../../app/routes.dart';
import '../../catalog/catalog_providers.dart';
import '../../downloads/download_providers.dart';
import '../../downloads/download_service.dart';
import '../account_providers.dart';
import '../downloads_providers.dart';
import '../preferences_repository.dart';

class DownloadUpdatesCard extends ConsumerWidget {
  const DownloadUpdatesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(downloadQueueProvider).value ?? const [];
    final status = ref.watch(downloadControllerProvider);
    final network = ref.watch(networkProvider).value ?? const [];
    final prefs =
        ref.watch(downloadPrefsProvider).value ?? const DownloadPrefs();
    final controller = ref.read(downloadControllerProvider.notifier);

    final active = [
      for (final d in queue)
        if (d.failures < ContentDao.maxFailures) d,
    ];
    final failed = queue.length - active.length;
    final total = active.fold<int>(0, (s, d) => s + d.size);
    final received = active.fold<int>(0, (s, d) => s + d.received);
    final left = formatBytes(total - received);
    final offline =
        network.isEmpty || network.contains(ConnectivityResult.none);

    final (String message, Widget? action) = switch (()) {
      _ when status.running => (ArProgress.updatesRunning, null),
      _ when active.isEmpty => (ArProgress.updatesNone, null),
      _ when offline => (
        '${ArProgress.updatesPending(left)} ${ArProgress.updatesOffline}',
        null,
      ),
      _ when status.last == RunResult.storageFull => (
        ArProgress.updatesStorageFull,
        null,
      ),
      _ when !downloadAllowed(network, wifiOnly: prefs.wifiOnly) => (
        ArProgress.updatesWaitingWifi,
        RizmaButton(
          label: ArProgress.updatesDownloadNow(left),
          icon: 'download',
          kind: ButtonKind.outlined,
          onPressed: () => controller.runNow(allowMobile: true),
        ),
      ),
      _ => (
        ArProgress.updatesPending(left),
        RizmaButton(
          label: ArProgress.updatesDownloadNow(left),
          icon: 'download',
          kind: ButtonKind.outlined,
          onPressed: controller.runNow,
        ),
      ),
    };

    return LedgeBox(
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              spacing: 12,
              children: [
                const IconTile(
                  iconName: 'download',
                  iconColor: AppColors.blue,
                  color: AppColors.blueTint,
                  size: 44,
                  iconSize: 22,
                ),
                Expanded(
                  child: Text(
                    ArProgress.updatesTitle,
                    style: AppTextStyles.section18,
                  ),
                ),
                if (!status.running)
                  TextButton(
                    onPressed: () => controller.refresh(force: true),
                    child: Text(
                      ArProgress.updatesCheck,
                      style: AppTextStyles.caption13.copyWith(
                        color: AppColors.teal,
                      ),
                    ),
                  ),
              ],
            ),
            if (status.running)
              const DownloadProgressCard(embedded: true)
            else
              Text(message, style: AppTextStyles.label14),
            if (failed > 0)
              Text(
                ArProgress.updatesFailed(failed),
                style: AppTextStyles.caption13,
              ),
            ?action,
            RizmaButton(
              label: ArProgress.updatesChoose,
              icon: 'list',
              kind: ButtonKind.outlined,
              onPressed: () => context.push(AppRoutes.downloadsChoose),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonVideoRow extends ConsumerWidget {
  const LessonVideoRow({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(videoStatusProvider(lessonId));
    final controller = ref.read(downloadControllerProvider.notifier);
    final (
      String label,
      String? button,
      VoidCallback? onTap,
    ) = switch (status) {
      VideoNone() => ('', null, null),
      VideoNotDownloaded(:final size) => (
        ArProgress.videoRowSize(formatBytes(size)),
        ArProgress.videoRowDownload,
        () => controller.requestVideo(lessonId),
      ),
      VideoQueued() && final q => (
        ArProgress.videoRowQueued((q.fraction * 100).round()),
        null,
        null,
      ),
      VideoDownloaded(:final size) => (
        ArProgress.videoRowSize(formatBytes(size)),
        ArProgress.videoRowRemove,
        () => controller.removeVideo(lessonId),
      ),
    };
    if (status is VideoNone) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 52, bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.caption13)),
          if (button != null)
            TextButton(
              onPressed: onTap,
              child: Text(
                button,
                style: AppTextStyles.caption13.copyWith(
                  color: status is VideoDownloaded
                      ? AppColors.coral
                      : AppColors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DownloadProgressCard extends ConsumerWidget {
  const DownloadProgressCard({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(downloadControllerProvider);
    if (!status.running) return const SizedBox.shrink();
    final current = status.current;
    final items = ref.watch(downloadItemsProvider).value ?? const [];
    final titles = {
      for (final l in ref.watch(catalogProvider).value?.allLessons ?? const [])
        l.id: l.title,
    };
    final item = current == null
        ? null
        : items.where((i) => i.blobs.containsKey(current.sha256)).firstOrNull;
    final name = item == null
        ? ArProgress.updatesRunning
        : [
            if (item.kind == DownloadItemKind.video) ArProgress.chooseVideos,
            titles[item.lessonId] ?? item.lessonId,
          ].join(': ');
    final fraction = current == null || current.size == 0
        ? 0.0
        : (current.received / current.size).clamp(0.0, 1.0);
    final speed = status.bytesPerSecond;
    final remaining = status.remaining;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(name, style: AppTextStyles.body15),
        ProgressBar(
          value: fraction,
          trackColor: AppColors.sky2,
          fillColor: AppColors.blue,
          height: 8,
        ),
        Text(
          current == null
              ? ArProgress.progressPreparing
              : ArProgress.progressLine(
                  (fraction * 100).round(),
                  speed == null ? null : formatDownloadSpeed(speed),
                  remaining == null ? null : formatRemaining(remaining),
                ),
          style: AppTextStyles.caption13,
        ),
      ],
    );
    if (embedded) return body;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LedgeBox(
        radius: 20,
        child: Padding(padding: const EdgeInsets.all(16), child: body),
      ),
    );
  }
}
