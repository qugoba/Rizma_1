import 'dart:convert';

import 'package:flutter/services.dart';

import '../downloads/installed_content.dart';
import 'lesson_content.dart';

class ContentRepository {
  ContentRepository({
    Future<String> Function(String path)? loadString,
    Future<Iterable<String>> Function()? listAssets,
    this.installed,
  }) : _loadString = loadString ?? rootBundle.loadString,
       _listAssets = listAssets ?? _manifestAssets;

  static const folder = 'assets/content/lessons/';

  final Future<String> Function(String path) _loadString;
  final Future<Iterable<String>> Function() _listAssets;

  final InstalledContent? installed;

  final Map<String, LessonContent?> _cache = {};
  final Map<String, int> _sizes = {};
  Set<String>? _bundled;
  Set<String>? _ids;

  static Future<Iterable<String>> _manifestAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets();
  }

  Future<Set<String>> _bundledIds() async {
    final cached = _bundled;
    if (cached != null) return cached;
    final assets = await _listAssets();
    return _bundled = {
      for (final a in assets)
        if (a.startsWith(folder) && a.endsWith('.json'))
          a.substring(folder.length, a.length - '.json'.length),
    };
  }

  Future<Set<String>> availableLessonIds() async {
    final cached = _ids;
    if (cached != null) return cached;
    return _ids = {...await _bundledIds(), ...?await _installedIds()};
  }

  Future<Set<String>?> _installedIds() async {
    try {
      return await installed?.lessonIds();
    } catch (_) {
      return null;
    }
  }

  Future<int> byteSize(String lessonId) async {
    final cached = _sizes[lessonId];
    if (cached != null) return cached;
    final raw = (await _resolve(lessonId))?.$1;
    return _sizes[lessonId] = raw == null ? 0 : utf8.encode(raw).length;
  }

  Future<LessonContent?> load(String lessonId) async {
    if (_cache.containsKey(lessonId)) return _cache[lessonId];
    return _cache[lessonId] = (await _resolve(lessonId))?.$2;
  }

  Future<(String, LessonContent)?> _resolve(String lessonId) async {
    final source = installed;
    if (source != null) {
      String? raw;
      try {
        raw = await source.lessonFile(lessonId, 'lesson.json');
      } catch (_) {
        raw = null;
      }
      if (raw != null) {
        try {
          return (raw, _parse(raw));
        } catch (_) {
          await source.markBroken(lessonId);
        }
      }
    }
    if (!(await _bundledIds()).contains(lessonId)) return null;
    final raw = await _loadString('$folder$lessonId.json');
    return (raw, _parse(raw));
  }

  static LessonContent _parse(String raw) =>
      LessonContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
