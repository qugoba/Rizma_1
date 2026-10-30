import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../downloads/download_providers.dart';
import 'catalog_models.dart';
import 'catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final installed = ref.watch(installedContentProvider);
  return CatalogRepository(installed: () => installed.catalog(5));
});

final catalogProvider = FutureProvider<Catalog>((ref) {
  return ref.watch(catalogRepositoryProvider).load();
});
