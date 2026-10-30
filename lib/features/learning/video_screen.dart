import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../content/lesson_content.dart';
import '../profiles/active_profile_provider.dart';
import 'lesson_view.dart';
import 'widgets/lesson_video_area.dart';
import 'widgets/part_frame.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  int _selected = 0;

  final _seek = ValueNotifier<Duration?>(null);

  @override
  void dispose() {
    _seek.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(lessonViewProvider(widget.lessonId)).value;
    final video = view?.content?.video;

    if (view == null || video == null) {
      return PartFrame(
        title: ArLearn.videoTitle,
        subtitle: view?.lesson.title ?? '',
        lessonId: widget.lessonId,
        child: const PartUnavailable(),
      );
    }

    return PartFrame(
      title: ArLearn.videoTitle,
      subtitle: ArLearn.videoKicker(view.lesson.title, video.minutes),
      lessonId: widget.lessonId,
      bottom: view.content!.has(LessonPart.practice)
          ? RizmaButton(
              label: ArLearn.videoPracticeNow,
              icon: 'fwd',
              onPressed: () =>
                  context.pushReplacement(AppRoutes.round(widget.lessonId)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ArLearn.videoWatch, style: AppTextStyles.title26),
              Text(video.title, style: AppTextStyles.caption13),
            ],
          ),
          LessonVideoArea(
            lessonId: widget.lessonId,
            placeholder: _Player(video: video),
            seek: _seek,
            mbPerMinute: video.minutes > 0
                ? video.sizeMb / video.minutes
                : null,
            fileSha256: video.file,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(
                label: ArLearn.videoSize(video.sizeMb),
                icon: 'cloudoff',
                background: AppColors.sky,
                foreground: AppColors.soft,
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              const AppIcon('list', size: 20, color: AppColors.ink),
              Expanded(
                child: Text(ArLearn.videoParts, style: AppTextStyles.section18),
              ),
            ],
          ),
          for (final (i, p) in video.parts.indexed)
            _ChapterRow(
              part: p,
              selected: i == _selected,
              onTap: () {
                setState(() => _selected = i);
                _seek.value = parseVideoTime(p.at);
              },
            ),
          if (view.content!.has(LessonPart.practice)) const _NextHint(),
        ],
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.video});

  final VideoContent video;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${video.title}. ${ArLearn.videoUnavailable}',
      excludeSemantics: true,
      child: LedgeBox(
        color: AppColors.tealDark,
        radius: 24,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 190),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIcon('play', size: 30, color: AppColors.teal),
                  ),
                ),
                Text(
                  video.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body16Strong.copyWith(
                    color: AppColors.card,
                  ),
                ),
                Text(
                  ArLearn.videoUnavailable,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption13.copyWith(
                    color: AppColors.onTeal,
                  ),
                ),
                Text(
                  ArLearn.videoUnavailableNote,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption13.copyWith(
                    color: AppColors.mint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.part,
    required this.selected,
    required this.onTap,
  });

  final VideoPart part;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${part.title}، ${part.at}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: LedgeBox(
          radius: 18,
          color: selected ? AppColors.tealTint : AppColors.card,
          edge: selected ? AppColors.mint : null,
          border: selected ? Border.all(color: AppColors.teal, width: 2) : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              IconTile(
                iconName: 'play',
                iconColor: selected ? AppColors.card : AppColors.teal,
                color: selected ? AppColors.teal : AppColors.tealTint,
                size: 40,
                iconSize: 18,
                radius: 12,
              ),
              Expanded(child: Text(part.title, style: AppTextStyles.body15)),
              TagChip(
                label: part.at,
                background: selected ? AppColors.teal : AppColors.sky,
                foreground: selected ? AppColors.card : AppColors.soft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextHint extends ConsumerWidget {
  const _NextHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color =
        ref.watch(activeProfileProvider).value?.color ?? ProfileColor.teal;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealTint,
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
                    ArLearn.videoHintTitle,
                    style: AppTextStyles.body15.copyWith(color: AppColors.teal),
                  ),
                  Text(ArLearn.videoHintBody, style: AppTextStyles.caption13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
