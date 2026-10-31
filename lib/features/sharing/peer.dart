import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../downloads/blob_store.dart';
import '../downloads/download_service.dart';
import 'sharing_service.dart';

abstract final class Peer {
  static const port = 47123;

  static final _blobPath = RegExp(r'^/v1/blobs/([0-9a-f]{64})$');
  static final _manifestPath = RegExp(
    r'^/v1/grades/(\d{1,2})/manifest\.json(\.sig)?$',
  );

  static String diagnostics = '';

  static Future<List<String>> localAddresses() async {
    final lines = [...await WifiBinding.platformAddresses()];
    try {
      for (final i in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      )) {
        for (final a in i.addresses) {
          lines.add('dart|${i.name}|${a.address}');
        }
      }
    } catch (e) {
      lines.add('error|dart|${e.runtimeType}');
    }
    diagnostics = lines.join(' · ');
    return pickAddresses(lines);
  }

  static final prefixes = <String, int>{};

  static List<String> pickAddresses(List<String> lines) {
    final ranked = <(int, int, String, int?)>[];
    for (final (i, line) in lines.indexed) {
      final p = line.split('|');
      if (p.length != 3 || p[0] == 'error') continue;
      final slash = p[2].indexOf('/');
      final ip = slash < 0 ? p[2] : p[2].substring(0, slash);
      final prefix = slash < 0 ? null : int.tryParse(p[2].substring(slash + 1));
      if (!isUsable(ip)) continue;
      final iface = interfaceRank(p[1]);
      final rank = switch (p[0]) {
        'wifi' => 0,
        'wm' => 1,
        _ => iface == null ? null : 2 + iface,
      };
      if (rank != null) ranked.add((rank, i, ip, prefix));
    }
    ranked.sort(
      (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
    );
    for (final (_, _, ip, prefix) in ranked) {
      if (prefix != null) prefixes.putIfAbsent(ip, () => prefix);
    }
    return {for (final (_, _, ip, _) in ranked) ip}.toList();
  }

  static List<String> hostsAround(String ip, int? prefix) {
    final p = ip.split('.').map(int.parse).toList();
    final value = (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
    final bits = prefix == null || prefix < 22 || prefix > 30 ? 24 : prefix;
    final mask = (0xffffffff << (32 - bits)) & 0xffffffff;
    final network = value & mask;
    final broadcast = network | (~mask & 0xffffffff);
    String text(int v) =>
        '${v >> 24 & 0xff}.${v >> 16 & 0xff}.${v >> 8 & 0xff}.${v & 0xff}';
    int near(int v) =>
        (v >> 8 == value >> 8 ? 0 : 2) + ((v & 0xff) == 1 ? 0 : 1);
    final hosts =
        [
          for (var v = network + 1; v < broadcast; v++)
            if (v != value) v,
        ]..sort(
          (a, b) =>
              near(a) != near(b) ? near(a).compareTo(near(b)) : a.compareTo(b),
        );
    return [for (final v in hosts) text(v)];
  }

  static int? interfaceRank(String name) {
    final n = name.toLowerCase();
    if (RegExp(
      r'^(rmnet|ccmni|pdp|ppp|tun|v4-|dummy|ip6tnl|sit)',
    ).hasMatch(n)) {
      return null;
    }
    if (RegExp(r'^(wlan|swlan|ap|wl|eth|en|softap)').hasMatch(n)) return 0;
    if (n.startsWith('p2p')) return 1;
    return 2;
  }

  static bool isUsable(String ip) {
    final p = ip.split('.').map(int.tryParse).toList();
    if (p.length != 4 || p.any((x) => x == null || x < 0 || x > 255)) {
      return false;
    }
    final a = p[0]!, b = p[1]!;
    return a != 0 && a != 127 && a < 224 && !(a == 169 && b == 254);
  }
}

abstract final class WifiBinding {
  static const _channel = MethodChannel('rizma/network');

  static Future<bool> bind() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('bindWifi') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> unbind() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('unbind');
    } catch (_) {}
  }

  static Future<void> keepScreenOn(bool on) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('keepScreenOn', on);
    } catch (_) {}
  }

  static Future<int?> sdkInt() async {
    if (!Platform.isAndroid) return null;
    try {
      return await _channel.invokeMethod<int>('sdkInt');
    } catch (_) {
      return null;
    }
  }

  static Future<List<String>> platformAddresses() async {
    if (!Platform.isAndroid) return const [];
    try {
      return (await _channel.invokeListMethod<String>('localAddresses')) ??
          const [];
    } catch (e) {
      return ['error|android|${e.runtimeType}'];
    }
  }
}

class PeerServer {
  PeerServer._(this._server, this.code, this._inv, this._store);

  final HttpServer _server;

  final String code;
  final ShareInventory _inv;
  final BlobStore _store;

  int get port => _server.port;

  int sentBytes = 0;
  final _sent = StreamController<int>.broadcast();
  Stream<int> get sent => _sent.stream;

  static Future<PeerServer> start(
    ShareInventory inv,
    BlobStore store, {
    int port = Peer.port,
    String? code,
    InternetAddress? address,
  }) async {
    final server = await HttpServer.bind(
      address ?? InternetAddress.anyIPv4,
      port,
    );
    final peer = PeerServer._(
      server,
      code ?? (1000 + Random.secure().nextInt(9000)).toString(),
      inv,
      store,
    );
    server.listen(peer._handle, onError: (_) {});
    return peer;
  }

  Future<void> close() async {
    await _server.close(force: true);
    await _sent.close();
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    try {
      if (req.method != 'GET') return _status(res, HttpStatus.methodNotAllowed);
      final path = req.uri.path;
      if (path == '/rizma/hello') {
        return _json(res, {'app': 'rizma', 'v': 1, 'code': code});
      }
      if (path == '/rizma/inventory.json') {
        return _json(res, {
          'grades': _inv.manifests.keys.toList(),
          'blobs': _inv.blobs.toList(),
        });
      }
      if (Peer._manifestPath.firstMatch(path) case final m?) {
        final entry = _inv.manifests[int.parse(m.group(1)!)];
        if (entry == null) return _status(res, HttpStatus.notFound);
        final bytes = m.group(2) == null ? entry.$1 : entry.$2;
        res.contentLength = bytes.length;
        res.add(bytes);
        return res.close();
      }
      if (Peer._blobPath.firstMatch(path) case final m?) {
        final sha = m.group(1)!;
        final file = _store.blob(sha);
        if (!_inv.blobs.contains(sha) || !await file.exists()) {
          return _status(res, HttpStatus.notFound);
        }
        final size = await file.length();
        final range = RegExp(
          r'^bytes=(\d+)-$',
        ).firstMatch(req.headers.value(HttpHeaders.rangeHeader) ?? '');
        final from = range == null ? 0 : int.parse(range.group(1)!);
        if (from > 0 && from >= size) {
          return _status(res, HttpStatus.requestedRangeNotSatisfiable);
        }
        if (from > 0) {
          res.statusCode = HttpStatus.partialContent;
          res.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes $from-${size - 1}/$size',
          );
        }
        res.contentLength = size - from;
        await res.addStream(
          file.openRead(from).map((chunk) {
            sentBytes += chunk.length;
            if (!_sent.isClosed) _sent.add(sentBytes);
            return chunk;
          }),
        );
        return res.close();
      }
      return _status(res, HttpStatus.notFound);
    } catch (_) {
      try {
        await res.close();
      } catch (_) {}
    }
  }

  static Future<void> _json(HttpResponse res, Object body) {
    final bytes = utf8.encode(jsonEncode(body));
    res.headers.contentType = ContentType.json;
    res.contentLength = bytes.length;
    res.add(bytes);
    return res.close();
  }

  static Future<void> _status(HttpResponse res, int status) {
    res.statusCode = status;
    return res.close();
  }
}

enum PeerFailure {
  timeout,

  refused,

  unreachable,

  notRizma,
  other;

  static PeerFailure of(Object error) {
    final e = error.toString().toLowerCase();
    if (error is TimeoutException || e.contains('timed out')) return timeout;
    if (e.contains('refused')) return refused;
    if (e.contains('unreachable') || e.contains('no route')) return unreachable;
    return other;
  }
}

class PeerInfo {
  const PeerInfo({required this.baseUrl, required this.code});

  final Uri baseUrl;
  final String code;

  String get host => baseUrl.host;
}

class PeerFinder {
  PeerFinder({
    http.Client? client,
    Future<List<String>> Function()? addresses,
    this.port = Peer.port,
    this.timeout = const Duration(milliseconds: 1500),
  }) : _client =
           client ??
           IOClient(
             HttpClient()
               ..connectionTimeout = const Duration(milliseconds: 1500),
           ),
       _addresses = addresses ?? Peer.localAddresses;

  final http.Client _client;
  final Future<List<String>> Function() _addresses;
  final int port;
  final Duration timeout;

  PeerFailure? lastFailure;

  Future<PeerInfo?> hello(String host) async {
    final base = Uri(scheme: 'http', host: host, port: port, path: '/');
    try {
      final res = await _client
          .get(base.resolve('rizma/hello'))
          .timeout(timeout);
      Object? json;
      try {
        json = res.statusCode == 200 ? jsonDecode(res.body) : null;
      } on FormatException {
        json = null;
      }
      if (json is! Map || json['app'] != 'rizma' || json['code'] is! String) {
        lastFailure = PeerFailure.notRizma;
        return null;
      }
      lastFailure = null;
      return PeerInfo(baseUrl: base, code: json['code'] as String);
    } catch (e) {
      lastFailure = PeerFailure.of(e);
      return null;
    }
  }

  Stream<PeerInfo> scan() async* {
    List<String> own;
    try {
      own = await _addresses();
    } catch (_) {
      own = const [];
    }
    final list = <String>{
      for (final ip in own) ...Peer.hostsAround(ip, Peer.prefixes[ip]),
    }.difference(own.toSet()).toList();
    const batch = 64;
    for (var i = 0; i < list.length; i += batch) {
      final found = await Future.wait(list.skip(i).take(batch).map(hello));
      for (final p in found) {
        if (p != null) yield p;
      }
    }
  }

  Future<LocalSource?> connect(PeerInfo peer) async {
    try {
      final res = await _client
          .get(peer.baseUrl.resolve('rizma/inventory.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return LocalSource(
        baseUrl: peer.baseUrl,
        client: _client,
        grades: {for (final g in json['grades'] as List) g as int},
        blobs: {
          for (final b in json['blobs'] as List)
            if (b is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(b)) b,
        },
      );
    } catch (_) {
      return null;
    }
  }
}
