import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

class BlobStore {
  BlobStore(this.root);

  final Directory root;

  Directory get _dir => Directory('${root.path}/blobs');

  File blob(String sha256) => File('${_dir.path}/$sha256');
  File _part(String sha256) => File('${_dir.path}/$sha256.part');

  Future<void> _ensureDir() => _dir.create(recursive: true);

  Future<int> partLength(String sha256) async {
    final f = _part(sha256);
    return await f.exists() ? f.length() : 0;
  }

  Future<IOSink> openPart(String sha256, {required bool append}) async {
    await _ensureDir();
    return _part(
      sha256,
    ).openWrite(mode: append ? FileMode.writeOnlyAppend : FileMode.writeOnly);
  }

  Future<String> partSha256(String sha256) async {
    final digest = await sha256Stream(_part(sha256).openRead());
    return digest;
  }

  static Future<String> sha256Stream(Stream<List<int>> bytes) async {
    final out = _DigestSink();
    final input = sha256.startChunkedConversion(out);
    await for (final chunk in bytes) {
      input.add(chunk);
    }
    input.close();
    return out.value.toString();
  }

  Future<void> promote(String sha256) async {
    await _part(sha256).rename(blob(sha256).path);
  }

  Future<void> writeBlob(String sha256, List<int> bytes) async {
    await _ensureDir();
    await _part(sha256).writeAsBytes(bytes, flush: true);
    await promote(sha256);
  }

  Future<void> deletePart(String sha256) => _deleteIfExists(_part(sha256));

  Future<void> deleteBlob(String sha256) => _deleteIfExists(blob(sha256));

  Future<bool> hasBlob(String sha256) => blob(sha256).exists();

  Future<String> readString(String sha256) =>
      blob(sha256).readAsString(encoding: utf8);

  Future<void> deleteStrayParts(Set<String> keep) async {
    if (!await _dir.exists()) return;
    await for (final e in _dir.list()) {
      final name = e.uri.pathSegments.last;
      if (e is File && name.endsWith('.part')) {
        final sha = name.substring(0, name.length - '.part'.length);
        if (!keep.contains(sha)) await _deleteIfExists(e);
      }
    }
  }

  static Future<void> _deleteIfExists(File f) async {
    if (await f.exists()) await f.delete();
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
