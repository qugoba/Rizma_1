import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rizma/features/downloads/download_service.dart';

String shaOf(List<int> bytes) => sha256.convert(bytes).toString();

class FakeLesson {
  FakeLesson(
    this.id,
    this.version,
    this.files, {
    this.video,
    this.attachments = const [],
    this.format = 1,
  });

  final String id;
  final int version;
  final Map<String, List<int>> files;
  final List<int>? video;
  final List<List<int>> attachments;
  final int format;
}

class FakeContentServer {
  FakeContentServer._(this._keyPair, this.publicKey);

  static Future<FakeContentServer> create() async {
    final pair = await Ed25519().newKeyPair();
    final pub = await pair.extractPublicKey();
    return FakeContentServer._(pair, pub.bytes);
  }

  final SimpleKeyPair _keyPair;
  final List<int> publicKey;

  final blobs = <String, List<int>>{};
  final _manifests = <int, (List<int>, List<int>)>{};

  final requests = <(String path, String? range)>[];

  var blobBytesSent = 0;

  bool offline = false;

  bool ignoreRange = false;

  final cutAfter = <String, int>{};

  final corrupt = <String, List<int>>{};

  final baseUrl = Uri.parse('https://content.test/');

  ContentConfig config({List<List<int>>? keys}) =>
      ContentConfig(baseUrl: baseUrl, publicKeys: keys ?? [publicKey]);

  Future<String> publish(
    int grade,
    int sequence,
    List<FakeLesson> lessons, {
    List<int>? catalog,
    Map<String, Object?>? override,
  }) async {
    Map<String, Object> blob(List<int> bytes) {
      final sha = shaOf(bytes);
      blobs[sha] = bytes;
      return {'sha256': sha, 'size': bytes.length};
    }

    final json = <String, Object?>{
      'format': 1,
      'grade': grade,
      'sequence': sequence,
      'published_at': '2026-10-26T10:00:00Z',
      if (catalog != null) 'catalog': blob(catalog),
      'lessons': [
        for (final l in lessons)
          {
            'id': l.id,
            'version': l.version,
            'content_format': l.format,
            'files': [
              for (final e in l.files.entries)
                {'path': e.key, ...blob(e.value)},
            ],
            if (l.video != null) 'video': {...blob(l.video!), 'minutes': 4},
            if (l.attachments.isNotEmpty)
              'attachments': [for (final a in l.attachments) blob(a)],
          },
      ],
      ...?override,
    };
    final text = jsonEncode(json);
    await sign(grade, utf8.encode(text));
    return text;
  }

  Future<void> sign(int grade, List<int> body, {SimpleKeyPair? keyPair}) async {
    final sig = await Ed25519().sign(body, keyPair: keyPair ?? _keyPair);
    _manifests[grade] = (body, sig.bytes);
  }

  void tamper(int grade, List<int> body) {
    final current = _manifests[grade]!;
    _manifests[grade] = (body, current.$2);
  }

  late final http.Client client = MockClient.streaming((req, _) async {
    final path = req.url.path;
    final range = req.headers['Range'];
    requests.add((path, range));
    if (offline) throw http.ClientException('no internet', req.url);

    final grade = RegExp(
      r'^/v1/grades/(\d+)/manifest\.json(\.sig)?$',
    ).firstMatch(path);
    if (grade != null) {
      final m = _manifests[int.parse(grade.group(1)!)];
      if (m == null) return _bytes(req, [], 404);
      return _bytes(req, grade.group(2) == null ? m.$1 : m.$2, 200);
    }

    final blob = RegExp(r'^/v1/blobs/([0-9a-f]{64})$').firstMatch(path);
    if (blob == null) return _bytes(req, [], 404);
    final sha = blob.group(1)!;
    final data = corrupt[sha] ?? blobs[sha];
    if (data == null) return _bytes(req, [], 404);

    var start = 0;
    final match = RegExp(r'^bytes=(\d+)-$').firstMatch(range ?? '');
    if (match != null && !ignoreRange) {
      start = int.parse(match.group(1)!);
      if (start >= data.length) return _bytes(req, [], 416);
    }
    final body = data.sublist(start);
    final cut = cutAfter.remove(sha);
    final controller = StreamController<List<int>>();
    () async {
      const chunk = 4096;
      var sent = 0;
      for (var i = 0; i < body.length; i += chunk) {
        final part = body.sublist(i, (i + chunk).clamp(0, body.length));
        if (cut != null && sent + part.length > cut) {
          final keep = cut - sent;
          if (keep > 0) controller.add(part.sublist(0, keep));
          blobBytesSent += keep;
          controller.addError(http.ClientException('connection reset'));
          await controller.close();
          return;
        }
        controller.add(part);
        sent += part.length;
        blobBytesSent += part.length;
        await Future<void>.delayed(Duration.zero);
      }
      await controller.close();
    }();
    final partial = start > 0;
    return http.StreamedResponse(
      controller.stream,
      partial ? 206 : 200,
      contentLength: body.length,
      request: req,
      headers: {
        if (partial)
          'content-range': 'bytes $start-${data.length - 1}/${data.length}',
      },
    );
  });

  static http.StreamedResponse _bytes(
    http.BaseRequest req,
    List<int> bytes,
    int status,
  ) => http.StreamedResponse(
    Stream.value(bytes),
    status,
    contentLength: bytes.length,
    request: req,
  );
}
