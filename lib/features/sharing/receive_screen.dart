import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_progress.dart';
import '../../core/strings/ar_share.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../account/downloads_providers.dart';
import '../account/widgets/download_updates.dart';
import '../account/widgets/item_list.dart';
import '../catalog/catalog_providers.dart';
import '../downloads/download_providers.dart';
import '../downloads/download_service.dart';
import 'nearby_protocol.dart';
import 'nearby_send_screen.dart';
import 'nearby_service.dart';
import 'peer.dart';
import 'rizma_package.dart';
import 'sharing_providers.dart';
import 'sharing_service.dart';

enum _Stage { idle, nearby, searching, opening, choosing, receiving, done }

class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  var _stage = _Stage.idle;
  String? _message;
  LocalSource? _source;
  ReceivePlan? _plan;
  Set<String> _selected = {};
  bool _someMissing = false;
  String _busyText = ArShare.receiveOpening;

  final _peers = <PeerInfo>[];
  StreamSubscription<PeerInfo>? _scan;
  bool _scanDone = false;
  final _address = TextEditingController();

  List<String>? _own;

  final _nearbyPeers = <NearbyPeer>[];
  StreamSubscription<NearbyPeer>? _discovery;
  NearbyProblem? _nearbyProblem;

  NearbyService? _nearby;

  @override
  void dispose() {
    _scan?.cancel();
    _discovery?.cancel();
    _nearby?.stop();
    _address.dispose();
    WifiBinding.unbind();
    super.dispose();
  }

  Future<void> _findNearby() async {
    _discovery?.cancel();
    final nearby = _nearby ?? ref.read<NearbyService>(nearbyServiceProvider);
    _nearby = nearby;
    setState(() {
      _stage = _Stage.nearby;
      _message = null;
      _nearbyPeers.clear();
      _nearbyProblem = null;
    });
    final problem = await nearby.prepare();
    if (!mounted) return;
    if (problem != null) {
      setState(() => _nearbyProblem = problem);
      return;
    }
    _discovery = nearby.discover().listen(
      (p) {
        if (mounted && !_nearbyPeers.any((x) => x.endpointId == p.endpointId)) {
          setState(() => _nearbyPeers.add(p));
        }
      },
      onError: (Object e) {
        if (mounted) {
          setState(
            () => _nearbyProblem = e is NearbyProblem
                ? e
                : NearbyProblem.unsupported,
          );
        }
      },
    );
  }

  Future<void> _connectNearby(NearbyPeer peer) async {
    unawaited(_discovery?.cancel());
    _discovery = null;
    setState(() {
      _stage = _Stage.opening;
      _busyText = ArShare.receiveConnecting;
    });
    final channel = await ref.read(nearbyServiceProvider).connect(peer);
    final source = channel == null
        ? null
        : await NearbyClient(channel).connect();
    if (source == null) {
      _fail(ArShare.nearbyCantConnect);
      return;
    }
    await _open(source);
  }

  Future<void> _findPhones() async {
    _scan?.cancel();
    setState(() {
      _stage = _Stage.searching;
      _message = null;
      _peers.clear();
      _scanDone = false;
    });
    await WifiBinding.bind();
    if (!mounted) return;
    unawaited(
      ref.read(localAddressesProvider)().then((a) {
        if (mounted) setState(() => _own = a);
      }),
    );
    _scan = ref
        .read(peerFinderProvider)
        .scan()
        .listen(
          (p) {
            if (mounted && !_peers.any((x) => x.host == p.host)) {
              setState(() => _peers.add(p));
            }
          },
          onDone: () {
            if (mounted) setState(() => _scanDone = true);
          },
        );
  }

  Future<void> _connect(PeerInfo peer) async {
    unawaited(_scan?.cancel());
    setState(() {
      _stage = _Stage.opening;
      _busyText = ArShare.receiveConnecting;
    });
    final source = await ref.read(peerFinderProvider).connect(peer);
    if (source == null) {
      _fail(ArShare.receiveCantConnect);
      return;
    }
    await _open(source);
  }

  Future<void> _connectTo(String address) async {
    final host = address.trim().split(':').first;
    if (host.isEmpty) return;
    setState(() {
      _stage = _Stage.opening;
      _busyText = ArShare.receiveConnecting;
    });
    await WifiBinding.bind();
    final finder = ref.read(peerFinderProvider);
    final peer = await finder.hello(host);
    if (peer == null) {
      _fail(switch (finder.lastFailure) {
        PeerFailure.timeout => ArShare.failTimeout,
        PeerFailure.refused => ArShare.failRefused,
        PeerFailure.unreachable => ArShare.failUnreachable,
        PeerFailure.notRizma => ArShare.failNotRizma,
        _ => ArShare.receiveCantConnect,
      });
      return;
    }
    await _connect(peer);
  }

  Future<void> _pickFile() async {
    final file = await ref.read(pickPackageProvider)();
    if (file == null || !mounted) return;
    setState(() {
      _stage = _Stage.opening;
      _busyText = ArShare.receiveOpening;
      _message = null;
    });
    try {
      await _open(LocalSource.package(await PackageReader.open(file)));
    } on FormatException {
      _fail(ArShare.receiveNotPackage);
    } on Exception {
      _fail(ArShare.receiveNotPackage);
    }
  }

  Future<void> _open(LocalSource source) async {
    final sharing = ref.read(sharingServiceProvider).value;
    if (sharing == null) return;
    final plan = await sharing.open(source);
    if (!mounted) return;
    if (plan.items.isEmpty) {
      _fail(
        plan.accepted ? ArShare.receiveNothingNew : ArShare.receiveUntrusted,
      );
      return;
    }
    setState(() {
      _source = source;
      _plan = plan;
      _selected = {for (final i in plan.items) i.id};
      _stage = _Stage.choosing;
    });
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _stage = _Stage.idle;
      _message = message;
    });
  }

  Future<void> _receive() async {
    final source = _source;
    final sharing = ref.read(sharingServiceProvider).value;
    if (source == null || sharing == null) return;
    final ids = {..._selected};
    setState(() => _stage = _Stage.receiving);
    await ref
        .read(downloadControllerProvider.notifier)
        .receiveFrom(
          (onProgress) => sharing.receive(source, ids, onProgress: onProgress),
        );
    final after = await sharing.open(source);
    if (!mounted) return;
    setState(() {
      _someMissing = after.items.any((i) => ids.contains(i.id));
      _stage = _Stage.done;
    });
  }

  void _reset() => setState(() {
    _stage = _Stage.idle;
    _source = null;
    _plan = null;
    _message = null;
  });

  @override
  Widget build(BuildContext context) {
    ref.watch(sharingServiceProvider);
    final titles = {
      for (final l in ref.watch(catalogProvider).value?.allLessons ?? const [])
        l.id: l.title,
    };
    final plan = _plan;
    final chosen = [
      for (final i in plan?.items ?? const <DownloadItem>[])
        if (_selected.contains(i.id)) i,
    ];
    final bytes = chosen.fold<int>(0, (s, i) => s + i.size - i.received);

    Widget section(
      DownloadItemKind kind,
      String title,
      String icon,
      Color color,
      Color tint,
    ) {
      final items = [
        for (final i in plan!.items)
          if (i.kind == kind) i,
      ];
      if (items.isEmpty) return const SizedBox.shrink();
      return ItemSection(
        title: title,
        icon: icon,
        color: color,
        tint: tint,
        children: [
          for (final i in items)
            ItemCheckRow(
              item: i,
              title: titles[i.lessonId] ?? i.lessonId,
              selected: _selected.contains(i.id),
              onChanged: (on) => setState(() {
                on ? _selected.add(i.id) : _selected.remove(i.id);
              }),
            ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              showOffline: false,
              title: ArShare.receiveTitle,
              subtitle: ArShare.receiveKicker,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.downloads),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
                children: [
                  switch (_stage) {
                    _Stage.idle => _Start(
                      message: _message,
                      onPickFile: _pickFile,
                      onFindPhone: _findPhones,
                      onNearby: _findNearby,
                    ),
                    _Stage.nearby => _NearbySearching(
                      peers: _nearbyPeers,
                      problem: _nearbyProblem,
                      onPeer: _connectNearby,
                      onRetry: _findNearby,
                    ),
                    _Stage.searching => _Searching(
                      peers: _peers,
                      done: _scanDone,
                      own: _own,
                      address: _address,
                      onPeer: _connect,
                      onAddress: _connectTo,
                      onAgain: _findPhones,
                    ),
                    _Stage.opening => _Busy(_busyText),
                    _Stage.choosing || _Stage.receiving => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DownloadProgressCard(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            ArShare.receiveChoose,
                            style: AppTextStyles.section18,
                          ),
                        ),
                        section(
                          DownloadItemKind.lesson,
                          ArProgress.chooseLessons,
                          'book',
                          AppColors.teal,
                          AppColors.tealTint,
                        ),
                        section(
                          DownloadItemKind.video,
                          ArProgress.chooseVideos,
                          'video',
                          AppColors.coral,
                          AppColors.coralTint,
                        ),
                        section(
                          DownloadItemKind.attachment,
                          ArProgress.chooseFiles,
                          'file',
                          AppColors.purple,
                          AppColors.purpleTint,
                        ),
                      ],
                    ),
                    _Stage.done => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14,
                      children: [
                        Text(
                          _someMissing
                              ? ArShare.receiveSomeMissing
                              : ArShare.receiveDone,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body15.copyWith(
                            color: _someMissing
                                ? AppColors.amberInk
                                : AppColors.teal,
                          ),
                        ),
                        if (!_someMissing) ...[
                          Text(
                            ArShare.spreadTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.section18,
                          ),
                          RizmaButton(
                            label: ArShare.spreadButton,
                            icon: 'users',
                            onPressed: () =>
                                context.pushReplacement(AppRoutes.share),
                          ),
                        ],
                        RizmaButton(
                          label: ArShare.receiveAnother,
                          icon: 'download',
                          kind: ButtonKind.outlined,
                          onPressed: _reset,
                        ),
                      ],
                    ),
                  },
                ],
              ),
            ),
            if (_stage == _Stage.choosing || _stage == _Stage.receiving)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
                child: RizmaButton(
                  label: ArShare.receiveButton(formatBytes(bytes)),
                  icon: 'download',
                  onPressed: _stage == _Stage.choosing && chosen.isNotEmpty
                      ? _receive
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Start extends StatelessWidget {
  const _Start({
    required this.message,
    required this.onPickFile,
    required this.onFindPhone,
    required this.onNearby,
  });

  final String? message;
  final VoidCallback onPickFile;
  final VoidCallback onFindPhone;
  final VoidCallback onNearby;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (message != null)
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body15.copyWith(color: AppColors.amberInk),
          ),
        RizmaButton(
          label: ArShare.nearbyReceive,
          icon: 'users',
          onPressed: onNearby,
        ),
        Text(
          ArShare.nearbyReceiveNote,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption13,
        ),
        const SizedBox(height: 8),
        RizmaButton(
          label: ArShare.receivePickFile,
          icon: 'file',
          kind: ButtonKind.outlined,
          onPressed: onPickFile,
        ),
        Text(
          ArShare.receivePickNote,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption13,
        ),
        const SizedBox(height: 8),
        RizmaButton(
          label: ArShare.receiveFindPhone,
          icon: 'wifi',
          kind: ButtonKind.outlined,
          onPressed: onFindPhone,
        ),
        Text(
          ArShare.receiveFindNote,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption13,
        ),
        const SizedBox(height: 8),
        Text(
          ArShare.receiveSafety,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption13,
        ),
      ],
    );
  }
}

class _NearbySearching extends StatelessWidget {
  const _NearbySearching({
    required this.peers,
    required this.problem,
    required this.onPeer,
    required this.onRetry,
  });

  final List<NearbyPeer> peers;
  final NearbyProblem? problem;
  final ValueChanged<NearbyPeer> onPeer;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (problem case final p?) {
      return NearbyProblemView(problem: p, onRetry: onRetry);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const Row(
          spacing: 12,
          children: [
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.teal,
              ),
            ),
            Text(ArShare.nearbySearching),
          ],
        ),
        for (final p in peers)
          RizmaButton(
            key: Key('nearby-${p.code}'),
            label: ArShare.receivePhone(p.code),
            icon: 'phone',
            onPressed: () => onPeer(p),
          ),
        if (peers.isEmpty)
          Text(
            ArShare.nearbyNoneYet,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption13,
          ),
      ],
    );
  }
}

class _Searching extends StatelessWidget {
  const _Searching({
    required this.peers,
    required this.done,
    required this.own,
    required this.address,
    required this.onPeer,
    required this.onAddress,
    required this.onAgain,
  });

  final List<PeerInfo> peers;
  final bool done;
  final List<String>? own;
  final TextEditingController address;
  final ValueChanged<PeerInfo> onPeer;
  final ValueChanged<String> onAddress;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (!done)
          const Row(
            spacing: 12,
            children: [
              SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.teal,
                ),
              ),
              Text(ArShare.receiveSearching),
            ],
          ),
        for (final p in peers)
          RizmaButton(
            key: Key('peer-${p.code}'),
            label: ArShare.receivePhone(p.code),
            icon: 'phone',
            onPressed: () => onPeer(p),
          ),
        if (done && peers.isEmpty)
          Text(
            ArShare.receiveNoPhones,
            textAlign: TextAlign.center,
            style: AppTextStyles.body15.copyWith(color: AppColors.amberInk),
          ),
        if (own case final own?)
          Text(
            own.isEmpty
                ? ArShare.receiveNoWifi
                : (Peer.prefixes[own.first] ?? 24) < 24
                ? ArShare.receiveOwnAddressOnly(own.first)
                : ArShare.receiveOwnAddress(
                    own.first,
                    own.first.substring(0, own.first.lastIndexOf('.') + 1),
                  ),
            key: const Key('own-address'),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption13.copyWith(
              color: own.isEmpty ? AppColors.amberInk : null,
            ),
          ),
        if (own case final own? when own.isEmpty && Peer.diagnostics.isNotEmpty)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              Peer.diagnostics,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption13,
            ),
          ),
        if (done)
          RizmaButton(
            label: ArShare.receiveSearchAgain,
            icon: 'retry',
            kind: ButtonKind.outlined,
            onPressed: onAgain,
          ),
        const SizedBox(height: 8),
        Text(ArShare.receiveAddressHint, style: AppTextStyles.caption13),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  key: const Key('peer-address'),
                  controller: address,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '192.168.43.1',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: onAddress,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onAddress(address.text),
              child: const Text(ArShare.receiveConnect),
            ),
          ],
        ),
      ],
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        spacing: 14,
        children: [
          const CircularProgressIndicator(color: AppColors.teal),
          Text(text, style: AppTextStyles.body15),
        ],
      ),
    );
  }
}
