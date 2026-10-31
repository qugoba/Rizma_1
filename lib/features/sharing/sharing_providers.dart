import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/strings/ar_share.dart';
import '../downloads/download_providers.dart';
import '../downloads/download_service.dart';
import 'nearby_service.dart';
import 'peer.dart';
import 'sharing_service.dart';

final sharingServiceProvider = FutureProvider<SharingService?>((ref) async {
  final config = ref.watch(contentConfigProvider);
  final downloads = await ref.watch(downloadServiceProvider.future);
  if (config == null || downloads == null) return null;
  final store = await ref.watch(blobStoreProvider.future);
  return SharingService(
    store: store,
    downloads: downloads,
    localDownloads: (source) => buildDownloadService(
      ref,
      store,
      ContentConfig(baseUrl: source.baseUrl, publicKeys: config.publicKeys),
      client: source.client,
      localSource: true,
      idleTimeout: source.idleTimeout,
    ),
  );
});

final shareInventoryProvider = FutureProvider.autoDispose<ShareInventory?>((
  ref,
) async {
  ref.watch(contentBlobsProvider);
  ref.watch(contentLessonsProvider);
  final sharing = await ref.watch(sharingServiceProvider.future);
  return sharing?.inventory();
});

final shareTempDirProvider = FutureProvider<Directory>((ref) async {
  final dir = Directory('${(await getTemporaryDirectory()).path}/rizma-share');
  return dir.create(recursive: true);
});

final shareFileProvider = Provider<Future<void> Function(File file)>(
  (ref) => (file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/octet-stream')],
        title: ArShare.sendTitle,
      ),
    );
  },
);

final pickPackageProvider = Provider<Future<File?> Function()>(
  (ref) => () async {
    final picked = await FilePicker.pickFile();
    if (picked == null) return null;
    final path = picked.path;
    if (path != null) return File(path);
    final dir = await ref.read(shareTempDirProvider.future);
    final out = File('${dir.path}/received.rizma');
    final sink = out.openWrite();
    await sink.addStream(picked.readAsByteStream());
    await sink.close();
    return out;
  },
);

final peerFinderProvider = Provider<PeerFinder>((ref) => PeerFinder());

final peerServerStarterProvider =
    Provider<Future<PeerServer> Function(ShareInventory inv)>(
      (ref) =>
          (inv) async =>
              PeerServer.start(inv, await ref.read(blobStoreProvider.future)),
    );

final localAddressesProvider = Provider<Future<List<String>> Function()>(
  (ref) => Peer.localAddresses,
);

final nearbyServiceProvider = Provider<NearbyService>(
  (ref) => NearbyService(() => ref.read(shareTempDirProvider.future)),
);
