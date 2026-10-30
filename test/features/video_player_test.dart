import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/features/learning/widgets/rizma_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlatform extends VideoPlayerPlatform {
  final calls = <String>[];
  final _events = StreamController<VideoEvent>.broadcast();
  Duration position = Duration.zero;
  static const length = Duration(minutes: 1);

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async => 1;

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async => 1;

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    scheduleMicrotask(
      () => _events.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: length,
          size: const Size(1280, 720),
        ),
      ),
    );
    return _events.stream;
  }

  @override
  Future<void> play(int playerId) async => calls.add('play');

  @override
  Future<void> pause(int playerId) async => calls.add('pause');

  @override
  Future<void> seekTo(int playerId, Duration to) async {
    position = to;
    calls.add('seek:${to.inSeconds}');
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async =>
      calls.add('speed:$speed');

  @override
  Future<Duration> getPosition(int playerId) async => position;

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Widget buildView(int playerId) => const ColoredBox(color: Colors.black);

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black);
}

void main() {
  late FakeVideoPlatform platform;
  late VideoPlayerController controller;
  final systemCalls = <String>[];

  setUp(() {
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    systemCalls.clear();
  });

  Future<void> show(WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          systemCalls.add('${call.method}:${call.arguments}');
          return null;
        });
    controller = VideoPlayerController.networkUrl(
      Uri.parse('https://content.test/v1/blobs/video'),
    );
    await tester.runAsync(controller.initialize);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: RizmaVideoView(controller: controller)),
        ),
      ),
    );
    await tester.pump();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await controller.dispose();
    });
  }

  Finder button(String label) => find.bySemanticsLabel(label);

  testWidgets('الوقت والمدة والسرعة ظاهرة', (tester) async {
    await show(tester);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget);
    expect(find.text('1×'), findsOneWidget);
  });

  testWidgets('تشغيل ثم إيقاف', (tester) async {
    await show(tester);
    await tester.tap(button(ArLearn.videoPlay));
    await tester.pump();
    expect(platform.calls, contains('play'));
    expect(button(ArLearn.videoPause), findsOneWidget);
    await tester.tap(button(ArLearn.videoPause));
    await tester.pump();
    expect(platform.calls, contains('pause'));
  });

  testWidgets('تقديم 10 ثوانٍ، والترجيع لا ينزل تحت الصفر', (tester) async {
    await show(tester);
    await tester.tap(button(ArLearn.videoSkipForward));
    await tester.pump();
    expect(platform.calls, contains('seek:10'));
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('0:10'), findsOneWidget);

    await tester.tap(button(ArLearn.videoSkipBack));
    await tester.tap(button(ArLearn.videoSkipBack));
    await tester.pump();
    expect(platform.calls.last, 'seek:0');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('لمستان على اليمين تقدّمان وعلى اليسار ترجعان', (tester) async {
    await show(tester);
    final right = find.byKey(const Key('video-tap-right'));
    await tester.tap(right);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(right);
    await tester.pump(const Duration(milliseconds: 400));
    expect(platform.calls, contains('seek:10'));

    final left = find.byKey(const Key('video-tap-left'));
    await tester.tap(left);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(left);
    await tester.pump(const Duration(milliseconds: 400));
    expect(platform.calls.last, 'seek:0');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('اختيار السرعة', (tester) async {
    await show(tester);
    await tester.tap(button(ArLearn.videoPlay));
    await tester.pump();
    await tester.tap(find.byKey(const Key('video-speed')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1.5×').last);
    await tester.pumpAndSettle();
    expect(platform.calls, contains('speed:1.5'));
    expect(find.text('1.5×'), findsOneWidget);
    await tester.runAsync(controller.pause);
    await tester.pump();
  });

  testWidgets('ملء الشاشة بالعرض بالفيديو نفسه، والخروج يرجع كل شيء', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.byKey(const Key('video-fullscreen')));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is RizmaVideoView && w.fullscreen),
      findsOneWidget,
    );
    expect(
      systemCalls.any(
        (c) =>
            c.startsWith('SystemChrome.setPreferredOrientations') &&
            c.contains('landscape'),
      ),
      isTrue,
    );

    await tester.tap(find.byKey(const Key('video-fullscreen')).last);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is RizmaVideoView && w.fullscreen),
      findsNothing,
    );
    expect(systemCalls.last, contains('SystemChrome.setEnabledSystemUIMode'));
    expect(systemCalls, contains('SystemChrome.setPreferredOrientations:[]'));
  });

  test('صيغة الوقت والسرعة', () {
    expect(formatVideoTime(const Duration(seconds: 65)), '1:05');
    expect(
      formatVideoTime(const Duration(hours: 1, minutes: 2, seconds: 9)),
      '1:02:09',
    );
    expect(formatSpeed(1), '1×');
    expect(formatSpeed(0.75), '0.75×');
  });
}
