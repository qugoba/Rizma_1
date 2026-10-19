import 'package:flutter/material.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/math_text.dart';
import '../../content/question.dart';
import '../round_engine.dart';
import 'question_context.dart';
import 'question_parts.dart';

class DragDropView extends StatefulWidget {
  const DragDropView({super.key, required this.context_});

  final QuestionContext context_;

  @override
  State<DragDropView> createState() => _DragDropViewState();
}

class _DragDropViewState extends State<DragDropView> {
  int? _placed;

  void _place(int? card) {
    setState(() => _placed = card);
    final cards = widget.context_.layout.cards;
    widget.context_.onAnswer(card == null ? null : cards[card]);
  }

  Widget _cardFace(String text, {Color? color, bool lifted = false}) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color ?? AppColors.line, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: lifted ? const Color(0x33000000) : AppColors.track,
            offset: const Offset(0, 4),
            blurRadius: lifted ? 10 : 0,
          ),
        ],
      ),
      child: MathText(
        text,
        style: AppTextStyles.heading22.copyWith(color: color ?? AppColors.ink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context_;
    final q = c.question as DragDropQuestion;
    final cards = c.layout.cards;
    final chip = kindChip(q.kind);

    final Widget slot = DragTarget<int>(
      onWillAcceptWithDetails: (_) => !c.locked,
      onAcceptWithDetails: (d) => _place(d.data),
      builder: (context, candidate, _) {
        final text = c.revealed
            ? q.answer
            : (_placed == null ? null : cards[_placed!]);
        final good = c.phase == RoundPhase.correct || c.revealed;
        final color = good ? AppColors.teal : AppColors.blue;
        return Semantics(
          button: text != null && !c.locked,
          label: text ?? '؟',
          child: GestureDetector(
            onTap: c.locked || _placed == null ? null : () => _place(null),
            child: DashedBorderBox(
              color: candidate.isNotEmpty ? AppColors.teal : color,
              radius: 10,
              strokeWidth: 1.8,
              dash: 6,
              gap: 4,
              child: Container(
                width: 56,
                height: 52,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: good ? AppColors.tealTint : AppColors.blueTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  text ?? '?',
                  style: AppTextStyles.heading22.copyWith(color: color),
                ),
              ),
            ),
          ),
        );
      },
    );

    Widget tray(int i) {
      final used = _placed == i || (c.revealed && cards[i] == q.answer);
      if (used) {
        return const DashedBorderBox(
          color: AppColors.disabled,
          radius: 16,
          child: SizedBox(width: 64, height: 64),
        );
      }
      final face = _cardFace(cards[i]);
      if (c.locked) return face;
      return Draggable<int>(
        data: i,
        feedback: Material(
          type: MaterialType.transparency,
          child: _cardFace(cards[i], color: AppColors.blue, lifted: true),
        ),
        childWhenDragging: Opacity(opacity: .3, child: face),
        child: Semantics(
          button: true,
          label: cards[i],
          child: GestureDetector(
            onTap: () {
              Haptics.tap();
              _place(i);
            },
            child: face,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        QuestionHeaderCard(
          kindLabel: chip.label,
          kindColor: chip.fg,
          kindTint: chip.tint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text(q.prompt, style: AppTextStyles.label14),
              Center(
                child: MathText(
                  q.template,
                  style: AppTextStyles.title26.copyWith(
                    fontSize: 34,
                    height: 1.5,
                  ),
                  blankBuilder: (_) => slot,
                ),
              ),
              if (q.visual != null) QuestionVisualView(q.visual!),
            ],
          ),
        ),
        LedgeBox(
          radius: 20,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(ArLearn.dragCards, style: AppTextStyles.caption13),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [for (var i = 0; i < cards.length; i++) tray(i)],
                ),
                Text(ArLearn.dragHint, style: AppTextStyles.caption13),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

const _pairPalette = [
  (AppColors.teal, AppColors.tealTint),
  (AppColors.purple, AppColors.purpleTint),
  (AppColors.blue, AppColors.blueTint),
  (AppColors.coral, AppColors.coralTint),
  (AppColors.amberDark, AppColors.amberTint),
];

class MatchPairsView extends StatefulWidget {
  const MatchPairsView({super.key, required this.context_});

  final QuestionContext context_;

  @override
  State<MatchPairsView> createState() => _MatchPairsViewState();
}

class _MatchPairsViewState extends State<MatchPairsView> {
  int? _pending;

  final Map<int, int> _links = {};

  void _report() {
    final n = (widget.context_.question as MatchPairsQuestion).pairs.length;
    widget.context_.onAnswer(
      _links.length == n ? Map<int, int>.from(_links) : null,
    );
  }

  void _tapLeft(int i) {
    if (_links.containsKey(i)) {
      setState(() => _links.remove(i));
    } else {
      setState(() => _pending = _pending == i ? null : i);
    }
    _report();
  }

  void _tapRight(int original) {
    final owner = _links.entries
        .where((e) => e.value == original)
        .map((e) => e.key)
        .firstOrNull;
    if (owner != null) {
      setState(() => _links.remove(owner));
    } else if (_pending != null) {
      setState(() {
        _links[_pending!] = original;
        _pending = null;
      });
    }
    _report();
  }

  Widget _side(PairSide side, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (side.text != null)
          MathText(
            side.text!,
            color: color,
            style: AppTextStyles.heading22.copyWith(fontSize: 24),
          ),
        if (side.visual != null)
          SizedBox(
            width: 110,
            child: QuestionVisualView(side.visual!, height: 22, color: color),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context_;
    final q = c.question as MatchPairsQuestion;
    final chip = kindChip(q.kind);
    final n = q.pairs.length;
    final shownLinks = c.revealed ? {for (var i = 0; i < n; i++) i: i} : _links;
    final sequence = shownLinks.keys.toList();

    Widget tile({
      required Widget face,
      required int? linkNumber,
      required bool pending,
      required VoidCallback? onTap,
    }) {
      final (fg, tint) = linkNumber == null
          ? (AppColors.ink, AppColors.card)
          : _pairPalette[linkNumber % _pairPalette.length];
      final border = pending
          ? AppColors.amber
          : (linkNumber == null ? AppColors.line : fg);
      return PressCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        minHeight: 72,
        mark: CardMark.idle,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: linkNumber == null && !pending ? 0 : 2,
            ),
            color: pending ? AppColors.amberTint : tint,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Flexible(child: face),
                if (linkNumber != null)
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: fg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${linkNumber + 1}',
                      style: AppTextStyles.percent12.copyWith(
                        color: AppColors.card,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    int? numberOfLeft(int i) {
      final k = sequence.indexOf(i);
      return k < 0 ? null : k;
    }

    int? numberOfRight(int original) {
      for (final (k, left) in sequence.indexed) {
        if (shownLinks[left] == original) return k;
      }
      return null;
    }

    final rightOrder = c.layout.order;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        QuestionHeaderCard(
          kindLabel: chip.label,
          kindColor: chip.fg,
          kindTint: chip.tint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              PromptText(q.prompt, size: 18),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Row(
                      spacing: 4,
                      children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: i < shownLinks.length
                                    ? AppColors.teal
                                    : AppColors.track,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    ArLearn.matchProgress(shownLinks.length, n),
                    style: AppTextStyles.captionBold13.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        for (var row = 0; row < n; row++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Expanded(
                  child: tile(
                    face: _side(q.pairs[row].left, AppColors.ink),
                    linkNumber: numberOfLeft(row),
                    pending: _pending == row,
                    onTap: c.locked ? null : () => _tapLeft(row),
                  ),
                ),
                Expanded(
                  child: tile(
                    face: _side(q.pairs[rightOrder[row]].right, AppColors.ink),
                    linkNumber: numberOfRight(rightOrder[row]),
                    pending: false,
                    onTap: c.locked ? null : () => _tapRight(rightOrder[row]),
                  ),
                ),
              ],
            ),
          ),
        Text(
          ArLearn.matchHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption13,
        ),
      ],
    );
  }
}

class OrderView extends StatefulWidget {
  const OrderView({super.key, required this.context_});

  final QuestionContext context_;

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  late final List<int> _items = [...widget.context_.layout.order];

  void _reorder(int from, int to) {
    setState(() {
      if (to > from) to -= 1;
      final item = _items.removeAt(from);
      _items.insert(to, item);
    });
    Haptics.tap();
    widget.context_.onAnswer(List<int>.from(_items));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context_;
    final q = c.question as OrderQuestion;
    final chip = kindChip(q.kind);
    final shown = c.revealed ? List.generate(q.items.length, (i) => i) : _items;
    final good = c.phase == RoundPhase.correct || c.revealed;

    Widget item(int position) {
      final original = shown[position];
      final it = q.items[original];
      final card = DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: good ? AppColors.teal : AppColors.line,
            width: good ? 2 : 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: good ? AppColors.teal : AppColors.mute,
                ),
                child: Text(
                  '${position + 1}',
                  style: AppTextStyles.body15.copyWith(
                    color: good ? AppColors.card : AppColors.ink,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: MathText(
                      it.label,
                      style: AppTextStyles.heading22.copyWith(fontSize: 24),
                    ),
                  ),
                ),
              ),
              if (it.visual != null)
                SizedBox(
                  width: 96,
                  child: QuestionVisualView(it.visual!, height: 26),
                ),
              if (!c.locked)
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: AppIcon(
                    'grip',
                    size: 22,
                    color: AppColors.placeholder,
                  ),
                ),
            ],
          ),
        ),
      );
      return Padding(
        key: ValueKey('order-$original'),
        padding: const EdgeInsets.only(bottom: 10),
        child: c.locked
            ? card
            : ReorderableDelayedDragStartListener(index: position, child: card),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        QuestionHeaderCard(
          kindLabel: chip.label,
          kindColor: chip.fg,
          kindTint: chip.tint,
          child: PromptText(q.prompt, size: 18),
        ),
        const SizedBox(height: 8),
        if (q.startLabel.isNotEmpty)
          Row(
            spacing: 4,
            children: [
              Text(
                q.startLabel,
                style: AppTextStyles.captionBold13.copyWith(
                  color: AppColors.teal,
                ),
              ),
              const AppIcon('up', size: 14, color: AppColors.teal),
            ],
          ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: c.locked ? (_, _) {} : _reorder,
          proxyDecorator: (child, _, _) => Material(
            type: MaterialType.transparency,
            elevation: 0,
            child: child,
          ),
          children: [for (var i = 0; i < shown.length; i++) item(i)],
        ),
        if (q.endLabel.isNotEmpty)
          Row(
            spacing: 4,
            children: [
              Text(
                q.endLabel,
                style: AppTextStyles.captionBold13.copyWith(
                  color: AppColors.teal,
                ),
              ),
              const AppIcon('down', size: 14, color: AppColors.teal),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            ArLearn.orderHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption13,
          ),
        ),
      ],
    );
  }
}
