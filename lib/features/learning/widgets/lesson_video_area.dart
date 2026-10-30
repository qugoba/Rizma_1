import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/rizma_button.dart';
import '../../account/account_providers.dart';
import '../../account/downloads_providers.dart';
import '../../account/preferences_repository.dart';
import '../../downloads/download_providers.dart';
import 'rizma_video_player.dart';

Duration? parseVideoTime(String at) {
  final m = RegExp(r'^(\d+):([0-5]\d)$').firstMatch(at.trim());
  if (m == null) return null;
  return Duration(
    minutes: int.parse(m.group(1)!),
    seconds: int.parse(m.group(2)!),
  );
}

class LessonVideoArea extends ConsumerWidget {
  const LessonVideoArea({
    super.key,
    required this.lessonId,
    required this.placeholder,
    required this.seek,
    this.mbPerMinute,
    this.fileSha256,
  });

  final String lessonId;

  final Widget placeholder;

  final ValueListenable<Duration?> seek;

  final double? mbPerMinute;

  final String? fileSha256;

  static final _sha = RegExp(r'^[0-9a-f]{64}$');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(videoStatusProvider(lessonId));
    final config = ref.watch(contentConfigProvider);
    final sha = fileSha256;
    final fromLesson = config != null && sha != null && _sha.hasMatch(sha)
        ? config.blobUrl(sha)
        : null;
    if (status is VideoNone && fromLesson == null) return placeholder;
    if (status is VideoDownloaded) {
      final file = ref.watch(videoFileProvider(lessonId)).value;
      return file == null
          ? placeholder
          : _VideoPlayerBox(
              key: ValueKey(file.path),
              create: () => VideoPlayerController.file(file),
              seek: seek,
              lazy: false,
            );
    }

    final network = ref.watch(networkProvider).value ?? const [];
    final online =
        network.isNotEmpty && !network.contains(ConnectivityResult.none);
    final onMobile =
        online &&
        !network.contains(ConnectivityResult.wifi) &&
        !network.contains(ConnectivityResult.ethernet);
    final url = ref.watch(videoStreamUrlProvider(lessonId)) ?? fromLesson;
    final controller = ref.read(downloadControllerProvider.notifier);

    final children = <Widget>[
      if (online && url != null) ...[
        _VideoPlayerBox(
          key: ValueKey(url),
          create: () => VideoPlayerController.networkUrl(url),
          seek: seek,
          lazy: true,
        ),
        Text(
          onMobile && mbPerMinute != null
              ? ArLearn.videoMobileData(mbPerMinute!)
              : ArLearn.videoStreamNote,
          style: AppTextStyles.caption13,
        ),
      ] else ...[
        placeholder,
        if (!online)
          Text(ArLearn.videoNeedsInternet, style: AppTextStyles.caption13),
      ],
    ];

    switch (status) {
      case VideoNotDownloaded(:final size):
        if (online) {
          children.add(
            RizmaButton(
              label: ArLearn.videoDownload(formatBytes(size)),
              icon: 'download',
              kind: ButtonKind.outlined,
              onPressed: () => controller.requestVideo(lessonId),
            ),
          );
        }
      case VideoQueued() && final q:
        final prefs =
            ref.watch(downloadPrefsProvider).value ?? const DownloadPrefs();
        final waiting =
            !ref.watch(downloadControllerProvider).running &&
            !downloadAllowed(network, wifiOnly: prefs.wifiOnly);
        children.addAll([
          ProgressBar(
            value: q.fraction,
            trackColor: AppColors.sky2,
            fillColor: AppColors.teal,
            height: 8,
          ),
          Text(
            waiting
                ? ArLearn.videoWaitingWifi
                : ArLearn.videoDownloading((q.fraction * 100).round()),
            style: AppTextStyles.caption13,
          ),
          if (waiting && online)
            RizmaButton(
              label: ArLearn.videoDownload(formatBytes(q.size - q.received)),
              icon: 'download',
              kind: ButtonKind.outlined,
              onPressed: () => controller.runNow(allowMobile: true),
            ),
        ]);
      default:
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: children,
    );
  }
}

class _VideoPlayerBox extends StatefulWidget {
  const _VideoPlayerBox({
    super.key,
    required this.create,
    required this.seek,
    required this.lazy,
  });

  final VideoPlayerController Function() create;
  final ValueListenable<Duration?> seek;
  final bool lazy;

  @override
  State<_VideoPlayerBox> createState() => _VideoPlayerBoxState();
}

class _VideoPlayerBoxState extends State<_VideoPlayerBox> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!widget.lazy) _start(play: false);
    widget.seek.addListener(_onSeek);
  }

  void _start({required bool play}) {
    final c = widget.create();
    _controller = c;
    c.addListener(_onTick);
    c.initialize().then(
      (_) {
        if (!mounted) return;
        setState(() {});
        if (play) c.play();
      },
      onError: (Object _) {
        if (mounted) setState(() => _failed = true);
      },
    );
    setState(() {});
  }

  void _onTick() {
    if (!mounted) return;
    if (_controller?.value.hasError ?? false) _failed = true;
    setState(() {});
  }

  void _onSeek() {
    final to = widget.seek.value;
    final c = _controller;
    if (to == null) return;
    if (c == null) {
      _start(play: true);
      return;
    }
    if (!c.value.isInitialized) return;
    c
      ..seekTo(to)
      ..play();
  }

  @override
  void dispose() {
    widget.seek.removeListener(_onSeek);
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  Widget _message(String text) => Padding(
    padding: const EdgeInsets.all(24),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.body15.copyWith(color: AppColors.card),
    ),
  );

  Widget _playButton({required bool playing}) => Container(
    width: 64,
    height: 64,
    decoration: const BoxDecoration(
      color: AppColors.card,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: AppIcon(
        playing ? 'pause' : 'play',
        size: 30,
        color: AppColors.teal,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final value = c?.value;
    return LedgeBox(
      color: AppColors.tealDark,
      radius: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: switch (()) {
          _ when _failed => _message(
            widget.lazy ? ArLearn.videoStreamFailed : ArLearn.videoPlayFailed,
          ),
          _ when c == null => Semantics(
            button: true,
            label: ArLearn.videoWatchNow,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => _start(play: true),
              child: SizedBox(
                height: 190,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    _playButton(playing: false),
                    Text(
                      ArLearn.videoWatchNow,
                      style: AppTextStyles.body16Strong.copyWith(
                        color: AppColors.card,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _ when !value!.isInitialized => const SizedBox(
            height: 190,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.card),
            ),
          ),
          _ => RizmaVideoView(controller: c),
        },
      ),
    );
  }
}
