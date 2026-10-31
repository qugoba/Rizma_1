import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_share.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../account/downloads_providers.dart';
import '../account/widgets/item_list.dart';
import '../../core/db/database_provider.dart';
import '../catalog/catalog_providers.dart';
import '../downloads/download_service.dart';
import 'rizma_package.dart';
import 'sharing_providers.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  Set<String>? _selected;

  double? _progress;
  bool _failed = false;

  Future<void> _send(ShareInventory inv, Set<String> selected) async {
    final sharing = ref.read(sharingServiceProvider).value;
    if (sharing == null) return;
    setState(() {
      _progress = 0;
      _failed = false;
    });
    try {
      final dir = await ref.read(shareTempDirProvider.future);
      await for (final old in dir.list()) {
        if (old is File) await old.delete();
      }
      final entries = sharing.packEntries(inv, selected);
      final total = RizmaPackage.sizeOf(entries);
      final now = ref.read(clockProvider)();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/rizma-$stamp.${RizmaPackage.extension}');
      await sharing.writePackage(
        file,
        entries,
        onProgress: (written) {
          if (mounted) setState(() => _progress = written / total);
        },
      );
      if (!mounted) return;
      setState(() => _progress = null);
      await ref.read(shareFileProvider)(file);
    } catch (_) {
      if (mounted) {
        setState(() {
          _progress = null;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = ref.watch(shareInventoryProvider).value;
    final titles = {
      for (final l in ref.watch(catalogProvider).value?.allLessons ?? const [])
        l.id: l.title,
    };
    final media = inv?.media ?? const <DownloadItem>[];
    final selected = _selected ??= {for (final i in media) i.id};
    final sharing = ref.watch(sharingServiceProvider).value;
    final entries = inv == null || sharing == null
        ? null
        : sharing.packEntries(inv, selected);
    final size = entries == null ? 0 : RizmaPackage.sizeOf(entries);
    final coreSize = inv?.core.values.fold<int>(0, (s, v) => s + v) ?? 0;
    final busy = _progress != null;
    final nothing = inv != null && inv.manifests.isEmpty;

    void toggle(String id, bool on) => setState(() {
      on ? selected.add(id) : selected.remove(id);
    });

    final videos = [
      for (final i in media)
        if (i.kind == DownloadItemKind.video) i,
    ];
    final files = [
      for (final i in media)
        if (i.kind == DownloadItemKind.attachment) i,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              showOffline: false,
              title: ArShare.sendTitle,
              subtitle: ArShare.sendKicker,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.downloads),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
                children: [
                  if (nothing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        ArShare.sendNothing,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label14,
                      ),
                    )
                  else if (inv != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: LedgeBox(
                        radius: 24,
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.teal,
                          ),
                          title: Text(
                            ArShare.sendCore(formatBytes(coreSize)),
                            style: AppTextStyles.body15,
                          ),
                          subtitle: Text(
                            ArShare.sendCoreNote,
                            style: AppTextStyles.caption13,
                          ),
                        ),
                      ),
                    ),
                    if (videos.isNotEmpty)
                      ItemSection(
                        title: ArShare.sendVideos,
                        icon: 'video',
                        color: AppColors.coral,
                        tint: AppColors.coralTint,
                        children: [
                          for (final i in videos)
                            ItemCheckRow(
                              item: i,
                              title: titles[i.lessonId] ?? i.lessonId,
                              sharing: true,
                              selected: selected.contains(i.id),
                              onChanged: busy
                                  ? (_) {}
                                  : (on) => toggle(i.id, on),
                            ),
                        ],
                      ),
                    if (files.isNotEmpty)
                      ItemSection(
                        title: ArShare.sendFiles,
                        icon: 'file',
                        color: AppColors.purple,
                        tint: AppColors.purpleTint,
                        children: [
                          for (final i in files)
                            ItemCheckRow(
                              item: i,
                              title: titles[i.lessonId] ?? i.lessonId,
                              sharing: true,
                              selected: selected.contains(i.id),
                              onChanged: busy
                                  ? (_) {}
                                  : (on) => toggle(i.id, on),
                            ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
            if (inv != null && !nothing)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Text(
                      _failed
                          ? ArShare.sendFailed
                          : busy
                          ? ArShare.sendPreparing((_progress! * 100).round())
                          : ArShare.sendNote,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption13.copyWith(
                        color: _failed ? AppColors.red : null,
                      ),
                    ),
                    if (busy)
                      LinearProgressIndicator(
                        value: _progress,
                        color: AppColors.teal,
                        backgroundColor: AppColors.sky2,
                      ),
                    RizmaButton(
                      label: ArShare.nearbySend,
                      icon: 'users',
                      onPressed: busy
                          ? null
                          : () => context.push(AppRoutes.shareNearby),
                    ),
                    RizmaButton(
                      label: ArShare.sendButton(formatBytes(size)),
                      icon: 'share',
                      kind: ButtonKind.outlined,
                      onPressed: busy ? null : () => _send(inv, {...selected}),
                    ),
                    RizmaButton(
                      label: ArShare.sendWifi,
                      icon: 'wifi',
                      kind: ButtonKind.outlined,
                      onPressed: busy
                          ? null
                          : () => context.push(AppRoutes.shareWifi),
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
