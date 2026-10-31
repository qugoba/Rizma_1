import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar_share.dart';
import 'package:rizma/features/account/downloads_providers.dart';
import 'package:rizma/features/downloads/blob_store.dart';
import 'package:rizma/features/downloads/download_providers.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/sharing/nearby_protocol.dart';
import 'package:rizma/features/sharing/nearby_service.dart';
import 'package:rizma/features/sharing/peer.dart';
import 'package:rizma/features/sharing/rizma_package.dart';
import 'package:rizma/features/sharing/sharing_providers.dart';
import 'package:rizma/features/sharing/sharing_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

const mb = 1024 * 1024;
final videoSha = 'a' * 64;
final pdfSha = 'b' * 64;

class FakeSharing implements SharingService {
  FakeSharing(this.store, {this.plan});

  @override
  final BlobStore store;
  ReceivePlan? plan;
  final received = <Set<String>>[];

  @override
  List<PackEntry> packEntries(ShareInventory inv, Set<String> mediaIds) => [
    PackEntry.bytes('v1/grades/5/manifest.json', [1, 2, 3]),
    for (final i in inv.media)
      if (mediaIds.contains(i.id))
        for (final sha in i.blobs.keys)
          PackEntry.file('v1/blobs/$sha', store.blob(sha), 10),
  ];

  @override
  Future<void> writePackage(
    File out,
    List<PackEntry> entries, {
    void Function(int written)? onProgress,
  }) => RizmaPackage.write(out, entries, onProgress: onProgress);

  @override
  Future<ReceivePlan> open(LocalSource source) async =>
      plan ?? const ReceivePlan(items: [], accepted: true);

  @override
  Future<RunResult> receive(
    LocalSource source,
    Set<String> itemIds, {
    bool Function()? mayContinue,
    void Function(DownloadProgress progress)? onProgress,
  }) async {
    received.add(itemIds);
    plan = const ReceivePlan(items: [], accepted: true);
    return RunResult.done;
  }

  ShareInventory? inv;

  @override
  Future<ShareInventory> inventory() async => inv!;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNearby extends NearbyService {
  FakeNearby({this.problem, this.peers = const []})
    : super(() async => Directory.systemTemp);

  NearbyProblem? problem;
  final List<NearbyPeer> peers;
  final advertised = <String>[];
  final connected = <String>[];
  var stopped = 0;

  @override
  Future<NearbyProblem?> prepare() async => problem;

  @override
  Future<NearbyProblem?> advertise(
    String code, {
    required void Function(NearbyChannel channel) onPeer,
    required void Function(NearbyChannel channel) onGone,
  }) async {
    advertised.add(code);
    return null;
  }

  @override
  Stream<NearbyPeer> discover() => Stream.fromIterable(peers);

  @override
  Future<NearbyChannel?> connect(NearbyPeer peer) async {
    connected.add(peer.code);
    return null;
  }

  @override
  Future<void> stop() async => stopped++;
}

class FakeFinder extends PeerFinder {
  FakeFinder(this.peers);

  final List<PeerInfo> peers;
  final connected = <String>[];

  @override
  Stream<PeerInfo> scan() => Stream.fromIterable(peers);

  @override
  Future<PeerInfo?> hello(String host) async =>
      peers.where((p) => p.host == host).firstOrNull;

  @override
  Future<LocalSource?> connect(PeerInfo peer) async {
    connected.add(peer.code);
    return LocalSource(
      baseUrl: peer.baseUrl,
      client: http.Client(),
      grades: {5},
      blobs: {videoSha},
    );
  }
}

void main() {
  setUpAll(loadCairoFont);

  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('rizma_ui'));
  tearDown(() async => tmp.delete(recursive: true));

  Future<void> seed(ProfileRepository repo) =>
      repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);

  Future<void> open(WidgetTester tester, String location) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RizmaApp)),
    );
    container.read(routerProvider).push(location);
    await tester.pumpAndSettle();
  }

  final inventory = ShareInventory(
    manifests: {
      5: ([1, 2, 3], [4, 5, 6]),
    },
    core: {'c' * 64: 40 * 1024},
    media: [
      DownloadItem.test(
        lessonId: 'english.u1.l1',
        kind: DownloadItemKind.video,
        blobs: {videoSha: 30 * mb},
        state: DownloadItemState.onPhone,
      ),
      DownloadItem.test(
        lessonId: 'english.u1.l1',
        kind: DownloadItemKind.attachment,
        blobs: {pdfSha: 500 * 1024},
        state: DownloadItemState.onPhone,
      ),
    ],
  );

  Future<void> run(
    WidgetTester tester,
    FakeSharing sharing,
    Future<void> Function(AppDatabase db) body, {
    ShareInventory? inv,
    Future<void> Function(File file)? share,
    Future<File?> Function()? pick,
    List<Override> extra = const [],
  }) => scenario(
    tester,
    seed: seed,
    overrides: [
      sharingServiceProvider.overrideWith((ref) => sharing),
      shareInventoryProvider.overrideWith((ref) => inv ?? inventory),
      shareTempDirProvider.overrideWith((ref) => tmp),
      blobStoreProvider.overrideWith((ref) async => BlobStore(tmp)),
      if (share != null) shareFileProvider.overrideWithValue(share),
      if (pick != null) pickPackageProvider.overrideWithValue(pick),
      ...extra,
    ],
    body,
  );

  group('شارك الدروس', () {
    testWidgets('الفيديو والملفات مختارة، والحجم يتغيّر مع الاختيار', (tester) {
      final sharing = FakeSharing(BlobStore(tmp));
      return run(tester, sharing, (db) async {
        await open(tester, '/account/downloads/share');
        expect(find.text(ArShare.sendVideos), findsOneWidget);
        expect(find.text(ArShare.sendFiles), findsOneWidget);
        expect(
          find.text(ArShare.sendCore(formatBytes(40 * 1024))),
          findsOneWidget,
        );
        final all = RizmaPackage.sizeOf(
          sharing.packEntries(inventory, {
            'video:english.u1.l1',
            'attachment:english.u1.l1',
          }),
        );
        expect(find.text(ArShare.sendButton(formatBytes(all))), findsOneWidget);

        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();
        final onlyPdf = RizmaPackage.sizeOf(
          sharing.packEntries(inventory, {'attachment:english.u1.l1'}),
        );
        expect(
          find.text(ArShare.sendButton(formatBytes(onlyPdf))),
          findsOneWidget,
        );
      });
    });

    testWidgets('«أرسل» يكتب ملف رزمة ويفتح قائمة المشاركة', (tester) {
      final store = BlobStore(tmp);
      final sharing = FakeSharing(store);
      final shared = <File>[];
      return run(tester, sharing, share: (file) async => shared.add(file), (
        db,
      ) async {
        await tester.runAsync(() async {
          await store.writeBlob(pdfSha, List.filled(10, 7));
        });
        await open(tester, '/account/downloads/share');
        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.textContaining('أرسل ملف رزمة'));
          for (var i = 0; i < 50 && shared.isEmpty; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            await tester.pump();
          }
        });
        expect(shared, hasLength(1));
        expect(shared.single.path, endsWith('.rizma'));
        final reader = await tester.runAsync(
          () => PackageReader.open(shared.single),
        );
        expect(reader!.blobs, {pdfSha});
      });
    });

    testWidgets('لا شيء على الهاتف بعد: يقول ذلك', (tester) {
      return run(
        tester,
        FakeSharing(BlobStore(tmp)),
        inv: const ShareInventory(manifests: {}, core: {}, media: []),
        (db) async {
          await open(tester, '/account/downloads/share');
          expect(find.text(ArShare.sendNothing), findsOneWidget);
        },
      );
    });
  });

  group('استلم دروسًا', () {
    Future<File> packageFile() async {
      final file = File('${tmp.path}/in.rizma');
      await RizmaPackage.write(file, [
        PackEntry.bytes('v1/blobs/$pdfSha', [1, 2, 3]),
      ]);
      return file;
    }

    Future<void> pickFile(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.tap(find.text(ArShare.receivePickFile));
        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
    }

    testWidgets('ملف ليس رزمة: يقول ذلك', (tester) {
      return run(
        tester,
        FakeSharing(BlobStore(tmp)),
        pick: () async => File('${tmp.path}/x.rizma')..writeAsStringSync('hi'),
        (db) async {
          await open(tester, '/account/downloads/receive');
          await pickFile(tester);
          expect(find.text(ArShare.receiveNotPackage), findsOneWidget);
        },
      );
    });

    testWidgets('ما في الملف بأحجامه، و«أضف» يأخذ المختار', (tester) {
      final sharing = FakeSharing(
        BlobStore(tmp),
        plan: ReceivePlan(
          accepted: true,
          items: [
            DownloadItem.test(
              lessonId: 'english.u1.l1',
              kind: DownloadItemKind.video,
              blobs: {videoSha: 30 * mb},
            ),
            DownloadItem.test(
              lessonId: 'english.u1.l1',
              kind: DownloadItemKind.attachment,
              blobs: {pdfSha: 500 * 1024},
            ),
          ],
        ),
      );
      return run(tester, sharing, pick: packageFile, (db) async {
        await open(tester, '/account/downloads/receive');
        await pickFile(tester);
        expect(find.text(ArShare.receiveChoose), findsOneWidget);
        expect(
          find.text(ArShare.receiveButton(formatBytes(30 * mb + 500 * 1024))),
          findsOneWidget,
        );
        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(ArShare.receiveButton(formatBytes(500 * 1024))),
        );
        await tester.pumpAndSettle();
        expect(sharing.received, [
          {'attachment:english.u1.l1'},
        ]);
        expect(find.text(ArShare.receiveDone), findsOneWidget);
        expect(find.text(ArShare.spreadTitle), findsOneWidget);
        await tester.tap(find.text(ArShare.spreadButton));
        await tester.pumpAndSettle();
        expect(find.text(ArShare.nearbySend), findsOneWidget);
      });
    });

    testWidgets('توقيع لا يُعرف: لا يؤخذ شيء ويقول ذلك', (tester) {
      return run(
        tester,
        FakeSharing(
          BlobStore(tmp),
          plan: const ReceivePlan(items: [], accepted: false),
        ),
        pick: packageFile,
        (db) async {
          await open(tester, '/account/downloads/receive');
          await pickFile(tester);
          expect(find.text(ArShare.receiveUntrusted), findsOneWidget);
        },
      );
    });
  });

  group('على Wi-Fi', () {
    final phone = PeerInfo(
      baseUrl: Uri.parse('http://192.168.43.1:47123/'),
      code: '4821',
    );
    final videoPlan = ReceivePlan(
      accepted: true,
      items: [
        DownloadItem.test(
          lessonId: 'english.u1.l1',
          kind: DownloadItemKind.video,
          blobs: {videoSha: 30 * mb},
        ),
      ],
    );

    testWidgets('المرسل: الرمز والعنوان، و«أوقف» يغلق الشاشة', (tester) {
      final sharing = FakeSharing(BlobStore(tmp))..inv = inventory;
      PeerServer? started;
      return run(
        tester,
        sharing,
        extra: [
          localAddressesProvider.overrideWithValue(
            () async => ['192.168.43.1'],
          ),
          peerServerStarterProvider.overrideWithValue(
            (inv) async => started = await PeerServer.start(
              inv,
              BlobStore(tmp),
              port: 0,
              code: '4821',
              address: InternetAddress.loopbackIPv4,
            ),
          ),
        ],
        (db) async {
          await open(tester, '/account/downloads/share');
          await tester.runAsync(() async {
            await tester.tap(find.text(ArShare.sendWifi));
            for (var i = 0; i < 50 && started == null; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 20));
              await tester.pump();
            }
          });
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('wifi-code')), findsOneWidget);
          expect(find.text('4821'), findsOneWidget);
          expect(
            find.text(ArShare.wifiAddress('192.168.43.1')),
            findsOneWidget,
          );
          expect(started, isNotNull);
          await tester.tap(find.text(ArShare.wifiStop));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('wifi-code')), findsNothing);
        },
      );
    });

    testWidgets('المرسل بلا شبكة: يقول كيف يشغّل الهوتسبوت', (tester) {
      return run(
        tester,
        FakeSharing(BlobStore(tmp))..inv = inventory,
        extra: [localAddressesProvider.overrideWithValue(() async => [])],
        (db) async {
          await open(tester, '/account/downloads/share/wifi');
          expect(find.text(ArShare.wifiNoNetwork), findsOneWidget);
        },
      );
    });

    testWidgets('المستلم يجد الهاتف برمزه ويختار منه', (tester) {
      final finder = FakeFinder([phone]);
      return run(
        tester,
        FakeSharing(BlobStore(tmp), plan: videoPlan),
        extra: [peerFinderProvider.overrideWithValue(finder)],
        (db) async {
          await open(tester, '/account/downloads/receive');
          await tester.tap(find.text(ArShare.receiveFindPhone));
          await tester.pumpAndSettle();
          await tester.tap(find.text(ArShare.receivePhone('4821')));
          await tester.pumpAndSettle();
          expect(finder.connected, ['4821']);
          expect(find.text(ArShare.receiveChoose), findsOneWidget);
          expect(
            find.text(ArShare.receiveButton(formatBytes(30 * mb))),
            findsOneWidget,
          );
        },
      );
    });

    testWidgets('لا هاتف قريب: يقول ذلك، ويمكن كتابة العنوان', (tester) {
      final finder = FakeFinder([]);
      return run(
        tester,
        FakeSharing(BlobStore(tmp), plan: videoPlan),
        extra: [peerFinderProvider.overrideWithValue(finder)],
        (db) async {
          await open(tester, '/account/downloads/receive');
          await tester.tap(find.text(ArShare.receiveFindPhone));
          await tester.pumpAndSettle();
          expect(find.text(ArShare.receiveNoPhones), findsOneWidget);

          finder.peers.add(phone);
          await tester.enterText(
            find.byKey(const Key('peer-address')),
            '192.168.43.1',
          );
          await tester.tap(find.text(ArShare.receiveConnect));
          await tester.pumpAndSettle();
          expect(finder.connected, ['4821']);
          expect(find.text(ArShare.receiveChoose), findsOneWidget);
        },
      );
    });
  });

  group('مع القريبين (بدون نت)', () {
    testWidgets('المرسل: يعلن برمز ويبقى حتى الخروج', (tester) {
      final nearby = FakeNearby();
      return run(
        tester,
        FakeSharing(BlobStore(tmp))..inv = inventory,
        extra: [nearbyServiceProvider.overrideWithValue(nearby)],
        (db) async {
          await open(tester, '/account/downloads/share');
          await tester.runAsync(() async {
            await tester.tap(find.text(ArShare.nearbySend));
            for (var i = 0; i < 30 && nearby.advertised.isEmpty; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 20));
              await tester.pump();
            }
          });
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('nearby-code')), findsOneWidget);
          expect(find.text(nearby.advertised.single), findsOneWidget);
          expect(find.text(ArShare.nearbyConnected(0)), findsOneWidget);

          await tester.tap(find.text(ArShare.wifiStop));
          await tester.pumpAndSettle();
          expect(nearby.stopped, greaterThan(0));
        },
      );
    });

    testWidgets('الموقع مطفأ (أندرويد قديم): يقول ذلك ويسمح بالمحاولة', (
      tester,
    ) {
      final nearby = FakeNearby(problem: NearbyProblem.locationOff);
      return run(
        tester,
        FakeSharing(BlobStore(tmp))..inv = inventory,
        extra: [nearbyServiceProvider.overrideWithValue(nearby)],
        (db) async {
          await open(tester, '/account/downloads/share/nearby');
          expect(find.text(ArShare.nearbyLocationOff), findsOneWidget);
          nearby.problem = null;
          await tester.runAsync(() async {
            await tester.tap(find.text(ArShare.nearbyAgain));
            for (var i = 0; i < 30 && nearby.advertised.isEmpty; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 20));
              await tester.pump();
            }
          });
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('nearby-code')), findsOneWidget);
        },
      );
    });

    testWidgets('هاتف بلا خدمات Google: يوجّه للهوتسبوت', (tester) {
      return run(
        tester,
        FakeSharing(BlobStore(tmp)),
        extra: [
          nearbyServiceProvider.overrideWithValue(
            FakeNearby(problem: NearbyProblem.unsupported),
          ),
        ],
        (db) async {
          await open(tester, '/account/downloads/receive');
          await tester.tap(find.text(ArShare.nearbyReceive));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text(ArShare.nearbyUnsupported), findsOneWidget);
        },
      );
    });

    testWidgets('المستلم يرى الهواتف برموزها، وإن ابتعد الهاتف يقول ذلك', (
      tester,
    ) {
      final nearby = FakeNearby(
        peers: const [NearbyPeer(endpointId: 'e1', code: '4821')],
      );
      return run(
        tester,
        FakeSharing(BlobStore(tmp)),
        extra: [nearbyServiceProvider.overrideWithValue(nearby)],
        (db) async {
          await open(tester, '/account/downloads/receive');
          await tester.tap(find.text(ArShare.nearbyReceive));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          await tester.tap(find.text(ArShare.receivePhone('4821')));
          await tester.pumpAndSettle();
          expect(nearby.connected, ['4821']);
          expect(find.text(ArShare.nearbyCantConnect), findsOneWidget);
        },
      );
    });
  });
}
