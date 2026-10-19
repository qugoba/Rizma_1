import 'package:flutter/material.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../catalog/catalog_models.dart';

Future<CatalogLesson?> showLessonSearchSheet(
  BuildContext context,
  Catalog catalog,
) {
  return showModalBottomSheet<CatalogLesson>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _SearchSheet(catalog: catalog),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.catalog});

  final Catalog catalog;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  String _query = '';

  List<CatalogLesson> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return [
      for (final l in widget.catalog.allLessons)
        if (l.title.toLowerCase().contains(q)) l,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyles.input17,
                  decoration: InputDecoration(
                    hintText: ArLearn.subjectsSearchHint,
                    hintStyle: AppTextStyles.input17.copyWith(
                      color: AppColors.placeholder,
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                ),
                if (_query.trim().isNotEmpty && results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      ArLearn.searchNoResults,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label14,
                    ),
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final l in results)
                        ListTile(
                          title: Text(l.title, style: AppTextStyles.body15),
                          subtitle: Text(
                            '${widget.catalog.subjectById(l.subjectId)?.title ?? ''}'
                            ' · ${widget.catalog.unitOfLesson(l)?.title ?? ''}',
                            style: AppTextStyles.caption13,
                          ),
                          onTap: () => Navigator.of(context).pop(l),
                        ),
                    ],
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
