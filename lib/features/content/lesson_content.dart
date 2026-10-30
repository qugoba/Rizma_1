import '../../core/db/enums.dart';
import 'question.dart';

class PackBlock {
  const PackBlock({required this.type, required this.value});

  factory PackBlock.fromJson(Map<String, dynamic> json) => PackBlock(
    type: json['type'] as String,
    value: (json['value'] ?? json['caption'] ?? '') as String,
  );

  final String type;
  final String value;
}

class PackPage {
  const PackPage({
    required this.header,
    required this.title,
    required this.blocks,
  });

  factory PackPage.fromJson(Map<String, dynamic> json) => PackPage(
    header: (json['header'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
    blocks: [
      for (final b in json['blocks'] as List<dynamic>)
        PackBlock.fromJson(b as Map<String, dynamic>),
    ],
  );

  final String header;
  final String title;
  final List<PackBlock> blocks;
}

class BarRow {
  const BarRow({
    required this.label,
    required this.parts,
    required this.filled,
  });

  factory BarRow.fromJson(Map<String, dynamic> json) => BarRow(
    label: json['label'] as String,
    parts: json['parts'] as int,
    filled: json['filled'] as int,
  );

  final String label;
  final int parts;
  final int filled;
}

class ExplainStep {
  const ExplainStep({
    required this.title,
    required this.body,
    this.rows = const [],
    this.tip,
  });

  factory ExplainStep.fromJson(Map<String, dynamic> json) => ExplainStep(
    title: json['title'] as String,
    body: (json['body'] as String?) ?? '',
    rows: [
      for (final r in (json['rows'] as List<dynamic>? ?? []))
        BarRow.fromJson(r as Map<String, dynamic>),
    ],
    tip: json['tip'] as String?,
  );

  final String title;
  final String body;
  final List<BarRow> rows;
  final String? tip;
}

class SummaryPoint {
  const SummaryPoint({required this.text, this.math, this.mathNote});

  factory SummaryPoint.fromJson(Map<String, dynamic> json) => SummaryPoint(
    text: json['text'] as String,
    math: json['math'] as String?,
    mathNote: json['mathNote'] as String?,
  );

  final String text;
  final String? math;
  final String? mathNote;
}

class VideoPart {
  const VideoPart({required this.title, required this.at});

  factory VideoPart.fromJson(Map<String, dynamic> json) =>
      VideoPart(title: json['title'] as String, at: json['at'] as String);

  final String title;

  final String at;
}

class VideoContent {
  const VideoContent({
    required this.title,
    required this.minutes,
    required this.sizeMb,
    required this.parts,
    this.file,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) => VideoContent(
    title: json['title'] as String,
    minutes: json['minutes'] as int,
    sizeMb: (json['sizeMb'] as num).toDouble(),
    parts: [
      for (final p in json['parts'] as List<dynamic>)
        VideoPart.fromJson(p as Map<String, dynamic>),
    ],
    file: json['file'] as String?,
  );

  final String title;
  final int minutes;
  final double sizeMb;
  final List<VideoPart> parts;
  final String? file;
}

class LessonAttachment {
  const LessonAttachment({
    required this.title,
    required this.file,
    required this.sizeKb,
    this.type = 'pdf',
  });

  factory LessonAttachment.fromJson(Map<String, dynamic> json) =>
      LessonAttachment(
        title: json['title'] as String,
        file: json['file'] as String,
        sizeKb: json['sizeKb'] as int,
        type: (json['type'] as String?) ?? 'pdf',
      );

  final String title;
  final String file;
  final int sizeKb;

  final String type;
}

class WordItem {
  const WordItem({
    required this.en,
    required this.ar,
    required this.ipa,
    required this.illustration,
    required this.sentenceEn,
    required this.sentenceAr,
  });

  factory WordItem.fromJson(Map<String, dynamic> json) => WordItem(
    en: json['en'] as String,
    ar: json['ar'] as String,
    ipa: (json['ipa'] as String?) ?? '',
    illustration: json['illustration'] as String,
    sentenceEn: (json['sentenceEn'] as String?) ?? '',
    sentenceAr: (json['sentenceAr'] as String?) ?? '',
  );

  final String en;
  final String ar;
  final String ipa;
  final String illustration;
  final String sentenceEn;
  final String sentenceAr;
}

class LessonContent {
  const LessonContent({
    required this.lessonId,
    this.pages = const [],
    this.steps = const [],
    this.summary = const [],
    this.video,
    this.words = const [],
    this.practice = const [],
    this.quiz = const [],
    this.attachments = const [],
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) => [
      for (final e in (json[key] as List<dynamic>? ?? []))
        f(e as Map<String, dynamic>),
    ];
    return LessonContent(
      lessonId: json['lessonId'] as String,
      pages: list('pack', PackPage.fromJson),
      steps: list('explanation', ExplainStep.fromJson),
      summary: list('summary', SummaryPoint.fromJson),
      video: json['video'] == null
          ? null
          : VideoContent.fromJson(json['video'] as Map<String, dynamic>),
      words: list('words', WordItem.fromJson),
      practice: list('practice', Question.fromJson),
      quiz: list('quiz', Question.fromJson),
      attachments: list('attachments', LessonAttachment.fromJson),
    );
  }

  final String lessonId;
  final List<PackPage> pages;
  final List<ExplainStep> steps;
  final List<SummaryPoint> summary;
  final VideoContent? video;
  final List<WordItem> words;
  final List<Question> practice;
  final List<Question> quiz;

  final List<LessonAttachment> attachments;

  bool has(LessonPart part) => switch (part) {
    LessonPart.pack => pages.isNotEmpty,
    LessonPart.explanation => steps.isNotEmpty,
    LessonPart.summary => summary.isNotEmpty,
    LessonPart.video => video != null,
    LessonPart.words => words.isNotEmpty,
    LessonPart.practice => practice.isNotEmpty,
    LessonPart.quiz => quiz.isNotEmpty,
  };

  List<LessonPart> get parts => [
    for (final p in LessonPart.values)
      if (has(p)) p,
  ];
}
