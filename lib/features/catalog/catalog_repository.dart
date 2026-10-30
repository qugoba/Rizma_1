import 'dart:convert';

import 'package:flutter/services.dart';

import 'catalog_models.dart';

class CatalogRepository {
  CatalogRepository({
    Future<String> Function(String path)? loadString,
    this.assetPath = 'assets/content/catalog_grade5.json',
    this.installed,
  }) : _loadString = loadString ?? rootBundle.loadString;

  final String assetPath;
  final Future<String> Function(String path) _loadString;

  final Future<String?> Function()? installed;

  Catalog? _cached;

  Future<Catalog> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    return _cached = await _installed() ?? _parse(await _loadString(assetPath));
  }

  Future<Catalog?> _installed() async {
    try {
      final raw = await installed?.call();
      return raw == null ? null : _parse(raw);
    } catch (_) {
      return null;
    }
  }

  static Catalog _parse(String raw) =>
      Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
