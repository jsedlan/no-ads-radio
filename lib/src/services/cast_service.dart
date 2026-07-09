import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

enum CastConnectionStatus { unavailable, disconnected, connecting, connected }

enum CastPlaybackStatus { idle, loading, playing, paused, error }

class CastDevice {
  const CastDevice({required this.id, required this.name, this.modelName});

  final String id;
  final String name;
  final String? modelName;
}

class CastSnapshot {
  const CastSnapshot({
    required this.connectionStatus,
    this.playbackStatus = CastPlaybackStatus.idle,
    this.devices = const <CastDevice>[],
    this.deviceName,
    this.message,
  });

  const CastSnapshot.unavailable()
    : this(connectionStatus: CastConnectionStatus.unavailable);

  final CastConnectionStatus connectionStatus;
  final CastPlaybackStatus playbackStatus;
  final List<CastDevice> devices;
  final String? deviceName;
  final String? message;

  bool get isAvailable => connectionStatus != CastConnectionStatus.unavailable;
  bool get isConnected => connectionStatus == CastConnectionStatus.connected;
}

class CastMedia {
  const CastMedia({
    required this.url,
    required this.title,
    required this.contentType,
    this.album,
    this.artUri,
  });

  final String url;
  final String title;
  final String contentType;
  final String? album;
  final Uri? artUri;
}

abstract class CastService {
  ValueListenable<CastSnapshot> get snapshot;

  Future<void> initialize();
  Future<void> startDiscovery();
  Future<void> stopDiscovery();
  Future<void> connect(CastDevice device);
  Future<void> disconnect();
  Future<void> load(CastMedia media);
  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

class DisabledCastService implements CastService {
  DisabledCastService();

  final ValueNotifier<CastSnapshot> _snapshot = ValueNotifier<CastSnapshot>(
    const CastSnapshot.unavailable(),
  );

  @override
  ValueListenable<CastSnapshot> get snapshot => _snapshot;

  @override
  Future<void> connect(CastDevice device) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {
    _snapshot.dispose();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> load(CastMedia media) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> startDiscovery() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> stopDiscovery() async {}
}

class GoogleCastService implements CastService {
  static const Duration _sessionTimeout = Duration(seconds: 20);
  static const Duration _mediaLoadTimeout = Duration(seconds: 20);
  static const Duration _autoplayGracePeriod = Duration(seconds: 3);

  final ValueNotifier<CastSnapshot> _snapshot = ValueNotifier<CastSnapshot>(
    const CastSnapshot.unavailable(),
  );
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  final Map<String, GoogleCastDevice> _nativeDevices =
      <String, GoogleCastDevice>{};
  GoggleCastMediaStatus? _latestMediaStatus;

  @override
  ValueListenable<CastSnapshot> get snapshot => _snapshot;

  @override
  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
    final options = Platform.isIOS
        ? IOSGoogleCastOptions(
            GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
            suspendSessionsWhenBackgrounded: false,
          )
        : GoogleCastOptionsAndroid(appId: appId);
    final initialized = await GoogleCastContext.instance
        .setSharedInstanceWithOptions(options);
    if (!initialized) {
      throw StateError('Google Cast could not be initialized.');
    }

    _snapshot.value = const CastSnapshot(
      connectionStatus: CastConnectionStatus.disconnected,
    );
    _subscriptions.add(
      GoogleCastDiscoveryManager.instance.devicesStream.listen(_handleDevices),
    );
    _subscriptions.add(
      GoogleCastSessionManager.instance.currentSessionStream.listen(
        _handleSession,
      ),
    );
    _subscriptions.add(
      GoogleCastRemoteMediaClient.instance.mediaStatusStream.listen(
        _handleMediaStatus,
      ),
    );
  }

  @override
  Future<void> startDiscovery() =>
      GoogleCastDiscoveryManager.instance.startDiscovery();

  @override
  Future<void> stopDiscovery() =>
      GoogleCastDiscoveryManager.instance.stopDiscovery();

  @override
  Future<void> connect(CastDevice device) async {
    final nativeDevice = _nativeDevices[device.id];
    if (nativeDevice == null) {
      throw StateError('Cast device is no longer available.');
    }
    _update(
      connectionStatus: CastConnectionStatus.connecting,
      deviceName: device.name,
    );
    final connected = await GoogleCastSessionManager.instance
        .startSessionWithDevice(nativeDevice);
    if (!connected) {
      _update(
        connectionStatus: CastConnectionStatus.disconnected,
        message: 'Could not connect to ${device.name}.',
      );
      throw StateError('Could not connect to ${device.name}.');
    }

    try {
      await GoogleCastSessionManager.instance.currentSessionStream
          .firstWhere(
            (session) =>
                session?.connectionState == GoogleCastConnectState.connected &&
                session?.device?.deviceID == nativeDevice.deviceID,
          )
          .timeout(_sessionTimeout);
    } on TimeoutException {
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
      _update(
        connectionStatus: CastConnectionStatus.disconnected,
        playbackStatus: CastPlaybackStatus.idle,
        message: 'Timed out connecting to ${device.name}.',
        clearDeviceName: true,
      );
      throw TimeoutException('Timed out connecting to ${device.name}.');
    }
  }

  @override
  Future<void> disconnect() async {
    await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    _update(
      connectionStatus: CastConnectionStatus.disconnected,
      playbackStatus: CastPlaybackStatus.idle,
      clearDeviceName: true,
    );
  }

  @override
  Future<void> load(CastMedia media) async {
    if (!_snapshot.value.isConnected) {
      throw StateError('Connect to a Cast device first.');
    }
    _update(playbackStatus: CastPlaybackStatus.loading);

    final images = media.artUri == null
        ? null
        : <GoogleCastImage>[GoogleCastImage(url: media.artUri!)];
    final metadata = GoogleCastMusicMediaMetadata(
      title: media.title,
      albumName: media.album,
      images: images,
    );
    final uri = Uri.parse(media.url);
    final mediaInfo = Platform.isIOS
        ? GoogleCastMediaInformationIOS(
            contentId: media.url,
            contentUrl: uri,
            streamType: CastMediaStreamType.live,
            contentType: media.contentType,
            metadata: metadata,
          )
        : GoogleCastMediaInformationAndroid(
            contentId: media.url,
            contentUrl: uri,
            streamType: CastMediaStreamType.live,
            contentType: media.contentType,
            metadata: metadata,
          );

    await GoogleCastRemoteMediaClient.instance.loadMedia(mediaInfo);
    if (_isRemotePlaybackActive(media.url)) {
      return;
    }
    try {
      await _waitForRemotePlayback(media.url, timeout: _autoplayGracePeriod);
    } on TimeoutException {
      await GoogleCastRemoteMediaClient.instance.play();
      if (_isRemotePlaybackActive(media.url)) {
        return;
      }
      try {
        await _waitForRemotePlayback(
          media.url,
          timeout: _mediaLoadTimeout - _autoplayGracePeriod,
        );
      } on TimeoutException {
        _log('remote playback confirmation timed out; leaving Cast session active');
        _update(
          playbackStatus: CastPlaybackStatus.playing,
          message: 'Cast playback started, but status confirmation timed out.',
        );
      }
    }
  }

  Future<void> _waitForRemotePlayback(
    String contentId, {
    required Duration timeout,
  }) async {
    if (_isRemotePlaybackActive(contentId)) {
      return;
    }
    await GoogleCastRemoteMediaClient.instance.mediaStatusStream
        .firstWhere(
          (status) =>
              status?.mediaInformation?.contentId == contentId &&
              status?.playerState == CastMediaPlayerState.playing,
        )
        .timeout(timeout);
  }

  bool _isRemotePlaybackActive(String contentId) {
    final status = _latestMediaStatus;
    return status?.mediaInformation?.contentId == contentId &&
        status?.playerState == CastMediaPlayerState.playing;
  }

  @override
  Future<void> resume() => GoogleCastRemoteMediaClient.instance.play();

  @override
  Future<void> pause() => GoogleCastRemoteMediaClient.instance.pause();

  @override
  Future<void> stop() => GoogleCastRemoteMediaClient.instance.stop();

  void _handleDevices(List<GoogleCastDevice> devices) {
    _nativeDevices
      ..clear()
      ..addEntries(devices.map((device) => MapEntry(device.deviceID, device)));
    _update(
      devices: devices
          .map(
            (device) => CastDevice(
              id: device.deviceID,
              name: device.friendlyName,
              modelName: device.modelName,
            ),
          )
          .toList(growable: false),
    );
  }

  void _handleSession(GoogleCastSession? session) {
    _log(
      'session state=${session?.connectionState.name ?? 'none'} '
      'device=${session?.device?.friendlyName ?? 'none'}',
    );
    final connectionStatus = switch (session?.connectionState) {
      GoogleCastConnectState.connecting => CastConnectionStatus.connecting,
      GoogleCastConnectState.connected => CastConnectionStatus.connected,
      GoogleCastConnectState.disconnecting => CastConnectionStatus.connecting,
      GoogleCastConnectState.disconnected ||
      null => CastConnectionStatus.disconnected,
    };
    _update(
      connectionStatus: connectionStatus,
      playbackStatus: connectionStatus == CastConnectionStatus.connected
          ? _snapshot.value.playbackStatus
          : CastPlaybackStatus.idle,
      deviceName: session?.device?.friendlyName,
      clearDeviceName: session == null,
    );
  }

  void _handleMediaStatus(GoggleCastMediaStatus? status) {
    if (status == null) {
      return;
    }
    _latestMediaStatus = status;
    _log(
      'media status state=${status.playerState.name} '
      'idleReason=${status.idleReason?.name ?? 'none'} '
      'contentId=${status.mediaInformation?.contentId ?? 'none'}',
    );
    final playbackStatus = switch (status.playerState) {
      CastMediaPlayerState.playing => CastPlaybackStatus.playing,
      CastMediaPlayerState.paused => CastPlaybackStatus.paused,
      CastMediaPlayerState.buffering ||
      CastMediaPlayerState.loading => CastPlaybackStatus.loading,
      CastMediaPlayerState.idle ||
      CastMediaPlayerState.unknown => CastPlaybackStatus.idle,
    };
    _update(playbackStatus: playbackStatus);
  }

  void _update({
    CastConnectionStatus? connectionStatus,
    CastPlaybackStatus? playbackStatus,
    List<CastDevice>? devices,
    String? deviceName,
    String? message,
    bool clearDeviceName = false,
  }) {
    final previous = _snapshot.value;
    _snapshot.value = CastSnapshot(
      connectionStatus: connectionStatus ?? previous.connectionStatus,
      playbackStatus: playbackStatus ?? previous.playbackStatus,
      devices: devices ?? previous.devices,
      deviceName: clearDeviceName ? null : deviceName ?? previous.deviceName,
      message: message,
    );
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _snapshot.dispose();
  }

  void _log(String message) {
    debugPrint(
      '[cast_service ${DateTime.now().toIso8601String()}] $message',
    );
  }
}
