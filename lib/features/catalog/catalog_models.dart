import '../../core/theme/subject_tone.dart';

class CatalogConcept {
  const CatalogConcept({required this.id, required this.title});

  factory CatalogConcept.fromJson(Map<String, dynamic> json) {
    return CatalogConcept(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  final String id;
  final String title;
}

class CatalogLesson {
  const CatalogLesson({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
    required this.order,
    required this.concepts,
    required this.subjectId,
    required this.unitId,
  });

  factory CatalogLesson.fromJson(
    Map<String, dynamic> json, {
    required String subjectId,
    required String unitId,
  }) {
    return CatalogLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      order: json['order'] as int,
      concepts: [
        for (final c in json['concepts'] as List<dynamic>)
          CatalogConcept.fromJson(c as Map<String, dynamic>),
      ],
      subjectId: subjectId,
      unitId: unitId,
    );
  }

  final String id;
  final String title;
  final int estimatedMinutes;
  final int order;
  final List<CatalogConcept> concepts;
  final String subjectId;
  final String unitId;
}

class CatalogUnit {
  const CatalogUnit({
    required this.id,
    required this.title,
    required this.order,
    required this.lessons,
  });

  factory CatalogUnit.fromJson(
    Map<String, dynamic> json, {
    required String subjectId,
  }) {
    final id = json['id'] as String;
    final lessons = [
      for (final l in json['lessons'] as List<dynamic>)
        CatalogLesson.fromJson(
          l as Map<String, dynamic>,
          subjectId: subjectId,
          unitId: id,
        ),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return CatalogUnit(
      id: id,
      title: json['title'] as String,
      order: json['order'] as int,
      lessons: lessons,
    );
  }

  final String id;
  final String title;
  final int order;
  final List<CatalogLesson> lessons;
}

class CatalogSubject {
  const CatalogSubject({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.order,
    required this.units,
  });

  factory CatalogSubject.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final units = [
      for (final u in json['units'] as List<dynamic>)
        CatalogUnit.fromJson(u as Map<String, dynamic>, subjectId: id),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return CatalogSubject(
      id: id,
      title: json['title'] as String,
      icon: json['icon'] as String,
      color: SubjectTone.values.byName(json['color'] as String),
      order: json['order'] as int,
      units: units,
    );
  }

  final String id;
  final String title;

  final String icon;
  final SubjectTone color;
  final int order;
  final List<CatalogUnit> units;

  List<CatalogLesson> get lessons => [for (final u in units) ...u.lessons];
}

class Catalog {
  Catalog({required this.grade, required List<CatalogSubject> subjects})
    : subjects = List.unmodifiable(subjects),
      _lessonsById = {
        for (final s in subjects)
          for (final l in s.lessons) l.id: l,
      },
      _subjectsById = {for (final s in subjects) s.id: s};

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final subjects = [
      for (final s in json['subjects'] as List<dynamic>)
        CatalogSubject.fromJson(s as Map<String, dynamic>),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return Catalog(grade: json['grade'] as int, subjects: subjects);
  }

  final int grade;
  final List<CatalogSubject> subjects;
  final Map<String, CatalogLesson> _lessonsById;
  final Map<String, CatalogSubject> _subjectsById;

  List<CatalogLesson> get allLessons => [
    for (final s in subjects) ...s.lessons,
  ];

  CatalogLesson? get firstLesson {
    final lessons = allLessons;
    return lessons.isEmpty ? null : lessons.first;
  }

  CatalogLesson? lessonById(String id) => _lessonsById[id];

  CatalogSubject? subjectById(String id) => _subjectsById[id];

  CatalogUnit? unitOfLesson(CatalogLesson lesson) {
    final subject = _subjectsById[lesson.subjectId];
    if (subject == null) return null;
    for (final u in subject.units) {
      if (u.id == lesson.unitId) return u;
    }
    return null;
  }

  CatalogLesson? nextLessonInSubject(CatalogLesson lesson) {
    final lessons = _subjectsById[lesson.subjectId]?.lessons ?? const [];
    final i = lessons.indexWhere((l) => l.id == lesson.id);
    if (i < 0 || i + 1 >= lessons.length) return null;
    return lessons[i + 1];
  }

  ({CatalogConcept concept, CatalogLesson lesson})? conceptById(String id) {
    for (final lesson in _lessonsById.values) {
      for (final c in lesson.concepts) {
        if (c.id == id) return (concept: c, lesson: lesson);
      }
    }
    return null;
  }
}
