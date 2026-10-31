import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/strings/ar_progress.dart';
import '../../core/strings/ar_share.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/dashed_border.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import '../catalog/catalog_providers.dart';
import '../downloads/download_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'account_providers.dart';
import 'downloads_providers.dart';
import 'widgets/download_updates.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  static String _partName(LessonPart p) => switch (p) {
    LessonPart.pack => ArLearn.partPack,
    LessonPart.explanation => ArLearn.partExplanation,
    LessonPart.summary => ArLearn.partSummary,
    LessonPart.video => ArLearn.partVideo,
    LessonPart.words => ArLearn.partWords,
    LessonPart.practice => ArLearn.partPractice,
    LessonPart.quiz => ArLearn.partQuiz,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installed = ref.watch(installedLessonsProvider).value;
    final total = ref.watch(catalogProvider).value?.allLessons.length ?? 0;
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final downloads = ref.read(downloadControllerProvider.notifier).available;

    final bytes = installed?.fold<int>(0, (s, l) => s + l.bytes) ?? 0;
    final count = installed?.length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: ArProgress.downloadsTitle,
              subtitle: ArProgress.downloadsKicker,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.account),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    const _Banner().fadeIn(0),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              const IconTile(
                                iconName: 'phone',
                                iconColor: AppColors.teal,
                                color: AppColors.tealTint,
                                size: 44,
                                iconSize: 22,
                              ),
                              Expanded(
                                child: Text(
                                  ArProgress.storageTitle,
                                  style: AppTextStyles.section18,
                                ),
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: TagChip(
                                  label: formatBytes(bytes),
                                  background: AppColors.amberTint,
                                  foreground: AppColors.amberInk,
                                ),
                              ),
                            ],
                          ),
                          ProgressBar(
                            value: total == 0
                                ? 0
                                : (count / total).clamp(0.0, 1.0),
                            trackColor: AppColors.sky2,
                            fillColor: AppColors.teal,
                            height: 10,
                          ),
                          Text(
                            ArProgress.storageNote(count, total),
                            style: AppTextStyles.label14,
                          ),
                        ],
                      ),
                    ).fadeIn(1),
                    if (downloads) const DownloadUpdatesCard().fadeIn(1),
                    if (downloads) const _ShareCard().fadeIn(1),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              const AppIcon(
                                'download',
                                size: 20,
                                color: AppColors.ink,
                              ),
                              Expanded(
                                child: Text(
                                  ArProgress.installedTitle,
                                  style: AppTextStyles.section18,
                                ),
                              ),
                              TagChip(label: ArLearn.lessonsCount(count)),
                            ],
                          ),
                          if (installed != null && installed.isEmpty)
                            Text(
                              ArProgress.installedEmpty,
                              style: AppTextStyles.label14,
                            ),
                          for (final (i, l)
                              in (installed ?? const []).indexed) ...[
                            _InstalledRow(
                              title: l.lesson.title,
                              parts: l.parts.map(_partName).join(' · '),
                              size: formatBytes(l.bytes),
                              last: i == installed!.length - 1,
                            ),
                            if (downloads)
                              LessonVideoRow(lessonId: l.lesson.id),
                          ],
                          Text(
                            downloads
                                ? ArProgress.installedNoteDownloads
                                : ArProgress.installedNote,
                            style: AppTextStyles.caption13,
                          ),
                        ],
                      ),
                    ).fadeIn(2),
                    _SyncCard(pending: pending).fadeIn(3),
                    const _TipCard().fadeIn(4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppIcon('check', size: 22, color: AppColors.card),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ArProgress.offlineBannerTitle,
                    style: AppTextStyles.body16Strong.copyWith(
                      color: AppColors.tealDark,
                    ),
                  ),
                  Text(
                    ArProgress.offlineBannerBody,
                    style: AppTextStyles.caption13,
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 24,
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _InstalledRow extends StatelessWidget {
  const _InstalledRow({
    required this.title,
    required this.parts,
    required this.size,
    required this.last,
  });

  final String title;
  final String parts;
  final String size;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title، $parts، $size',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: last ? Colors.transparent : AppColors.line,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            spacing: 12,
            children: [
              const IconTile(
                iconName: 'file',
                iconColor: AppColors.teal,
                color: AppColors.tealTint,
                size: 40,
                iconSize: 20,
                radius: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body15),
                    Text(parts, style: AppTextStyles.caption13),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TagChip(
                  label: size,
                  background: AppColors.sky,
                  foreground: AppColors.soft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.pending});

  final int pending;

  @override
  Widget build(BuildContext context) {
    return DashedBorderBox(
      color: AppColors.disabled,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArProgress.syncTitle, style: AppTextStyles.body16Strong),
                Text(
                  ArProgress.syncBody(pending),
                  style: AppTextStyles.caption13,
                ),
              ],
            ),
          ),
          const IconTile(
            iconName: 'sync',
            iconColor: AppColors.soft,
            color: AppColors.mute,
            radius: 14,
          ),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 12,
            children: [
              const IconTile(
                iconName: 'share',
                iconColor: AppColors.blue,
                color: AppColors.blueTint,
                size: 44,
                iconSize: 22,
              ),
              Expanded(
                child: Text(ArShare.cardTitle, style: AppTextStyles.section18),
              ),
            ],
          ),
          Text(ArShare.cardBody, style: AppTextStyles.label14),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: RizmaButton(
                  label: ArShare.cardSend,
                  icon: 'share',
                  height: 46,
                  onPressed: () => context.push(AppRoutes.share),
                ),
              ),
              Expanded(
                child: RizmaButton(
                  label: ArShare.cardReceive,
                  icon: 'download',
                  kind: ButtonKind.outlined,
                  height: 46,
                  onPressed: () => context.push(AppRoutes.receive),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipCard extends ConsumerWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color =
        ref.watch(activeProfileProvider).value?.color ?? ProfileColor.teal;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          spacing: 12,
          children: [
            Mascot(size: 52, color: color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ArProgress.downloadsTipTitle,
                    style: AppTextStyles.body15.copyWith(color: AppColors.teal),
                  ),
                  Text(
                    ArProgress.downloadsTipBody,
                    style: AppTextStyles.caption13,
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
