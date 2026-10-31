import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import 'nearby_protocol.dart';
import 'peer.dart';

class NearbyPeer {
  const NearbyPeer({required this.endpointId, required this.code});

  final String endpointId;
  final String code;
}

enum NearbyProblem {
  permission,

  locationOff,

  unsupported,
}

class NearbyService {
  NearbyService(this._temp);

  static const serviceId = 'com.rizma.rizma.share';
  static const _strategy = Strategy.P2P_STAR;

  final Future<Directory> Function() _temp;
  late final _nearby = Nearby();
  final _channels = <String, _PluginChannel>{};

  Future<NearbyProblem?> prepare() async {
    final sdk = await _sdk();
    final permissions = <Permission>[
      if (sdk >= 31) ...[
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ],
      if (sdk >= 33) Permission.nearbyWifiDevices,
      if (sdk < 33) Permission.location,
    ];
    final results = await permissions.request();
    if (results.values.any((s) => !s.isGranted && !s.isLimited)) {
      return NearbyProblem.permission;
    }
    if (sdk < 33 && !await Permission.location.serviceStatus.isEnabled) {
      return NearbyProblem.locationOff;
    }
    return null;
  }

  static Future<int> _sdk() async => await WifiBinding.sdkInt() ?? 33;

  Future<NearbyProblem?> advertise(
    String code, {
    required void Function(NearbyChannel channel) onPeer,
    required void Function(NearbyChannel channel) onGone,
  }) async {
    try {
      final ok = await _nearby.startAdvertising(
        code,
        _strategy,
        serviceId: serviceId,
        onConnectionInitiated: (id, _) => _accept(id),
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) onPeer(_channel(id));
        },
        onDisconnected: (id) {
          final c = _channels.remove(id);
          if (c != null) {
            onGone(c);
            c._closeStreams();
          }
        },
      );
      return ok ? null : NearbyProblem.unsupported;
    } catch (_) {
      return NearbyProblem.unsupported;
    }
  }

  Stream<NearbyPeer> discover() {
    late final StreamController<NearbyPeer> out;
    out = StreamController<NearbyPeer>(
      onListen: () async {
        try {
          final ok = await _nearby.startDiscovery(
            'rizma',
            _strategy,
            serviceId: serviceId,
            onEndpointFound: (id, name, service) {
              if (service == serviceId && !out.isClosed) {
                out.add(NearbyPeer(endpointId: id, code: name));
              }
            },
            onEndpointLost: (_) {},
          );
          if (!ok && !out.isClosed) {
            out.addError(NearbyProblem.unsupported);
          }
        } catch (_) {
          if (!out.isClosed) out.addError(NearbyProblem.unsupported);
        }
      },
      onCancel: () async {
        try {
          await _nearby.stopDiscovery();
        } catch (_) {}
      },
    );
    return out.stream;
  }

  Future<NearbyChannel?> connect(NearbyPeer peer) async {
    final done = Completer<NearbyChannel?>();
    try {
      await _nearby.requestConnection(
        'rizma',
        peer.endpointId,
        onConnectionInitiated: (id, _) => _accept(id),
        onConnectionResult: (id, status) {
          if (done.isCompleted) return;
          done.complete(status == Status.CONNECTED ? _channel(id) : null);
        },
        onDisconnected: (id) {
          _channels.remove(id)?._closeStreams();
          if (!done.isCompleted) done.complete(null);
        },
      );
    } catch (_) {
      return null;
    }
    return done.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => null,
    );
  }

  Future<void> stop() async {
    for (final f in [
      _nearby.stopAdvertising,
      _nearby.stopDiscovery,
      _nearby.stopAllEndpoints,
    ]) {
      try {
        await f();
      } catch (_) {}
    }
    for (final c in _channels.values) {
      c._closeStreams();
    }
    _channels.clear();
  }

  Future<void> _accept(String endpointId) async {
    try {
      await _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: _onPayload,
        onPayloadTransferUpdate: _onUpdate,
      );
    } catch (_) {}
  }

  _PluginChannel _channel(String endpointId) =>
      _channels[endpointId] ??= _PluginChannel(this, endpointId);

  void _onPayload(String endpointId, Payload payload) {
    final c = _channel(endpointId);
    switch (payload.type) {
      case PayloadType.BYTES:
        try {
          final json = jsonDecode(utf8.decode(payload.bytes!));
          if (json is Map<String, dynamic>) c._messages.add(json);
        } catch (_) {}
      case PayloadType.FILE:
        // ignore: deprecated_member_use
        c._uris[payload.id] = payload.uri ?? payload.filePath;
        if (c._succeeded.remove(payload.id)) c._finish(payload.id);
      default:
        break;
    }
  }

  void _onUpdate(String endpointId, PayloadTransferUpdate u) {
    final c = _channels[endpointId];
    if (c == null) return;
    if (u.status == PayloadStatus.IN_PROGRESS) {
      c._progress.add((u.id, u.bytesTransferred, u.totalBytes));
    } else if (u.status == PayloadStatus.SUCCESS) {
      if (c._uris.containsKey(u.id)) {
        c._finish(u.id);
      } else {
        c._succeeded.add(u.id);
      }
    }
  }
}

class _PluginChannel implements NearbyChannel {
  _PluginChannel(this._service, this._endpointId);

  final NearbyService _service;
  final String _endpointId;
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  final _files = StreamController<(int, File)>.broadcast();
  final _progress = StreamController<(int, int, int)>.broadcast();
  final _uris = <int, String?>{};
  final _succeeded = <int>{};

  @override
  Stream<Map<String, dynamic>> get messages => _messages.stream;
  @override
  Stream<(int, File)> get files => _files.stream;
  @override
  Stream<(int, int, int)> get progress => _progress.stream;

  Future<void> _finish(int payloadId) async {
    final uri = _uris.remove(payloadId);
    if (uri == null) return;
    final dest = File('${(await _service._temp()).path}/nearby-in-$payloadId');
    try {
      final ok = await _service._nearby.copyFileAndDeleteOriginal(
        uri,
        dest.path,
      );
      if (ok && !_files.isClosed) _files.add((payloadId, dest));
    } catch (_) {}
  }

  @override
  Future<void> sendMessage(Map<String, Object?> message) =>
      _service._nearby.sendBytesPayload(
        _endpointId,
        Uint8List.fromList(utf8.encode(jsonEncode(message))),
      );

  @override
  Future<int> sendFile(File file) =>
      _service._nearby.sendFilePayload(_endpointId, file.path);

  @override
  Future<void> close() async {
    try {
      await _service._nearby.disconnectFromEndpoint(_endpointId);
    } catch (_) {}
    _service._channels.remove(_endpointId);
    _closeStreams();
  }

  void _closeStreams() {
    _messages.close();
    _files.close();
    _progress.close();
  }
}
