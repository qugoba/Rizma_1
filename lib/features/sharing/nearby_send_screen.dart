import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_share.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../account/downloads_providers.dart';
import '../downloads/download_providers.dart';
import 'nearby_protocol.dart';
import 'nearby_service.dart';
import 'peer.dart';
import 'sharing_providers.dart';

class NearbySendScreen extends ConsumerStatefulWidget {
  const NearbySendScreen({super.key});

  @override
  ConsumerState<NearbySendScreen> createState() => _NearbySendScreenState();
}

class _NearbySendScreenState extends ConsumerState<NearbySendScreen> {
  final _code = (1000 + Random.secure().nextInt(9000)).toString();
  final _sessions = <NearbyChannel, NearbyShareSession>{};
  final _sent = <NearbyChannel, int>{};
  NearbyProblem? _problem;
  bool _ready = false;
  late final NearbyService _nearby = ref.read(nearbyServiceProvider);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _problem = null;
      _ready = false;
    });
    var problem = await _nearby.prepare();
    if (problem == null) {
      final inv = await ref.read(sharingServiceProvider).value?.inventory();
      final store = await ref.read(blobStoreProvider.future);
      final temp = await ref.read(shareTempDirProvider.future);
      if (inv == null) {
        problem = NearbyProblem.unsupported;
      } else {
        problem = await _nearby.advertise(
          _code,
          onPeer: (channel) {
            final session = NearbyShareSession(channel, inv, store, temp);
            session.sent.listen((n) {
              if (mounted) setState(() => _sent[channel] = n);
            });
            if (mounted) setState(() => _sessions[channel] = session);
          },
          onGone: (channel) {
            _sessions.remove(channel)?.close();
            if (mounted) setState(() {});
          },
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _problem = problem;
      _ready = problem == null;
    });
    if (problem == null) await WifiBinding.keepScreenOn(true);
  }

  @override
  void dispose() {
    for (final s in _sessions.values) {
      s.close();
    }
    _nearby.stop();
    WifiBinding.keepScreenOn(false);
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.share);

  @override
  Widget build(BuildContext context) {
    final sent = _sent.values.fold(0, (a, b) => a + b);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: ArShare.nearbyTitle,
              subtitle: ArShare.nearbyKicker,
              onBack: _back,
              showOffline: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
                children: [
                  if (_problem case final p?)
                    NearbyProblemView(problem: p, onRetry: _start)
                  else if (!_ready)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        LedgeBox(
                          color: AppColors.teal,
                          radius: 24,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            spacing: 6,
                            children: [
                              Text(
                                ArShare.wifiCode,
                                style: AppTextStyles.body15.copyWith(
                                  color: AppColors.onTeal,
                                ),
                              ),
                              Semantics(
                                label: _code.split('').join(' '),
                                excludeSemantics: true,
                                child: Text(
                                  _code,
                                  key: const Key('nearby-code'),
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.title26.copyWith(
                                    color: AppColors.card,
                                    fontSize: 44,
                                    letterSpacing: 8,
                                  ),
                                ),
                              ),
                              Text(
                                ArShare.nearbyConnected(_sessions.length),
                                style: AppTextStyles.caption13.copyWith(
                                  color: AppColors.onTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(ArShare.nearbySteps, style: AppTextStyles.body15),
                        Text(
                          ArShare.nearbyKeepOpen,
                          style: AppTextStyles.caption13,
                        ),
                        Text(
                          ArShare.wifiSent(formatBytes(sent)),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label14,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
              child: RizmaButton(
                label: ArShare.wifiStop,
                icon: 'x',
                kind: ButtonKind.outlined,
                onPressed: _back,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyProblemView extends StatelessWidget {
  const NearbyProblemView({
    super.key,
    required this.problem,
    required this.onRetry,
  });

  final NearbyProblem problem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final unsupported = problem == NearbyProblem.unsupported;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Text(
          switch (problem) {
            NearbyProblem.permission => ArShare.nearbyPermission,
            NearbyProblem.locationOff => ArShare.nearbyLocationOff,
            NearbyProblem.unsupported => ArShare.nearbyUnsupported,
          },
          key: const Key('nearby-problem'),
          textAlign: TextAlign.center,
          style: AppTextStyles.body15.copyWith(color: AppColors.amberInk),
        ),
        if (!unsupported)
          RizmaButton(
            label: ArShare.nearbyAgain,
            icon: 'retry',
            kind: ButtonKind.outlined,
            onPressed: onRetry,
          ),
      ],
    );
  }
}
