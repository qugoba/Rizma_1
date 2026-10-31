import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../downloads/blob_store.dart';
import '../downloads/download_service.dart';
import 'sharing_service.dart';

abstract class NearbyChannel {
  Future<void> sendMessage(Map<String, Object?> message);

  Future<int> sendFile(File file);

  Stream<Map<String, dynamic>> get messages;

  Stream<(int, File)> get files;

  Stream<(int, int, int)> get progress;

  Future<void> close();
}

class NearbyShareSession {
  NearbyShareSession(this._channel, this._inv, this._store, this._temp) {
    _sub = _channel.messages.listen(_onMessage);
  }

  final NearbyChannel _channel;
  final ShareInventory _inv;
  final BlobStore _store;
  final Directory _temp;
  late final StreamSubscription<Map<String, dynamic>> _sub;

  int sentBytes = 0;
  final _sent = StreamController<int>.broadcast();
  Stream<int> get sent => _sent.stream;

  static final _blobPath = RegExp(r'^v1/blobs/([0-9a-f]{64})$');
  static final _manifestPath = RegExp(
    r'^v1/grades/(\d{1,2})/manifest\.json(\.sig)?$',
  );

  Future<void> _onMessage(Map<String, dynamic> m) async {
    if (m['t'] != 'get') return;
    final id = m['id'];
    final path = m['path'];
    if (id is! int || path is! String) return;
    try {
      final file = await _resolve(id, path);
      if (file == null) {
        await _channel.sendMessage({'t': 'res', 'id': id, 'status': 404});
        return;
      }
      final size = await file.length();
      final pid = await _channel.sendFile(file);
      await _channel.sendMessage({
        't': 'res',
        'id': id,
        'status': 200,
        'pid': pid,
        'size': size,
      });
      if (_blobPath.hasMatch(path)) {
        sentBytes += size;
        if (!_sent.isClosed) _sent.add(sentBytes);
      }
    } catch (_) {
      await _channel.sendMessage({'t': 'res', 'id': id, 'status': 500});
    }
  }

  Future<File?> _resolve(int id, String path) async {
    List<int>? bytes;
    if (path == 'rizma/inventory.json') {
      bytes = utf8.encode(
        jsonEncode({
          'grades': _inv.manifests.keys.toList(),
          'blobs': _inv.blobs.toList(),
        }),
      );
    } else if (_manifestPath.firstMatch(path) case final m?) {
      final entry = _inv.manifests[int.parse(m.group(1)!)];
      if (entry == null) return null;
      bytes = m.group(2) == null ? entry.$1 : entry.$2;
    } else if (_blobPath.firstMatch(path) case final m?) {
      final sha = m.group(1)!;
      final file = _store.blob(sha);
      if (!_inv.blobs.contains(sha) || !await file.exists()) return null;
      return file;
    } else {
      return null;
    }
    final out = File('${_temp.path}/nearby-out-$id');
    await out.writeAsBytes(bytes, flush: true);
    return out;
  }

  Future<void> close() async {
    await _sub.cancel();
    await _sent.close();
    try {
      await for (final f in _temp.list()) {
        if (f is File && f.uri.pathSegments.last.startsWith('nearby-out-')) {
          await f.delete();
        }
      }
    } catch (_) {}
  }
}

class NearbyClient extends http.BaseClient {
  NearbyClient(this._channel, {this.timeout = const Duration(minutes: 10)}) {
    _subs.add(_channel.messages.listen(_onMessage));
    _subs.add(
      _channel.files.listen((f) {
        final (pid, file) = f;
        final waiter = _files.remove(pid);
        if (waiter != null) {
          waiter.complete(file);
        } else {
          _arrived[pid] = file;
        }
      }),
    );
  }

  static final baseUrl = Uri.parse('http://rizma-nearby.local/');

  final NearbyChannel _channel;

  final Duration timeout;

  final _subs = <StreamSubscription<Object?>>[];
  final _responses = <int, Completer<Map<String, dynamic>>>{};
  final _files = <int, Completer<File>>{};
  final _arrived = <int, File>{};
  var _next = 0;

  Stream<(int, int, int)> get progress => _channel.progress;

  void _onMessage(Map<String, dynamic> m) {
    if (m['t'] != 'res') return;
    final id = m['id'];
    if (id is int) _responses.remove(id)?.complete(m);
  }

  Future<File> _file(int pid) {
    final done = _arrived.remove(pid);
    if (done != null) return Future.value(done);
    return (_files[pid] = Completer<File>()).future;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path.replaceFirst(RegExp('^/'), '');
    final id = _next++;
    final response = (_responses[id] = Completer<Map<String, dynamic>>());
    await _channel.sendMessage({'t': 'get', 'id': id, 'path': path});
    final res = await response.future.timeout(timeout);
    final status = res['status'];
    final pid = res['pid'];
    if (status != 200 || pid is! int) {
      return http.StreamedResponse(
        const Stream.empty(),
        status is int ? status : 500,
        request: request,
      );
    }
    final file = await _file(pid).timeout(timeout);
    final size = await file.length();
    final stream = file.openRead().transform<List<int>>(
      StreamTransformer.fromHandlers(
        handleDone: (sink) {
          sink.close();
          file.delete().ignore();
        },
      ),
    );
    return http.StreamedResponse(
      stream,
      200,
      contentLength: size,
      request: request,
    );
  }

  Future<LocalSource?> connect() async {
    try {
      final res = await get(baseUrl.resolve('rizma/inventory.json'));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return LocalSource(
        baseUrl: baseUrl,
        client: this,
        grades: {for (final g in json['grades'] as List) g as int},
        blobs: {
          for (final b in json['blobs'] as List)
            if (b is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(b)) b,
        },
        idleTimeout: timeout,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void close() {
    for (final s in _subs) {
      s.cancel();
    }
    super.close();
  }
}
