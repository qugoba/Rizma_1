import 'dart:convert';

import 'package:flutter/services.dart';

import 'catalog_models.dart';

class CatalogRepository {
  CatalogRepository({
    Future<String> Function(String path)? loadString,
    this.assetPath = 'assets/content/catalog_grade5.json',
  }) : _loadString = loadString ?? rootBundle.loadString;

  final String assetPath;
  final Future<String> Function(String path) _loadString;
  Catalog? _cached;

  Future<Catalog> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    final raw = await _loadString(assetPath);
    final catalog = Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _cached = catalog;
  }
}
