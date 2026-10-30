import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/math_text.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../content/lesson_content.dart';
import 'lesson_view.dart';
import 'widgets/part_frame.dart';

class PackScreen extends ConsumerStatefulWidget {
  const PackScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<PackScreen> createState() => _PackScreenState();
}

class _PackScreenState extends ConsumerState<PackScreen> {
  static const _sizes = [1.0, 1.2, 1.4];

  final _controller = PageController();
  int _page = 0;
  int _sizeIndex = 0;
  bool _completed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPage(int page, int total) {
    setState(() => _page = page);
    if (page == total - 1 && !_completed) {
      _completed = true;
      completeLessonPart(ref, lessonId: widget.lessonId, part: LessonPart.pack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(lessonViewProvider(widget.lessonId)).value;
    final pages = view?.content?.pages ?? const <PackPage>[];

    if (view == null || pages.isEmpty) {
      return PartFrame(
        title: ArLearn.packTitle,
        subtitle: view?.lesson.title ?? '',
        lessonId: widget.lessonId,
        child: const PartUnavailable(),
      );
    }

    final last = pages.length - 1;
    if (last == 0 && !_completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onPage(0, 1);
      });
    }
    return PartFrame(
      title: ArLearn.packTitle,
      subtitle: ArLearn.packKicker(view.lesson.title),
      lessonId: widget.lessonId,
      scrollable: false,
      end: TopTile(
        icon: 'type',
        label: ArLearn.packTextSize,
        onTap: () => setState(() => _sizeIndex = (_sizeIndex + 1) % 3),
      ),
      bottom: Row(
        spacing: 12,
        children: [
          Expanded(
            child: RizmaButton(
              label: ArLearn.previous,
              kind: ButtonKind.outlined,
              icon: 'back',
              onPressed: _page > 0 ? () => _go(_page - 1) : null,
            ),
          ),
          Expanded(
            child: RizmaButton(
              label: ArLearn.next,
              icon: 'fwd',
              onPressed: _page < last ? () => _go(_page + 1) : null,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              TagChip(label: ArLearn.packPage(_page + 1, pages.length)),
              const TagChip(
                label: ArLearn.packLoaded,
                icon: 'checkc',
                background: AppColors.sky,
                foreground: AppColors.soft,
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              for (var i = 0; i < pages.length; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= _page ? AppColors.teal : AppColors.sky2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (p) => _onPage(p, pages.length),
              itemBuilder: (context, i) =>
                  _PackPageCard(page: pages[i], scale: _sizes[_sizeIndex]),
            ),
          ),
          _Thumbnails(count: pages.length, current: _page, onTap: _go),
        ],
      ),
    );
  }
}

class _PackPageCard extends StatelessWidget {
  const _PackPageCard({required this.page, required this.scale});

  final PackPage page;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: LedgeBox(
        radius: 22,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (page.header.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TagChip(label: page.header, icon: 'book'),
                ),
              if (page.title.isNotEmpty)
                Text(
                  page.title,
                  style: AppTextStyles.section18.copyWith(fontSize: 18 * scale),
                ),
              for (final b in page.blocks) _Block(block: b, scale: scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block, required this.scale});

  final PackBlock block;
  final double scale;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'math':
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.blueTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Center(
              child: MathText(
                block.value,
                style: AppTextStyles.heading22.copyWith(
                  fontSize: 22 * scale,
                  color: AppColors.blue,
                ),
              ),
            ),
          ),
        );
      case 'image':
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.mute,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 96,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  block.value,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption13,
                ),
              ),
            ),
          ),
        );
      default:
        return MathText(
          block.value,
          style: AppTextStyles.body15.copyWith(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            height: 1.7,
          ),
        );
    }
  }
}

class _Thumbnails extends StatelessWidget {
  const _Thumbnails({
    required this.count,
    required this.current,
    required this.onTap,
  });

  final int count;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == current;
          return Semantics(
            button: true,
            selected: selected,
            label: ArLearn.packPageNumber(i + 1),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onTap(i),
              child: LedgeBox(
                color: selected ? AppColors.tealTint : AppColors.card,
                border: Border.all(
                  color: selected ? AppColors.teal : AppColors.line,
                  width: selected ? 2 : 1,
                ),
                radius: 12,
                child: SizedBox(
                  width: 44,
                  height: 46,
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.body15.copyWith(
                        color: selected ? AppColors.teal : AppColors.soft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
