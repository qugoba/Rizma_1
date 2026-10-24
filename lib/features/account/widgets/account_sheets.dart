import 'package:flutter/material.dart';

import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: builder,
  );
}

Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T value, String label)> options,
  required T selected,
}) {
  return _showSheet<T>(
    context,
    (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(title, style: AppTextStyles.section18),
            for (final (value, label) in options)
              _ChoiceTile(
                label: label,
                selected: value == selected,
                onTap: () => Navigator.of(context).pop(value),
              ),
          ],
        ),
      ),
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.tealTint : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppTextStyles.body15)),
                if (selected)
                  const Icon(Icons.check_rounded, color: AppColors.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<int?> showGradeSheet(
  BuildContext context, {
  required int current,
  required int? contentGrade,
}) {
  return _showSheet<int>(
    context,
    (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(ArStrings.gradeSheetTitle, style: AppTextStyles.section18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var grade = 1; grade <= 12; grade++)
                  _GradeChip(
                    grade: grade,
                    selected: grade == current,
                    onTap: () => Navigator.of(context).pop(grade),
                  ),
              ],
            ),
            if (contentGrade != null)
              Text(
                ArStrings.gradeContentSoon(contentGrade),
                style: AppTextStyles.caption13,
              ),
          ],
        ),
      ),
    ),
  );
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({
    required this.grade,
    required this.selected,
    required this.onTap,
  });

  final int grade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: ArStrings.gradeSemantics(grade),
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.teal : AppColors.card,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? AppColors.teal : AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 48,
            child: Center(
              child: Text(
                '$grade',
                style: AppTextStyles.gradeNumber24.copyWith(
                  fontSize: 20,
                  color: selected ? AppColors.card : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required List<String> paragraphs,
}) {
  return _showSheet<void>(
    context,
    (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(title, style: AppTextStyles.section18),
            for (final p in paragraphs) Text(p, style: AppTextStyles.body15),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(ArStrings.close),
            ),
          ],
        ),
      ),
    ),
  );
}
