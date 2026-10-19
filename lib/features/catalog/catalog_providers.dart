import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_models.dart';
import 'catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final catalogProvider = FutureProvider<Catalog>((ref) {
  return ref.watch(catalogRepositoryProvider).load();
});
