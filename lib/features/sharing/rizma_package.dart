import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class PackEntry {
  const PackEntry({required this.path, required this.size, required this.open});

  PackEntry.bytes(this.path, List<int> bytes)
    : size = bytes.length,
      open = (() => Stream.value(bytes));

  PackEntry.file(this.path, File file, this.size)
    : open = (() => file.openRead());

  final String path;
  final int size;
  final Stream<List<int>> Function() open;
}

abstract final class RizmaPackage {
  static final magic = ascii.encode('RIZMA-PACK\n');
  static const format = 1;
  static const extension = 'rizma';

  static const maxIndexBytes = 4 * 1024 * 1024;
  static const maxEntries = 20000;

  static final _manifestPath = RegExp(
    r'^v1/grades/([1-9]|1[0-2])/manifest\.json(\.sig)?$',
  );
  static final _blobPath = RegExp(r'^v1/blobs/([0-9a-f]{64})$');

  static bool validPath(String path) =>
      _manifestPath.hasMatch(path) || _blobPath.hasMatch(path);

  static List<int> _index(List<PackEntry> entries) {
    var offset = 0;
    return utf8.encode(
      jsonEncode({
        'format': format,
        'entries': [
          for (final e in entries)
            {
              'path': e.path,
              'offset': (offset += e.size) - e.size,
              'size': e.size,
            },
        ],
      }),
    );
  }

  static int sizeOf(List<PackEntry> entries) =>
      magic.length +
      4 +
      _index(entries).length +
      entries.fold(0, (s, e) => s + e.size);

  static Future<void> write(
    File out,
    List<PackEntry> entries, {
    void Function(int written)? onProgress,
  }) async {
    for (final e in entries) {
      if (!validPath(e.path)) throw ArgumentError('bad path ${e.path}');
    }
    final index = _index(entries);
    final sink = out.openWrite();
    try {
      final header = ByteData(4)..setUint32(0, index.length);
      sink
        ..add(magic)
        ..add(header.buffer.asUint8List())
        ..add(index);
      var written = magic.length + 4 + index.length;
      for (final e in entries) {
        var left = e.size;
        await for (final chunk in e.open()) {
          if (chunk.length > left) {
            throw StateError('${e.path} is larger than its size');
          }
          sink.add(chunk);
          left -= chunk.length;
          written += chunk.length;
          onProgress?.call(written);
        }
        if (left != 0) throw StateError('${e.path} is shorter than its size');
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }
}

class PackageReader {
  PackageReader._(this.file, this._entries, this._dataStart);

  final File file;
  final Map<String, (int offset, int size)> _entries;
  final int _dataStart;

  static Future<PackageReader> open(File file) async {
    final raf = await file.open();
    try {
      final length = await raf.length();
      final magic = RizmaPackage.magic;
      if (length < magic.length + 4) {
        throw const FormatException('rizma: too short');
      }
      final head = await raf.read(magic.length + 4);
      for (var i = 0; i < magic.length; i++) {
        if (head[i] != magic[i]) {
          throw const FormatException('rizma: not a package');
        }
      }
      final indexLength = ByteData.sublistView(head, magic.length).getUint32(0);
      final dataStart = magic.length + 4 + indexLength;
      if (indexLength > RizmaPackage.maxIndexBytes || dataStart > length) {
        throw const FormatException('rizma: bad index length');
      }
      final Object? index;
      try {
        index = jsonDecode(utf8.decode(await raf.read(indexLength)));
      } on FormatException {
        throw const FormatException('rizma: index is not JSON');
      }
      if (index is! Map<String, dynamic> ||
          index['format'] is! int ||
          (index['format'] as int) > RizmaPackage.format ||
          index['entries'] is! List) {
        throw const FormatException('rizma: bad index');
      }
      final raw = index['entries'] as List;
      if (raw.length > RizmaPackage.maxEntries) {
        throw const FormatException('rizma: too many entries');
      }
      final entries = <String, (int, int)>{};
      for (final e in raw) {
        if (e is! Map<String, dynamic>) {
          throw const FormatException('rizma: bad entry');
        }
        final path = e['path'];
        final offset = e['offset'];
        final size = e['size'];
        if (path is! String ||
            !RizmaPackage.validPath(path) ||
            offset is! int ||
            size is! int ||
            offset < 0 ||
            size < 0 ||
            dataStart + offset + size > length ||
            entries.containsKey(path)) {
          throw const FormatException('rizma: bad entry');
        }
        entries[path] = (offset, size);
      }
      return PackageReader._(file, entries, dataStart);
    } finally {
      await raf.close();
    }
  }

  Set<int> get grades => {
    for (final p in _entries.keys)
      if (RizmaPackage._manifestPath.firstMatch(p) case final m?
          when m.group(2) == null && _entries.containsKey('$p.sig'))
        int.parse(m.group(1)!),
  };

  Set<String> get blobs => {
    for (final p in _entries.keys)
      if (RizmaPackage._blobPath.firstMatch(p) case final m?) m.group(1)!,
  };

  int? sizeOf(String path) => _entries[path]?.$2;

  Stream<List<int>>? read(String path, {int from = 0}) {
    final e = _entries[path];
    if (e == null) return null;
    final (offset, size) = e;
    return file.openRead(
      _dataStart + offset + from,
      _dataStart + offset + size,
    );
  }
}

class PackageClient extends http.BaseClient {
  PackageClient(this.reader);

  final PackageReader reader;

  static final baseUrl = Uri.parse('http://rizma-package.local/');

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path.replaceFirst(RegExp('^/'), '');
    final size = reader.sizeOf(path);
    if (request.method != 'GET' || size == null) {
      return http.StreamedResponse(const Stream.empty(), 404, request: request);
    }
    final range = RegExp(
      r'^bytes=(\d+)-$',
    ).firstMatch(request.headers['Range'] ?? request.headers['range'] ?? '');
    final from = range == null ? 0 : int.parse(range.group(1)!);
    if (from > 0 && from >= size) {
      return http.StreamedResponse(const Stream.empty(), 416, request: request);
    }
    return http.StreamedResponse(
      reader.read(path, from: from)!,
      from > 0 ? 206 : 200,
      contentLength: size - from,
      request: request,
      headers: {if (from > 0) 'content-range': 'bytes $from-${size - 1}/$size'},
    );
  }
}
