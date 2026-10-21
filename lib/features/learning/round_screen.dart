import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/tag_chip.dart';
import '../../app/routes.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/db/enums.dart';
import '../content/content_providers.dart';
import '../content/lesson_content.dart';
import '../content/question.dart';
import '../content/speech_service.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_providers.dart';
import 'lesson_view.dart';
import 'round_engine.dart';
import 'widgets/part_frame.dart';
import 'widgets/question_context.dart';
import 'widgets/question_view.dart';
import 'widgets/round_panels.dart';

class RoundScreen extends ConsumerStatefulWidget {
  const RoundScreen({
    super.key,
    required this.lessonId,
    required this.mode,
    this.concept,
  });

  final String lessonId;
  final RoundMode mode;

  final String? concept;

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> {
  RoundState? _state;

  Object? _pending;
  bool _hintOpen = true;
  bool _finishing = false;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get _practice => widget.mode == RoundMode.practice;

  bool _immediate(Question q) =>
      _practice && (q is ChoiceQuestion || q is TrueFalseQuestion);

  RoundState _build(LessonContent content) {
    final random = ref.read(roundRandomProvider);
    final pool = _practice ? content.practice : content.quiz;
    final grade = ref.read(activeProfileProvider).value?.grade;
    final questions = RoundEngine.pick(
      pool,
      widget.mode,
      random: random,
      concept: widget.concept,
      kids: grade != null && grade <= RoundEngine.lastKidsGrade,
    );
    return RoundEngine.start(
      mode: widget.mode,
      questions: questions,
      random: random,
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _submit(Object? answer) {
    final s = _state;
    if (s == null || answer == null) return;
    final next = RoundEngine.submit(s, answer);
    setState(() {
      _state = next;
      _pending = null;
      _hintOpen = true;
    });
    if (next.phase != RoundPhase.answering) Haptics.heavy();
    if (next.finished) {
      _finish(next);
    } else if (next.phase != RoundPhase.answering ||
        next.hintsShown > s.hintsShown) {
      _scrollDown();
    }
  }

  void _advance() {
    final s = _state;
    if (s == null) return;
    final next = RoundEngine.advance(s);
    setState(() {
      _state = next;
      _pending = null;
    });
    if (next.finished) {
      _finish(next);
    } else if (_scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  Future<void> _finish(RoundState s) async {
    if (_finishing) return;
    _finishing = true;
    final profileId = ref.read(activeProfileIdProvider).value;
    final content = await ref.read(
      lessonContentProvider(widget.lessonId).future,
    );
    if (!mounted) return;
    if (profileId == null) {
      context.pop();
      return;
    }
    final record = await ref
        .read(learningRepositoryProvider)
        .recordRound(
          profileId: profileId,
          lessonId: widget.lessonId,
          mode: widget.mode,
          results: s.results,
          content: content,
        );
    if (!mounted) return;
    context.pushReplacement(
      _practice
          ? AppRoutes.roundEnd(record.attemptId)
          : AppRoutes.result(record.attemptId),
    );
  }

  Future<void> _confirmQuit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ArLearn.quitTitle),
        content: const Text(ArLearn.quitBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(ArLearn.quitStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(ArLearn.quitLeave),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      ref.read(speechServiceProvider).stop();
      context.canPop()
          ? context.pop()
          : context.go(AppRoutes.lesson(widget.lessonId));
    }
  }

  int? _readIndex;

  void _autoRead(int index, Question q) {
    if (_readIndex == index || q is ListenChooseQuestion) return;
    final grade = ref.read(activeProfileProvider).value?.grade;
    if (grade == null || grade > RoundEngine.lastKidsGrade) return;
    _readIndex = index;
    final text = q.prompt.replaceAll(RegExp(r'[{}]'), '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(speechServiceProvider).speak(text, language: 'ar');
    });
  }

  Future<void> _speak(String text, {bool slow = false}) async {
    final ok = await ref
        .read(speechServiceProvider)
        .speak(text, language: 'en-US', slow: slow);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(ArLearn.speechUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(lessonViewProvider(widget.lessonId)).value;
    final content = view?.content;

    if (view == null ||
        content == null ||
        !content.has(_practice ? LessonPart.practice : LessonPart.quiz)) {
      return PartFrame(
        title: _practice ? ArLearn.partPractice : ArLearn.partQuiz,
        subtitle: view?.lesson.title ?? '',
        lessonId: widget.lessonId,
        child: const PartUnavailable(message: ArLearn.roundNoQuestions),
      );
    }

    final s = _state ??= _build(content);
    if (s.finished) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final q = s.current!;
    _autoRead(s.index, q);
    final stars = ref.watch(starsTotalProvider);
    final ctx = QuestionContext(
      question: q,
      layout: s.layout!,
      mode: s.mode,
      phase: s.phase,
      lastAnswer: s.lastAnswer,
      number: s.index + 1,
      total: s.questions.length,
      onAnswer: (a) {
        if (_immediate(q) && a != null) {
          _submit(a);
        } else {
          setState(() => _pending = a);
        }
      },
      onSpeak: _speak,
    );

    final isLast = s.index == s.questions.length - 1;
    final needsConfirm = s.phase == RoundPhase.answering && !_immediate(q);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmQuit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RoundHeader(
                practice: _practice,
                title: ArLearn.quizHeader(ArLearn.unitOrdinal(view.unit.order)),
                subtitle: ArLearn.quizSubtitle(view.lesson.title),
                stars: stars,
                index: s.index,
                total: s.questions.length,
                onClose: _confirmQuit,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 14,
                    children: [
                      QuestionView(
                        key: ValueKey('${s.index}-${s.wrongs}'),
                        data: ctx,
                      ),
                      ..._feedback(s, q, isLast),
                    ],
                  ),
                ),
              ),
              if (needsConfirm)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      RizmaButton(
                        label: _confirmLabel(q, s),
                        kind: ButtonKind.filled,
                        icon: s.wrongs > 0 ? 'retry' : 'check',
                        onPressed: _pending == null
                            ? null
                            : () => _submit(_pending),
                      ),
                      if (_pending == null && q is DragDropQuestion)
                        Text(
                          ArLearn.confirmDisabledNote,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption13,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _confirmLabel(Question q, RoundState s) {
    if (s.wrongs > 0) return ArLearn.tryAgain;
    if (q is OrderQuestion) return ArLearn.checkOrder;
    return ArLearn.confirmAnswer;
  }

  List<Widget> _feedback(RoundState s, Question q, bool isLast) {
    if (!_practice) return const [_QuizNote()];
    final next = isLast ? ArLearn.finishRound : ArLearn.nextQuestion;
    switch (s.phase) {
      case RoundPhase.correct:
        return [
          CorrectPanel(
            stars: QuestionResult.starsFor(s.wrongs),
            question: q,
            nextLabel: next,
            onNext: _advance,
          ),
        ];
      case RoundPhase.revealed:
        return [RevealedPanel(question: q, nextLabel: next, onNext: _advance)];
      case RoundPhase.answering:
        final shown = s.hintsShown;
        if (shown == 0) return const [];
        final stages = q.hints.length + (q.solution.isNotEmpty ? 1 : 0);
        if (!_hintOpen) {
          return [
            RizmaButton(
              label: ArLearn.hintStage(shown, stages),
              kind: ButtonKind.amber,
              icon: 'bulb',
              onPressed: () => setState(() => _hintOpen = true),
            ),
          ];
        }
        return [
          HintPanel(
            stage: shown,
            stages: stages,
            hint: q.hints[shown - 1],
            onTryAgain: _immediate(q)
                ? () => setState(() => _hintOpen = false)
                : null,
            onLastHint: s.canRevealSolution
                ? () => setState(() => _state = RoundEngine.revealSolution(s))
                : null,
          ),
        ];
    }
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.practice,
    required this.title,
    required this.subtitle,
    required this.stars,
    required this.index,
    required this.total,
    required this.onClose,
  });

  final bool practice;
  final String title;
  final String subtitle;
  final int stars;
  final int index;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final close = Semantics(
      button: true,
      label: ArLearn.roundClose,
      excludeSemantics: true,
      child: LedgeBox(
        radius: 14,
        depth: 3,
        clip: true,
        child: Material(
          color: AppColors.card,
          child: InkWell(
            onTap: onClose,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(child: AppIcon('x', color: AppColors.ink)),
            ),
          ),
        ),
      ),
    );

    final counter = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          ArLearn.roundQuestionOf(index + 1, total),
          style: AppTextStyles.chip13.copyWith(color: AppColors.tealDark),
        ),
      ),
    );

    final bar = TweenAnimationBuilder<double>(
      tween: Tween(end: total == 0 ? 0 : index / total),
      duration: const Duration(milliseconds: 260),
      builder: (context, value, _) => ProgressBar(
        value: value.clamp(0.0, 1.0),
        trackColor: AppColors.sky2,
        fillColor: practice ? AppColors.teal : AppColors.purple,
        height: 10,
      ),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 4),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 12,
            children: [
              close,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice ? ArLearn.roundPracticeTitle : title,
                      style: AppTextStyles.heading22,
                    ),
                    if (!practice)
                      Text(subtitle, style: AppTextStyles.caption13),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            children: [
              counter,
              if (practice)
                StarsChip(count: stars)
              else
                const Flexible(
                  child: TagChip(
                    label: ArLearn.quizRulesChip,
                    icon: 'list',
                    background: AppColors.purpleTint,
                    foreground: AppColors.purple,
                  ),
                ),
            ],
          ),
          bar,
        ],
      ),
    );
  }
}

class _QuizNote extends StatelessWidget {
  const _QuizNote();

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const IconTile(
            iconName: 'bulb',
            iconColor: AppColors.purple,
            color: AppColors.purpleTint,
            size: 40,
            iconSize: 20,
            radius: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ArLearn.quizNoHintsTitle, style: AppTextStyles.body15),
                Text(ArLearn.quizNoHintsBody, style: AppTextStyles.caption13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
