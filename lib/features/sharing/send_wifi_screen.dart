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
import 'peer.dart';
import 'sharing_providers.dart';

class SendWifiScreen extends ConsumerStatefulWidget {
  const SendWifiScreen({super.key});

  @override
  ConsumerState<SendWifiScreen> createState() => _SendWifiScreenState();
}

class _SendWifiScreenState extends ConsumerState<SendWifiScreen> {
  PeerServer? _server;
  String? _address;
  String? _error;

  String? _detail;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final addresses = await ref.read(localAddressesProvider)();
      if (addresses.isEmpty) {
        if (mounted) {
          setState(() {
            _error = ArShare.wifiNoNetwork;
            _detail = Peer.diagnostics;
          });
        }
        return;
      }
      final sharing = ref.read(sharingServiceProvider).value;
      final inv = await sharing?.inventory();
      if (inv == null) throw StateError('no sharing');
      final server = await ref.read(peerServerStarterProvider)(inv);
      if (!mounted) {
        await server.close();
        return;
      }
      setState(() {
        _server = server;
        _address = addresses.first;
      });
      await WifiBinding.keepScreenOn(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ArShare.wifiFailed;
          _detail = '$e';
        });
      }
    }
  }

  @override
  void dispose() {
    _server?.close();
    WifiBinding.keepScreenOn(false);
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.share);

  @override
  Widget build(BuildContext context) {
    final server = _server;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: ArShare.wifiTitle,
              subtitle: ArShare.wifiKicker,
              onBack: _back,
              showOffline: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
                children: [
                  if (_error != null)
                    Column(
                      spacing: 12,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body15.copyWith(
                            color: AppColors.amberInk,
                          ),
                        ),
                        if (_detail case final d? when d.isNotEmpty)
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              d,
                              key: const Key('wifi-detail'),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption13,
                            ),
                          ),
                      ],
                    )
                  else if (server == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        spacing: 14,
                        children: [
                          CircularProgressIndicator(color: AppColors.teal),
                          Text(ArShare.wifiStarting),
                        ],
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
                                label: server.code.split('').join(' '),
                                excludeSemantics: true,
                                child: Text(
                                  server.code,
                                  key: const Key('wifi-code'),
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.title26.copyWith(
                                    color: AppColors.card,
                                    fontSize: 44,
                                    letterSpacing: 8,
                                  ),
                                ),
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  ArShare.wifiAddress(_address!),
                                  style: AppTextStyles.caption13.copyWith(
                                    color: AppColors.onTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(ArShare.wifiSteps, style: AppTextStyles.body15),
                        Text(
                          ArShare.wifiKeepOpen,
                          style: AppTextStyles.caption13,
                        ),
                        StreamBuilder<int>(
                          stream: server.sent,
                          initialData: server.sentBytes,
                          builder: (context, snap) => Text(
                            ArShare.wifiSent(formatBytes(snap.data ?? 0)),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.label14,
                          ),
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
