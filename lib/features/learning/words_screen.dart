import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../content/lesson_content.dart';
import '../content/speech_service.dart';
import 'lesson_view.dart';
import 'widgets/part_frame.dart';

class WordsScreen extends ConsumerStatefulWidget {
  const WordsScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends ConsumerState<WordsScreen> {
  int _index = 0;
  final _seen = <int>{0};
  bool _completed = false;

  void _select(int i, int total) {
    setState(() {
      _index = i;
      _seen.add(i);
    });
    _checkDone(total);
  }

  void _checkDone(int total) {
    if (_seen.length == total && !_completed) {
      _completed = true;
      completeLessonPart(
        ref,
        lessonId: widget.lessonId,
        part: LessonPart.words,
      );
    }
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
    final words = view?.content?.words ?? const <WordItem>[];

    if (view == null || words.isEmpty) {
      return PartFrame(
        title: ArLearn.partWords,
        subtitle: view?.lesson.title ?? '',
        lessonId: widget.lessonId,
        child: const PartUnavailable(),
      );
    }

    if (words.length == 1 && !_completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkDone(1);
      });
    }
    final i = _index.clamp(0, words.length - 1);
    final word = words[i];
    return PartFrame(
      title: ArLearn.partWords,
      subtitle: ArLearn.wordsKicker(
        view.subject.title,
        view.unit.order,
        i + 1,
        words.length,
      ),
      lessonId: widget.lessonId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  ArLearn.wordsCardOf(i + 1, words.length),
                  style: AppTextStyles.body15,
                ),
              ),
              const TagChip(label: ArLearn.wordsAudioReady, icon: 'cloudoff'),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              for (var n = 0; n < words.length; n++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 8,
                    decoration: BoxDecoration(
                      color: n <= i ? AppColors.purple : AppColors.sky2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          _WordCard(
            word: word,
            onListen: () => _speak(word.en),
            onSlow: () => _speak(word.en, slow: true),
          ),
          if (word.sentenceEn.isNotEmpty)
            _SentenceCard(word: word, onListen: () => _speak(word.sentenceEn)),
          if (words.length > 1)
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: RizmaButton(
                    label: ArLearn.previous,
                    kind: ButtonKind.outlined,
                    icon: 'back',
                    height: 48,
                    onPressed: i > 0
                        ? () => _select(i - 1, words.length)
                        : null,
                  ),
                ),
                Expanded(
                  child: RizmaButton(
                    label: ArLearn.next,
                    icon: 'fwd',
                    height: 48,
                    onPressed: i < words.length - 1
                        ? () => _select(i + 1, words.length)
                        : null,
                  ),
                ),
              ],
            ),
          Text(ArLearn.wordsLesson, style: AppTextStyles.section18),
          _WordList(
            words: words,
            current: i,
            onTap: (n) => _select(n, words.length),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.onListen,
    required this.onSlow,
  });

  final WordItem word;
  final VoidCallback onListen;
  final VoidCallback onSlow;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 24,
      edge: AppColors.purpleDark,
      border: Border.all(color: AppColors.purple, width: 2),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          spacing: 6,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.amberTint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _WordPicture(word, size: 76),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                word.en,
                style: AppTextStyles.title26.copyWith(
                  fontSize: 40,
                  height: 1.2,
                ),
              ),
            ),
            if (word.ipa.isNotEmpty)
              Directionality(
                textDirection: TextDirection.ltr,
                child: TagChip(
                  label: word.ipa,
                  background: AppColors.purpleTint,
                  foreground: AppColors.purple,
                ),
              ),
            Text(
              word.ar,
              style: AppTextStyles.title26.copyWith(color: AppColors.teal),
            ),
            const SizedBox(height: 6),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: RizmaButton(
                    label: ArLearn.wordListen,
                    icon: 'volume',
                    onPressed: onListen,
                  ),
                ),
                Expanded(
                  child: RizmaButton(
                    label: ArLearn.wordSlow,
                    kind: ButtonKind.soft,
                    icon: 'clock',
                    onPressed: onSlow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({required this.word, required this.onListen});

  final WordItem word;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          spacing: 12,
          children: [
            Semantics(
              button: true,
              label: ArLearn.wordListen,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: onListen,
                child: const IconTile(
                  iconName: 'volume',
                  iconColor: AppColors.purple,
                  color: AppColors.card,
                  radius: 12,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      word.sentenceEn,
                      style: AppTextStyles.body16Strong,
                    ),
                  ),
                  Text(word.sentenceAr, style: AppTextStyles.label14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({
    required this.words,
    required this.current,
    required this.onTap,
  });

  final List<WordItem> words;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 16,
      child: Column(
        children: [
          for (final (n, w) in words.indexed)
            Semantics(
              button: true,
              selected: n == current,
              label: '${w.en}، ${w.ar}',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onTap(n),
                child: Container(
                  color: n == current ? AppColors.purpleTint : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      _WordPicture(w, size: 32),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(w.en, style: AppTextStyles.body16Strong),
                        ),
                      ),
                      Text(w.ar, style: AppTextStyles.label14),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WordPicture extends StatelessWidget {
  const _WordPicture(this.word, {required this.size});

  final WordItem word;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (Illustration.kindOf(word.illustration) != null) {
      return Illustration(word.illustration, size: size);
    }
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          word.en.isEmpty ? '' : word.en.substring(0, 1).toUpperCase(),
          textDirection: TextDirection.ltr,
          style: AppTextStyles.title26.copyWith(
            fontSize: size * 0.7,
            height: 1,
            color: AppColors.purple,
          ),
        ),
      ),
    );
  }
}
