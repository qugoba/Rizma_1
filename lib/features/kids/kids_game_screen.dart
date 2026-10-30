import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_kids.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../content/question.dart';
import '../content/speech_service.dart';
import '../learning/learning_providers.dart';
import '../learning/learning_repository.dart';
import '../learning/round_engine.dart';
import '../learning/widgets/question_parts.dart';
import '../learning/widgets/round_panels.dart';
import '../profiles/active_profile_provider.dart';
import 'counting_game.dart';

class KidsGameScreen extends ConsumerStatefulWidget {
  const KidsGameScreen({super.key});

  @override
  ConsumerState<KidsGameScreen> createState() => _KidsGameScreenState();
}

class _KidsGameScreenState extends ConsumerState<KidsGameScreen> {
  late RoundState _state = CountingGame.start(ref.read(roundRandomProvider));
  bool _saving = false;
  RoundRecord? _record;

  Future<void> _speak(String text) async {
    final ok = await ref
        .read(speechServiceProvider)
        .speak(text, language: 'ar');
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(ArKids.gameNoSpeech)));
    }
  }

  void _answer(int index) {
    if (_state.phase != RoundPhase.answering || _state.finished) return;
    Haptics.tap();
    final next = RoundEngine.submit(_state, index);
    setState(() => _state = next);
    if (next.phase != RoundPhase.answering) Haptics.heavy();
  }

  Future<void> _advance() async {
    final next = RoundEngine.advance(_state);
    setState(() => _state = next);
    if (!next.finished || _saving) return;
    _saving = true;
    final profileId = ref.read(activeProfileIdProvider).value;
    if (profileId == null) return;
    final record = await ref
        .read(learningRepositoryProvider)
        .recordGame(
          profileId: profileId,
          activityId: CountingGame.activityId,
          results: next.results,
          starsCap: CountingGame.starsCap,
        );
    if (mounted) setState(() => _record = record);
  }

  void _again() {
    setState(() {
      _state = CountingGame.start(ref.read(roundRandomProvider));
      _record = null;
      _saving = false;
    });
  }

  void _exit() {
    ref.read(speechServiceProvider).stop();
    context.canPop() ? context.pop() : context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final stars = ref.watch(starsTotalProvider);

    return Scaffold(
      body: SafeArea(
        child: _state.finished
            ? _End(
                results: _state.results,
                record: _record,
                onAgain: _again,
                onHome: _exit,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    stars: stars,
                    index: _state.index,
                    total: _state.questions.length,
                    onBack: _exit,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        12,
                        20,
                        20,
                      ),
                      child: _Body(
                        state: _state,
                        onAnswer: _answer,
                        onNext: _advance,
                        onSpeak: _speak,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stars,
    required this.index,
    required this.total,
    required this.onBack,
  });

  final int stars;
  final int index;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 4),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 12,
            children: [
              Semantics(
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
                      onTap: onBack,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: AppIcon('back')),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(ArKids.gameTitle, style: AppTextStyles.heading22),
              ),
              StarsChip(count: stars),
            ],
          ),
          Row(
            children: [
              TagChip(
                label: ArKids.gameChallenge(index + 1, total),
                icon: 'target',
                background: AppColors.sky,
                foreground: AppColors.tealDark,
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              for (var i = 0; i < total; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 8,
                    decoration: BoxDecoration(
                      color: i < index ? AppColors.teal : AppColors.sky2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.onAnswer,
    required this.onNext,
    required this.onSpeak,
  });

  final RoundState state;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;
  final ValueChanged<String> onSpeak;

  static const _tiles = [
    (AppColors.coral, AppColors.coralTint, AppColors.coralDark),
    (AppColors.amberInk, AppColors.amberTint, AppColors.amberDark),
    (AppColors.blue, AppColors.blueTint, AppColors.blueDark),
  ];

  @override
  Widget build(BuildContext context) {
    final q = state.current! as ChoiceQuestion;
    final fruit = CountingGame.fruitOf(q);
    final count = CountingGame.countOf(q);
    final locked = state.phase != RoundPhase.answering;
    final last = state.index == state.questions.length - 1;

    Widget tile(int i) {
      final selected = state.lastAnswer == i;
      final correct = i == q.answerIndex;
      final (fg, tint, edge) = _tiles[i % _tiles.length];
      final mark = switch (state.phase) {
        RoundPhase.correct => selected ? CardMark.correct : CardMark.idle,
        RoundPhase.revealed =>
          correct
              ? CardMark.correct
              : (selected ? CardMark.wrong : CardMark.idle),
        RoundPhase.answering => selected ? CardMark.wrong : CardMark.idle,
      };
      final filled = mark == CardMark.correct;
      final wrong = mark == CardMark.wrong;
      final word = ArKids.numberWord(int.tryParse(q.choices[i]) ?? -1);
      return Semantics(
        button: true,
        label: q.choices[i],
        enabled: !locked,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: locked ? null : () => onAnswer(i),
          child: LedgeBox(
            radius: 20,
            color: filled ? AppColors.teal : tint,
            edge: filled
                ? AppColors.tealDark
                : (wrong ? AppColors.coralDark : edge),
            border: Border.all(
              color: filled
                  ? AppColors.tealDark
                  : (wrong ? AppColors.coral : Colors.transparent),
              width: 2.5,
            ),
            child: SizedBox(
              height: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    q.choices[i],
                    style: AppTextStyles.title26.copyWith(
                      fontSize: 38,
                      height: 1.1,
                      color: filled ? AppColors.card : fg,
                    ),
                  ),
                  if (word != null)
                    Text(
                      word,
                      style: AppTextStyles.caption12.copyWith(
                        color: filled ? AppColors.card : fg,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        LedgeBox(
          radius: 24,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  q.prompt,
                  style: AppTextStyles.title26.copyWith(fontSize: 28),
                ),
                Semantics(
                  button: true,
                  label: ArKids.listenQuestion,
                  excludeSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onSpeak(q.prompt),
                    child: Row(
                      spacing: 10,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.amber,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.amberDark,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const AppIcon(
                            'volume',
                            size: 24,
                            color: AppColors.amberInk,
                          ),
                        ),
                        Text(
                          ArKids.listenQuestion,
                          style: AppTextStyles.body15.copyWith(
                            color: AppColors.amberInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _CountArea(
                  key: ValueKey(state.index),
                  fruit: fruit.key,
                  count: count,
                ),
              ],
            ),
          ),
        ),
        Text(ArKids.pickNumber, style: AppTextStyles.body16Strong),
        Row(
          spacing: 10,
          children: [
            for (var i = 0; i < q.choices.length; i++) Expanded(child: tile(i)),
          ],
        ),
        if (state.phase == RoundPhase.correct)
          CorrectPanel(
            stars: state.wrongs == 0 ? 3 : 2,
            question: q,
            nextLabel: last ? ArLearn.finishRound : ArLearn.nextQuestion,
            onNext: onNext,
          )
        else if (state.phase == RoundPhase.revealed)
          RevealedPanel(
            question: q,
            nextLabel: last ? ArLearn.finishRound : ArLearn.nextQuestion,
            onNext: onNext,
          )
        else if (state.hintsShown > 0)
          HintPanel(
            stage: state.hintsShown,
            stages: q.hints.length,
            hint: q.hints[state.hintsShown - 1],
          )
        else
          const _TipCard(),
      ],
    );
  }
}

class _CountArea extends StatefulWidget {
  const _CountArea({super.key, required this.fruit, required this.count});

  final String fruit;
  final int count;

  @override
  State<_CountArea> createState() => _CountAreaState();
}

class _CountAreaState extends State<_CountArea> {
  final _order = <int>[];

  void _toggle(int i) {
    setState(() => _order.contains(i) ? _order.remove(i) : _order.add(i));
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    ArKids.tapToCount,
                    style: AppTextStyles.caption13.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
                TagChip(
                  label: ArKids.countSoFar(_order.length),
                  background: AppColors.teal,
                  foreground: AppColors.card,
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < widget.count; i++)
                  _FruitTile(
                    fruit: widget.fruit,
                    number: _order.contains(i) ? _order.indexOf(i) + 1 : null,
                    onTap: () => _toggle(i),
                  ),
              ],
            ),
            if (_order.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(_order.clear),
                  icon: const AppIcon('retry', size: 16, color: AppColors.teal),
                  label: Text(
                    ArKids.recount,
                    style: AppTextStyles.caption13.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FruitTile extends StatelessWidget {
  const _FruitTile({
    required this.fruit,
    required this.number,
    required this.onTap,
  });

  final String fruit;
  final int? number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final counted = number != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: counted ? AppColors.teal : AppColors.line,
            width: counted ? 2.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(child: Illustration(fruit, size: 44)),
            if (counted)
              PositionedDirectional(
                top: 3,
                start: 3,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: AppTextStyles.caption12.copyWith(
                      color: AppColors.card,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 12,
          children: [
            const Mascot(size: 52, mood: MascotMood.thinking),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ArKids.tipTitle,
                    style: AppTextStyles.body15.copyWith(color: AppColors.teal),
                  ),
                  Text(ArKids.tipBody, style: AppTextStyles.caption13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _End extends StatelessWidget {
  const _End({
    required this.results,
    required this.record,
    required this.onAgain,
    required this.onHome,
  });

  final List<QuestionResult> results;
  final RoundRecord? record;
  final VoidCallback onAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final correct = results.where((r) => r.correct).length;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                const Mascot(size: 140),
                Text(ArKids.gameEndTitle, style: AppTextStyles.title26),
                Text(
                  ArKids.gameEndBody(correct, results.length),
                  style: AppTextStyles.label14,
                ),
                if (record != null)
                  Text(
                    ArKids.gameEndStars(record!.earned),
                    style: AppTextStyles.heading22.copyWith(
                      color: AppColors.amberDark,
                    ),
                  ),
              ],
            ),
          ),
          RizmaButton(
            label: ArKids.gameAgain,
            icon: 'shuffle',
            onPressed: onAgain,
          ),
          const SizedBox(height: 10),
          RizmaButton(
            label: ArKids.gameBackHome,
            kind: ButtonKind.outlined,
            onPressed: onHome,
          ),
        ],
      ),
    );
  }
}
