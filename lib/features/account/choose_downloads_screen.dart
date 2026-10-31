import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_progress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../catalog/catalog_providers.dart';
import '../downloads/download_providers.dart';
import '../downloads/download_service.dart';
import 'downloads_providers.dart';
import 'widgets/download_updates.dart';
import 'widgets/item_list.dart';

class ChooseDownloadsScreen extends ConsumerStatefulWidget {
  const ChooseDownloadsScreen({super.key});

  @override
  ConsumerState<ChooseDownloadsScreen> createState() =>
      _ChooseDownloadsScreenState();
}

class _ChooseDownloadsScreenState extends ConsumerState<ChooseDownloadsScreen> {
  Set<String>? _selected;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(downloadItemsProvider).value;
    final titles = {
      for (final l in ref.watch(catalogProvider).value?.allLessons ?? const [])
        l.id: l.title,
    };
    final network = ref.watch(networkProvider).value ?? const [];
    final online =
        network.isNotEmpty && !network.contains(ConnectivityResult.none);
    final onMobile =
        online &&
        !network.contains(ConnectivityResult.wifi) &&
        !network.contains(ConnectivityResult.ethernet);
    final controller = ref.read(downloadControllerProvider.notifier);

    final choosable = [
      for (final i in items ?? const <DownloadItem>[])
        if (i.state != DownloadItemState.onPhone) i,
    ];
    final selected = _selected ??= {
      for (final i in choosable)
        if (i.state == DownloadItemState.queued) i.id,
    };
    final chosen = [
      for (final i in choosable)
        if (selected.contains(i.id)) i,
    ];
    final chosenBytes = chosen.fold<int>(0, (s, i) => s + i.size - i.received);

    void toggle(String id, bool on) => setState(() {
      on ? selected.add(id) : selected.remove(id);
    });

    final lessons = [
      for (final i in items ?? const <DownloadItem>[])
        if (i.kind == DownloadItemKind.lesson) i,
    ];
    final videos = [
      for (final i in items ?? const <DownloadItem>[])
        if (i.kind == DownloadItemKind.video) i,
    ];
    final files = [
      for (final i in items ?? const <DownloadItem>[])
        if (i.kind == DownloadItemKind.attachment) i,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: ArProgress.chooseTitle,
              subtitle: ArProgress.chooseKicker,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.downloads),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
                children: [
                  const DownloadProgressCard(),
                  if (items != null && items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        ArProgress.chooseNothing,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label14,
                      ),
                    ),
                  if (choosable.isNotEmpty)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => setState(() {
                          final all = chosen.length == choosable.length;
                          selected
                            ..clear()
                            ..addAll(
                              all ? const [] : choosable.map((i) => i.id),
                            );
                        }),
                        child: Text(
                          chosen.length == choosable.length
                              ? ArProgress.chooseNone
                              : ArProgress.chooseAll,
                          style: AppTextStyles.caption13.copyWith(
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  if (lessons.isNotEmpty)
                    ItemSection(
                      title: ArProgress.chooseLessons,
                      icon: 'book',
                      color: AppColors.teal,
                      tint: AppColors.tealTint,
                      children: [
                        for (final i in lessons)
                          ItemCheckRow(
                            item: i,
                            title: titles[i.lessonId] ?? i.lessonId,
                            note: i.isNew
                                ? ArProgress.chooseNew
                                : ArProgress.chooseUpdate,
                            selected: selected.contains(i.id),
                            onChanged: (on) => toggle(i.id, on),
                          ),
                      ],
                    ),
                  if (videos.isNotEmpty)
                    ItemSection(
                      title: ArProgress.chooseVideos,
                      icon: 'video',
                      color: AppColors.coral,
                      tint: AppColors.coralTint,
                      children: [
                        for (final i in videos)
                          ItemCheckRow(
                            item: i,
                            title: titles[i.lessonId] ?? i.lessonId,
                            selected: selected.contains(i.id),
                            onChanged: (on) => toggle(i.id, on),
                          ),
                      ],
                    ),
                  if (files.isNotEmpty)
                    ItemSection(
                      title: ArProgress.chooseFiles,
                      icon: 'file',
                      color: AppColors.purple,
                      tint: AppColors.purpleTint,
                      children: [
                        for (final i in files)
                          ItemCheckRow(
                            item: i,
                            title: titles[i.lessonId] ?? i.lessonId,
                            note: ArProgress.chooseFilesCount(i.blobs.length),
                            selected: selected.contains(i.id),
                            onChanged: (on) => toggle(i.id, on),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (choosable.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Text(
                      !online
                          ? ArProgress.chooseOffline
                          : onMobile && chosen.isNotEmpty
                          ? ArProgress.chooseMobileNote
                          : ArProgress.chooseSelected(
                              chosen.length,
                              formatBytes(chosenBytes),
                            ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption13,
                    ),
                    RizmaButton(
                      label: ArProgress.chooseDownload(
                        formatBytes(chosenBytes),
                      ),
                      icon: 'download',
                      onPressed: online
                          ? () => controller.applySelection({
                              ...selected,
                            }, allowMobile: true)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
