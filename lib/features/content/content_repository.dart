import 'dart:convert';

import 'package:flutter/services.dart';

import 'lesson_content.dart';

class ContentRepository {
  ContentRepository({
    Future<String> Function(String path)? loadString,
    Future<Iterable<String>> Function()? listAssets,
  }) : _loadString = loadString ?? rootBundle.loadString,
       _listAssets = listAssets ?? _manifestAssets;

  static const folder = 'assets/content/lessons/';

  final Future<String> Function(String path) _loadString;
  final Future<Iterable<String>> Function() _listAssets;
  final Map<String, LessonContent?> _cache = {};
  final Map<String, int> _sizes = {};
  Set<String>? _ids;

  static Future<Iterable<String>> _manifestAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets();
  }

  Future<Set<String>> availableLessonIds() async {
    final cached = _ids;
    if (cached != null) return cached;
    final assets = await _listAssets();
    return _ids = {
      for (final a in assets)
        if (a.startsWith(folder) && a.endsWith('.json'))
          a.substring(folder.length, a.length - '.json'.length),
    };
  }

  Future<int> byteSize(String lessonId) async {
    final cached = _sizes[lessonId];
    if (cached != null) return cached;
    if (!(await availableLessonIds()).contains(lessonId)) return 0;
    final raw = await _loadString('$folder$lessonId.json');
    return _sizes[lessonId] = utf8.encode(raw).length;
  }

  Future<LessonContent?> load(String lessonId) async {
    if (_cache.containsKey(lessonId)) return _cache[lessonId];
    if (!(await availableLessonIds()).contains(lessonId)) {
      return _cache[lessonId] = null;
    }
    final raw = await _loadString('$folder$lessonId.json');
    return _cache[lessonId] = LessonContent.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}
