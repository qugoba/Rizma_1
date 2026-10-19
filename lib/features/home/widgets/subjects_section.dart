import 'package:flutter/material.dart';

import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/rizma_look.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../core/widgets/progress_bar.dart';
import '../home_state.dart';

class SubjectsHeader extends StatelessWidget {
  const SubjectsHeader({super.key, required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
      child: Row(
        spacing: 8,
        children: [
          const AppIcon('book', size: 22, color: AppColors.ink),
          Expanded(
            child: Text(
              ArStrings.homeMySubjects,
              style: AppTextStyles.section18,
            ),
          ),
          TextButton(
            onPressed: onShowAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.teal,
              textStyle: AppTextStyles.label14,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(ArStrings.homeShowAll),
          ),
        ],
      ),
    );
  }
}

class SubjectsCarousel extends StatelessWidget {
  const SubjectsCarousel({
    super.key,
    required this.subjects,
    required this.onOpen,
  });

  final List<SubjectProgress> subjects;
  final ValueChanged<SubjectProgress> onOpen;

  @override
  Widget build(BuildContext context) {
    final calm = RizmaLook.of(context).calm;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
      child: calm
          ? LedgeBox(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (final (i, s) in subjects.indexed) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.line),
                    _SubjectRow(progress: s, onTap: () => onOpen(s)),
                  ],
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, box) {
                final columns = box.maxWidth < 300 ? 2 : 3;
                const gap = 10.0;
                final width = (box.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final s in subjects)
                      SizedBox(
                        width: width,
                        child: _SubjectTile(
                          progress: s,
                          onTap: () => onOpen(s),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.progress, required this.onTap});

  final SubjectProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subject = progress.subject;
    final accent = subject.color.fg;
    final percent = (progress.fraction * 100).round();

    return LedgeBox(
      radius: 20,
      clip: true,
      child: Material(
        color: AppColors.card,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              spacing: 8,
              children: [
                IconTile(
                  iconName: subject.icon,
                  iconColor: accent,
                  color: subject.color.tint,
                  size: 52,
                  iconSize: 26,
                  radius: 16,
                ),
                Text(
                  subject.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTextStyles.body15,
                ),
                Text(
                  progress.started ? '$percent%' : ArStrings.homeNotStarted,
                  style: AppTextStyles.caption12.copyWith(
                    color: progress.started ? accent : AppColors.muteText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).pressable();
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.progress, required this.onTap});

  final SubjectProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subject = progress.subject;
    final accent = subject.color.fg;
    final percent = (progress.fraction * 100).round();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            IconTile(
              iconName: subject.icon,
              iconColor: accent,
              color: subject.color.tint,
              size: 40,
              iconSize: 20,
              radius: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(subject.title, style: AppTextStyles.body15),
                      ),
                      Text(
                        progress.started
                            ? '$percent%'
                            : ArStrings.homeNotStarted,
                        style: AppTextStyles.caption12,
                      ),
                    ],
                  ),
                  ProgressBar(
                    value: progress.fraction,
                    trackColor: AppColors.sky2,
                    fillColor: accent,
                    height: 6,
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
