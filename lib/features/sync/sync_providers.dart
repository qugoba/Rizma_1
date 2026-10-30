import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database_provider.dart';
import '../content/content_providers.dart';
import '../learning/learning_providers.dart';
import '../profiles/active_profile_provider.dart';
import '../profiles/profile_providers.dart';
import 'sync_api.dart';
import 'sync_service.dart';

final syncServiceProvider = Provider<SyncService?>((ref) {
  final api = ref.watch(syncApiProvider);
  if (api == null) return null;
  final learning = ref.watch(learningRepositoryProvider);
  final content = ref.watch(contentRepositoryProvider);
  final profiles = ref.watch(profileRepositoryProvider);
  return SyncService(
    ref.watch(appDatabaseProvider),
    api,
    recompute: (id) => learning.recomputeProgress(id, contentFor: content.load),
    removeLocal: (id) async {
      await profiles.delete(id);
      await ref.read(activeProfileIdProvider.notifier).reload();
    },
    now: ref.watch(clockProvider),
  );
});

class SyncScheduler extends ConsumerStatefulWidget {
  const SyncScheduler({
    super.key,
    required this.child,
    this.interval = const Duration(minutes: 10),
  });

  final Widget child;
  final Duration interval;

  @override
  ConsumerState<SyncScheduler> createState() => _SyncSchedulerState();
}

class _SyncSchedulerState extends ConsumerState<SyncScheduler>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(syncServiceProvider) == null) return;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(widget.interval, (_) => _sync());
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  Future<void> _sync() async {
    final service = ref.read(syncServiceProvider);
    if (service == null || _running) return;
    _running = true;
    try {
      await service.syncAll();
    } catch (_) {
    } finally {
      _running = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
