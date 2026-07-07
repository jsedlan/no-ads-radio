import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

enum PlaybackStatus { idle, loading, playing, paused, error }

class NowPlayingMetadata {
  const NowPlayingMetadata({
    this.title,
    this.url,
    this.stationName,
    this.genre,
  });

  final String? title;
  final String? url;
  final String? stationName;
  final String? genre;

  String? get displayTitle {
    final value = title?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.status,
    this.message,
    this.nowPlaying,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
  });

  const PlaybackSnapshot.idle() : this(status: PlaybackStatus.idle);

  final PlaybackStatus status;
  final String? message;
  final NowPlayingMetadata? nowPlaying;
  final Duration position;
  final Duration bufferedPosition;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isLoading => status == PlaybackStatus.loading;
  bool get isPaused => status == PlaybackStatus.paused;
  bool get hasError => status == PlaybackStatus.error;
}

abstract class AudioEngine {
  ValueListenable<PlaybackSnapshot> get snapshot;

  Future<void> playStream(
    String url, {
    Map<String, String>? headers,
    PlaybackMediaMetadata? metadata,
  });

  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

class PlaybackMediaMetadata {
  const PlaybackMediaMetadata({
    required this.id,
    required this.title,
    this.album,
    this.artUri,
  });

  final String id;
  final String title;
  final String? album;
  final Uri? artUri;
}

class JustAudioEngine implements AudioEngine {
  JustAudioEngine() {
    _subscriptions.add(_player.playerStateStream.listen(_handlePlayerState));
    _subscriptions.add(_player.playingStream.listen(_handlePlayingChanged));
    _subscriptions.add(_player.positionStream.listen(_handlePositionChanged));
    _subscriptions.add(
      _player.androidAudioSessionIdStream.listen(_handleAudioSessionChanged),
    );
    _subscriptions.add(_player.icyMetadataStream.listen(_handleIcyMetadata));
    _subscriptions.add(
      _player.playbackEventStream.listen(
        _handlePlaybackEvent,
        onError: _handlePlaybackEventError,
      ),
    );
  }

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<PlaybackSnapshot> _snapshot =
      ValueNotifier<PlaybackSnapshot>(const PlaybackSnapshot.idle());
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  String? _currentUrl;
  static const String _streamEndedMessage = 'Live stream ended unexpectedly.';

  @override
  ValueListenable<PlaybackSnapshot> get snapshot => _snapshot;

  @override
  Future<void> playStream(
    String url, {
    Map<String, String>? headers,
    PlaybackMediaMetadata? metadata,
  }) async {
    _currentUrl = url;
    _snapshot.value = const PlaybackSnapshot(status: PlaybackStatus.loading);
    _log(
      'playStream start url=$url headers=${headers == null ? 'none' : headers.keys.join(',')}',
    );

    try {
      await _player.setVolume(1.0);
      _log('setVolume complete');
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          headers: headers,
          tag: metadata == null
              ? null
              : MediaItem(
                  id: metadata.id,
                  title: metadata.title,
                  album: metadata.album,
                  artUri: metadata.artUri,
                ),
        ),
      );
      _log('setUrl complete');
      await _player.play();
      _log('play invoked');
    } on PlayerException catch (error) {
      _log('PlayerException code=${error.code} message=${error.message}');
      _snapshot.value = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: error.message,
        position: _snapshot.value.position,
        bufferedPosition: _snapshot.value.bufferedPosition,
      );
    } on PlayerInterruptedException {
      _log('PlayerInterruptedException while starting playback');
      _snapshot.value = const PlaybackSnapshot(status: PlaybackStatus.paused);
    } catch (error) {
      _log('Unexpected error during playStream: $error');
      _snapshot.value = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: error.toString(),
        position: _snapshot.value.position,
        bufferedPosition: _snapshot.value.bufferedPosition,
      );
    }
  }

  @override
  Future<void> resume() {
    _log('resume requested');
    return _player.play();
  }

  @override
  Future<void> pause() {
    _log('pause requested');
    return _player.pause();
  }

  @override
  Future<void> stop() async {
    _log('stop requested');
    await _player.stop();
    _currentUrl = null;
    _snapshot.value = const PlaybackSnapshot.idle();
  }

  void _handlePlayerState(PlayerState state) {
    _log(
      'playerState playing=${state.playing} processing=${state.processingState.name}',
    );
    if (state.processingState == ProcessingState.completed) {
      _snapshot.value = PlaybackSnapshot(
        status: _currentUrl == null
            ? PlaybackStatus.paused
            : PlaybackStatus.error,
        message: _currentUrl == null ? null : _streamEndedMessage,
        nowPlaying: _snapshot.value.nowPlaying,
        position: _snapshot.value.position,
        bufferedPosition: _snapshot.value.bufferedPosition,
      );
      return;
    }

    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) {
      _snapshot.value = PlaybackSnapshot(
        status: PlaybackStatus.loading,
        nowPlaying: _snapshot.value.nowPlaying,
        position: _snapshot.value.position,
        bufferedPosition: _snapshot.value.bufferedPosition,
      );
      return;
    }

    if (state.playing) {
      _snapshot.value = PlaybackSnapshot(
        status: PlaybackStatus.playing,
        nowPlaying: _snapshot.value.nowPlaying,
        position: _snapshot.value.position,
        bufferedPosition: _snapshot.value.bufferedPosition,
      );
      return;
    }

    if (state.processingState == ProcessingState.idle) {
      _snapshot.value = const PlaybackSnapshot.idle();
      return;
    }

    _snapshot.value = PlaybackSnapshot(
      status: PlaybackStatus.paused,
      nowPlaying: _snapshot.value.nowPlaying,
      position: _snapshot.value.position,
      bufferedPosition: _snapshot.value.bufferedPosition,
    );
  }

  @override
  Future<void> dispose() async {
    _log('dispose requested');
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
  }

  void _handlePlaybackEvent(PlaybackEvent event) {
    _log(
      'playbackEvent buffered=${event.bufferedPosition.inMilliseconds}ms '
      'duration=${event.duration?.inMilliseconds ?? -1}ms '
      'index=${event.currentIndex} '
      'eventPosition=${event.updatePosition.inMilliseconds}ms',
    );
    _snapshot.value = PlaybackSnapshot(
      status: _snapshot.value.status,
      message: _snapshot.value.message,
      nowPlaying: _snapshot.value.nowPlaying,
      position: _snapshot.value.position,
      bufferedPosition: event.bufferedPosition,
    );
  }

  void _handlePlaybackEventError(Object error, StackTrace stackTrace) {
    _log('playbackEvent error: $error');
    _snapshot.value = PlaybackSnapshot(
      status: PlaybackStatus.error,
      message: error.toString(),
      nowPlaying: _snapshot.value.nowPlaying,
      position: _snapshot.value.position,
      bufferedPosition: _snapshot.value.bufferedPosition,
    );
  }

  void _handlePlayingChanged(bool playing) {
    _log('playingStream value=$playing');
  }

  void _handlePositionChanged(Duration position) {
    _log('positionStream value=${position.inMilliseconds}ms');
    _snapshot.value = PlaybackSnapshot(
      status: _snapshot.value.status,
      message: _snapshot.value.message,
      nowPlaying: _snapshot.value.nowPlaying,
      position: position,
      bufferedPosition: _snapshot.value.bufferedPosition,
    );
  }

  void _handleAudioSessionChanged(int? audioSessionId) {
    _log('androidAudioSessionIdStream value=${audioSessionId ?? 'null'}');
  }

  void _handleIcyMetadata(IcyMetadata? metadata) {
    final nextMetadata = NowPlayingMetadata(
      title: metadata?.info?.title,
      url: metadata?.info?.url,
      stationName: metadata?.headers?.name,
      genre: metadata?.headers?.genre,
    );
    _log(
      'icyMetadata title=${nextMetadata.title ?? 'null'} '
      'station=${nextMetadata.stationName ?? 'null'} '
      'genre=${nextMetadata.genre ?? 'null'}',
    );
    _snapshot.value = PlaybackSnapshot(
      status: _snapshot.value.status,
      message: _snapshot.value.message,
      position: _snapshot.value.position,
      bufferedPosition: _snapshot.value.bufferedPosition,
      nowPlaying:
          nextMetadata.displayTitle == null &&
              (nextMetadata.stationName?.trim().isEmpty ?? true) &&
              (nextMetadata.genre?.trim().isEmpty ?? true)
          ? null
          : nextMetadata,
    );
  }

  void _log(String message) {
    debugPrint(
      '[audio_engine ${DateTime.now().toIso8601String()}] '
      'url=${_currentUrl ?? 'none'} $message',
    );
  }
}
