import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:no_ads_radio/src/app.dart';
import 'package:no_ads_radio/src/audio/audio_engine.dart';
import 'package:no_ads_radio/src/controllers/radio_app_controller.dart';
import 'package:no_ads_radio/src/models/radio_station.dart';
import 'package:no_ads_radio/src/models/search_query.dart';
import 'package:no_ads_radio/src/services/connectivity_service.dart';
import 'package:no_ads_radio/src/services/fallback_station_repository.dart';
import 'package:no_ads_radio/src/services/favorites_store.dart';
import 'package:no_ads_radio/src/services/settings_store.dart';
import 'package:no_ads_radio/src/services/station_repository.dart';

void main() {
  testWidgets('renders discover list and favorites flow', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Show station icon'), findsOneWidget);
  });

  test(
    'fallback repository uses later source when earlier one fails',
    () async {
      final repository = FallbackStationRepository(<StationRepository>[
        ThrowingStationRepository(),
        FakeStationRepository(),
      ]);

      final stations = await repository.fetchTopClicked(limit: 2);

      expect(stations, hasLength(2));
      expect(stations.first.displayName, 'Test Station 1');
    },
  );

  test('controller persists settings changes', () async {
    final settingsStore = InMemorySettingsStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    expect(controller.showStationIcon, isFalse);

    await controller.setShowStationIcon(true);

    final reloaded = await settingsStore.loadSettings();
    expect(reloaded.showStationIcon, isTrue);
  });

  testWidgets('shows offline badge when connectivity is down', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.offline(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
  });

  test(
    'controller marks playback stalled when position stops advancing',
    () async {
      final audioEngine = FakeAudioEngine();
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: audioEngine,
        connectivityService: FakeConnectivityService.online(),
        playbackStallThreshold: const Duration(milliseconds: 60),
        playbackStallPollInterval: const Duration(milliseconds: 10),
      );

      audioEngine.emitSnapshot(
        const PlaybackSnapshot(
          status: PlaybackStatus.playing,
          position: Duration.zero,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(controller.playbackStalled, isTrue);

      audioEngine.emitSnapshot(
        const PlaybackSnapshot(
          status: PlaybackStatus.playing,
          position: Duration(milliseconds: 500),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(controller.playbackStalled, isFalse);

      controller.dispose();
    },
  );

  test('sleep timer stops playback when it expires', () async {
    final audioEngine = FakeAudioEngine();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: audioEngine,
      connectivityService: FakeConnectivityService.online(),
    );
    final station = controller.discoverStations.first;

    await controller.playStation(station);
    controller.setSleepTimer(const Duration(seconds: 1));

    expect(controller.isSleepTimerActive, isTrue);
    expect(controller.currentStation, station);

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    expect(controller.isSleepTimerActive, isFalse);
    expect(controller.currentStation, isNull);
    expect(controller.playback.status, PlaybackStatus.idle);

    controller.dispose();
  });

  testWidgets('custom sleep timer accepts 60 minutes', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await controller.playStation(controller.discoverStations.first);
    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.timer_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '60');
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump();

    expect(controller.isSleepTimerActive, isTrue);
    expect(controller.sleepTimerRemaining.inMinutes, greaterThanOrEqualTo(59));

    controller.dispose();
  });
}

class FakeStationRepository implements StationRepository {
  @override
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12}) async {
    return _stations(limit);
  }

  @override
  Future<List<RadioStation>> fetchTopClicked({int limit = 12}) async {
    return _stations(limit);
  }

  @override
  Future<List<RadioStation>> fetchTopVoted({int limit = 12}) async {
    return _stations(limit);
  }

  @override
  Future<String> resolveStreamUrl(String stationUuid) async {
    return 'https://example.com/$stationUuid.mp3';
  }

  @override
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  }) async {
    return _stations(limit)
        .where(
          (station) =>
              query.name.trim().isEmpty ||
              station.displayName.toLowerCase().contains(
                query.name.toLowerCase(),
              ),
        )
        .toList(growable: false);
  }

  List<RadioStation> _stations(int limit) {
    return List<RadioStation>.generate(
      limit.clamp(0, 4),
      (index) => RadioStation(
        stationUuid: 'station-$index',
        name: 'Test Station ${index + 1}',
        url: 'https://example.com/$index',
        urlResolved: 'https://example.com/$index/stream',
        homepage: '',
        favicon: '',
        tags: 'test,rock',
        country: 'Serbia',
        countryCode: 'RS',
        state: 'Belgrade',
        language: 'english',
        codec: 'MP3',
        bitrate: 128,
        votes: 10,
        clickCount: 20,
        clickTrend: 2,
        lastCheckOk: true,
        hls: false,
      ),
      growable: false,
    );
  }
}

class InMemoryFavoritesStore implements FavoritesStore {
  Map<String, List<RadioStation>> _favorites =
      const <String, List<RadioStation>>{};

  @override
  Future<Map<String, List<RadioStation>>> loadFavorites() async => _favorites;

  @override
  Future<void> saveFavorites(
    Map<String, List<RadioStation>> stationsByCategory,
  ) async {
    _favorites = Map<String, List<RadioStation>>.unmodifiable(
      stationsByCategory.map(
        (category, stations) =>
            MapEntry(category, List<RadioStation>.unmodifiable(stations)),
      ),
    );
  }
}

class ThrowingStationRepository implements StationRepository {
  @override
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12}) async {
    throw Exception('offline');
  }

  @override
  Future<List<RadioStation>> fetchTopClicked({int limit = 12}) async {
    throw Exception('offline');
  }

  @override
  Future<List<RadioStation>> fetchTopVoted({int limit = 12}) async {
    throw Exception('offline');
  }

  @override
  Future<String> resolveStreamUrl(String stationUuid) async {
    throw Exception('offline');
  }

  @override
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  }) async {
    throw Exception('offline');
  }
}

class InMemorySettingsStore implements SettingsStore {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}

class FakeAudioEngine implements AudioEngine {
  final ValueNotifier<PlaybackSnapshot> _snapshot =
      ValueNotifier<PlaybackSnapshot>(const PlaybackSnapshot.idle());

  @override
  ValueListenable<PlaybackSnapshot> get snapshot => _snapshot;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> pause() async {
    _snapshot.value = const PlaybackSnapshot(status: PlaybackStatus.paused);
  }

  @override
  Future<void> playStream(
    String url, {
    Map<String, String>? headers,
    PlaybackMediaMetadata? metadata,
  }) async {
    _snapshot.value = const PlaybackSnapshot(status: PlaybackStatus.playing);
  }

  @override
  Future<void> resume() async {
    _snapshot.value = const PlaybackSnapshot(status: PlaybackStatus.playing);
  }

  @override
  Future<void> stop() async {
    _snapshot.value = const PlaybackSnapshot.idle();
  }

  void emitSnapshot(PlaybackSnapshot snapshot) {
    _snapshot.value = snapshot;
  }
}

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService(ConnectivitySnapshot initial)
    : _snapshot = ValueNotifier<ConnectivitySnapshot>(initial);

  factory FakeConnectivityService.online() {
    return FakeConnectivityService(
      ConnectivitySnapshot(
        isOnline: true,
        isChecking: false,
        lastCheckedAt: DateTime(2026),
      ),
    );
  }

  factory FakeConnectivityService.offline() {
    return FakeConnectivityService(
      ConnectivitySnapshot(
        isOnline: false,
        isChecking: false,
        lastCheckedAt: DateTime(2026),
      ),
    );
  }

  final ValueNotifier<ConnectivitySnapshot> _snapshot;

  @override
  ValueListenable<ConnectivitySnapshot> get snapshot => _snapshot;

  @override
  Future<void> dispose() async {
    _snapshot.dispose();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> internetReachable() async {}
}
