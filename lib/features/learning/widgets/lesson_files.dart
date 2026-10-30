import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../account/downloads_providers.dart';
import '../../content/lesson_content.dart';
import '../../downloads/download_providers.dart';
import 'learn_cards.dart';

class LessonFilesSection extends StatelessWidget {
  const LessonFilesSection({
    super.key,
    required this.lessonId,
    required this.attachments,
  });

  final String lessonId;
  final List<LessonAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        const SizedBox(height: 4),
        Row(
          spacing: 8,
          children: [
            const AppIcon('file', size: 20, color: AppColors.ink),
            Text(ArLearn.filesTitle, style: AppTextStyles.section18),
          ],
        ),
        for (final (i, a) in attachments.indexed)
          LessonFileRow(lessonId: lessonId, index: i, attachment: a),
      ],
    );
  }
}

class LessonFileRow extends ConsumerWidget {
  const LessonFileRow({
    super.key,
    required this.lessonId,
    required this.index,
    required this.attachment,
  });

  final String lessonId;
  final int index;
  final LessonAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      attachmentStatusProvider((lessonId: lessonId, sha256: attachment.file)),
    );
    final controller = ref.read(downloadControllerProvider.notifier);
    final size = formatBytes(attachment.sizeKb * 1024);
    final meta = switch (status) {
      AttachmentDownloaded() => ArLearn.filesOnPhone,
      AttachmentQueued(:final fraction) => ArLearn.filesDownloading(
        (fraction * 100).round(),
      ),
      AttachmentNotDownloaded() => ArLearn.filesOnline,
    };

    final Widget trailing = switch (status) {
      AttachmentDownloaded() => IconButton(
        key: Key('file-remove-$index'),
        tooltip: ArLearn.filesRemove,
        icon: const AppIcon('trash', size: 20, color: AppColors.muteText),
        onPressed: () => controller.removeAttachment(attachment.file),
      ),
      AttachmentQueued(:final fraction) => SizedBox.square(
        dimension: 40,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: CircularProgressIndicator(
            value: fraction == 0 ? null : fraction,
            strokeWidth: 3,
            color: AppColors.purple,
          ),
        ),
      ),
      AttachmentNotDownloaded(size: final known) =>
        known != null && controller.available
            ? IconButton(
                key: Key('file-download-$index'),
                tooltip: ArLearn.filesDownload(formatBytes(known)),
                icon: const AppIcon(
                  'download',
                  size: 22,
                  color: AppColors.purple,
                ),
                onPressed: () =>
                    controller.requestAttachment(lessonId, attachment.file),
              )
            : const SizedBox.shrink(),
    };

    return LearnRowCard(
      onTap: () => context.push(AppRoutes.lessonFile(lessonId, index)),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 6, 10),
      semanticsLabel: '${attachment.title}، PDF، $size، $meta',
      child: Row(
        spacing: 14,
        children: [
          const IconTile(
            iconName: 'file',
            iconColor: AppColors.purple,
            color: AppColors.purpleTint,
            radius: 14,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attachment.title, style: AppTextStyles.body16Strong),
                Text('PDF · $size · $meta', style: AppTextStyles.caption13),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
