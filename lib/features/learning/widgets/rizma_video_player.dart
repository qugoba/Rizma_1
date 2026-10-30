import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

const videoSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

const videoSkip = Duration(seconds: 10);

String formatVideoTime(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

String formatSpeed(double s) => '${s == s.roundToDouble() ? s.toInt() : s}×';

class RizmaVideoView extends StatefulWidget {
  const RizmaVideoView({
    super.key,
    required this.controller,
    this.fullscreen = false,
  });

  final VideoPlayerController controller;

  final bool fullscreen;

  @override
  State<RizmaVideoView> createState() => _RizmaVideoViewState();
}

class _RizmaVideoViewState extends State<RizmaVideoView> {
  bool _visible = true;
  Timer? _hide;

  String? _flash;
  Timer? _flashTimer;

  double? _dragMs;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
    _scheduleHide();
  }

  @override
  void didUpdateWidget(RizmaVideoView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onTick);
      widget.controller.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onTick);
    _hide?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  bool get _ended {
    final v = _c.value;
    return v.isInitialized &&
        v.duration > Duration.zero &&
        v.position >= v.duration &&
        !v.isPlaying;
  }

  void _onTick() {
    if (!mounted) return;
    if (_ended && !_visible) _visible = true;
    setState(() {});
  }

  void _scheduleHide() {
    _hide?.cancel();
    if (!_c.value.isPlaying) return;
    _hide = Timer(const Duration(seconds: 3), () {
      if (mounted && _c.value.isPlaying) setState(() => _visible = false);
    });
  }

  void _show() {
    setState(() => _visible = true);
    _scheduleHide();
  }

  void _toggleVisible() {
    if (_visible) {
      _hide?.cancel();
      setState(() => _visible = false);
    } else {
      _show();
    }
  }

  Future<void> _togglePlay() async {
    if (_ended) {
      await _c.seekTo(Duration.zero);
      await _c.play();
    } else if (_c.value.isPlaying) {
      await _c.pause();
    } else {
      await _c.play();
    }
    _show();
  }

  Future<void> _seekBy(Duration by) async {
    final v = _c.value;
    var to = v.position + by;
    if (to < Duration.zero) to = Duration.zero;
    if (v.duration > Duration.zero && to > v.duration) to = v.duration;
    await _c.seekTo(to);
    _flashTimer?.cancel();
    setState(() => _flash = by.isNegative ? '−10' : '+10');
    _flashTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _flash = null);
    });
    _show();
  }

  Future<void> _setSpeed(double speed) async {
    await _c.setPlaybackSpeed(speed);
    _show();
  }

  Future<void> _toggleFullscreen() async {
    if (widget.fullscreen) {
      Navigator.of(context).pop();
      return;
    }
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (_, _, _) => _FullscreenVideo(controller: _c),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
    if (mounted) _show();
  }

  @override
  Widget build(BuildContext context) {
    final v = _c.value;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AspectRatio(
        aspectRatio: v.aspectRatio > 0 ? v.aspectRatio : 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: v.aspectRatio > 0 ? v.aspectRatio : 16 / 9,
                  child: VideoPlayer(_c),
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black26, Colors.black54],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final back in [true, false])
                  Expanded(
                    child: GestureDetector(
                      key: Key(back ? 'video-tap-left' : 'video-tap-right'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleVisible,
                      onDoubleTap: () => _seekBy(back ? -videoSkip : videoSkip),
                    ),
                  ),
              ],
            ),
            if (v.isBuffering)
              const Center(
                child: CircularProgressIndicator(color: AppColors.card),
              ),
            if (_flash != null)
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Text(
                      _flash!,
                      style: AppTextStyles.body16Strong.copyWith(
                        color: AppColors.card,
                      ),
                    ),
                  ),
                ),
              ),
            IgnorePointer(
              ignoring: !_visible,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _controls(v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls(VideoPlayerValue v) {
    final durMs = v.duration.inMilliseconds.toDouble();
    final posMs = (_dragMs ?? v.position.inMilliseconds.toDouble()).clamp(
      0.0,
      durMs > 0 ? durMs : 0.0,
    );
    final playing = v.isPlaying;
    return SizedBox.expand(
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 18,
              children: [
                _RoundButton(
                  icon: Icons.replay_10_rounded,
                  label: ArLearn.videoSkipBack,
                  onPressed: () => _seekBy(-videoSkip),
                ),
                _RoundButton(
                  icon: _ended
                      ? Icons.replay_rounded
                      : playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: _ended
                      ? ArLearn.videoReplay
                      : playing
                      ? ArLearn.videoPause
                      : ArLearn.videoPlay,
                  big: true,
                  onPressed: _togglePlay,
                ),
                _RoundButton(
                  icon: Icons.forward_10_rounded,
                  label: ArLearn.videoSkipForward,
                  onPressed: () => _seekBy(videoSkip),
                ),
              ],
            ),
          ),
          Positioned(
            left: 4,
            right: 4,
            bottom: 0,
            child: Row(
              children: [
                const SizedBox(width: 6),
                Text(
                  formatVideoTime(Duration(milliseconds: posMs.round())),
                  style: _timeStyle,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: AppColors.mint,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: AppColors.card,
                    ),
                    child: Semantics(
                      label: ArLearn.videoPosition,
                      child: Slider(
                        value: posMs,
                        max: durMs > 0 ? durMs : 1,
                        onChangeStart: (_) => _hide?.cancel(),
                        onChanged: durMs > 0
                            ? (x) => setState(() => _dragMs = x)
                            : null,
                        onChangeEnd: (x) async {
                          await _c.seekTo(Duration(milliseconds: x.round()));
                          setState(() => _dragMs = null);
                          _show();
                        },
                      ),
                    ),
                  ),
                ),
                Text(formatVideoTime(v.duration), style: _timeStyle),
                PopupMenuButton<double>(
                  key: const Key('video-speed'),
                  tooltip: ArLearn.videoSpeedLabel,
                  initialValue: v.playbackSpeed,
                  onOpened: () => _hide?.cancel(),
                  onCanceled: _show,
                  onSelected: _setSpeed,
                  itemBuilder: (_) => [
                    for (final s in videoSpeeds)
                      PopupMenuItem(value: s, child: Text(formatSpeed(s))),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      formatSpeed(v.playbackSpeed),
                      style: _timeStyle,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('video-fullscreen'),
                  tooltip: widget.fullscreen
                      ? ArLearn.videoExitFullscreen
                      : ArLearn.videoFullscreen,
                  onPressed: _toggleFullscreen,
                  icon: Icon(
                    widget.fullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: AppColors.card,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final _timeStyle = AppTextStyles.caption13.copyWith(
    color: AppColors.card,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.big = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final size = big ? 64.0 : 46.0;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: big ? AppColors.card : Colors.black38,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(
              icon,
              size: big ? 36 : 28,
              color: big ? AppColors.teal : AppColors.card,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RizmaVideoView(controller: widget.controller, fullscreen: true),
      ),
    );
  }
}
