import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/db/database_provider.dart';
import 'package:rizma/features/catalog/catalog_providers.dart';
import 'package:rizma/features/catalog/catalog_repository.dart';
import 'package:rizma/features/content/content_providers.dart';
import 'package:rizma/features/content/content_repository.dart';
import 'package:rizma/features/content/speech_service.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

final String _catalogJson = File(
  'assets/content/catalog_grade5.json',
).readAsStringSync();

final Map<String, String> _lessonFiles = {
  for (final f in Directory(
    'assets/content/lessons',
  ).listSync().whereType<File>().where((f) => f.path.endsWith('.json')))
    'assets/content/lessons/${f.uri.pathSegments.last}': f.readAsStringSync(),
};

class FakeSpeech implements SpeechService {
  FakeSpeech({this.available = true});

  final bool available;
  final spoken = <String>[];
  final languages = <String>[];
  final slowFlags = <bool>[];

  @override
  Future<bool> speak(
    String text, {
    required String language,
    bool slow = false,
  }) async {
    spoken.add(text);
    languages.add(language);
    slowFlags.add(slow);
    return available;
  }

  @override
  Future<void> stop() async {}
}

Future<void> scenario(
  WidgetTester tester,
  Future<void> Function(AppDatabase db) body, {
  Future<void> Function(ProfileRepository repo)? seed,
  List<Override> overrides = const [],
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  if (seed != null) {
    await tester.runAsync(() => seed(ProfileRepository(db)));
  }
  await tester.binding.setSurfaceSize(const Size(390, 1200));
  tester.platformDispatcher.defaultRouteNameTestValue = '/';
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details, forceReport: true);
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(loadString: (_) async => _catalogJson),
        ),
        contentRepositoryProvider.overrideWithValue(
          ContentRepository(
            loadString: (path) async => _lessonFiles[path]!,
            listAssets: () async => _lessonFiles.keys,
          ),
        ),
        speechServiceProvider.overrideWithValue(FakeSpeech()),
        ...overrides,
      ],
      child: const RizmaApp(),
    ),
  );
  await tester.pumpAndSettle();
  try {
    await body(db);
  } finally {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
    await tester.binding.setSurfaceSize(null);
    tester.platformDispatcher.clearDefaultRouteNameTestValue();
  }
}

Future<T> onDb<T>(WidgetTester tester, Future<T> Function() action) async {
  final result = (await tester.runAsync(action)) as T;
  await tester.pumpAndSettle();
  return result;
}

Future<void> enterPin(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}
