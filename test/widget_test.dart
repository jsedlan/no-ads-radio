import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:no_ads_radio/src/app.dart';
import 'package:no_ads_radio/src/audio/audio_engine.dart';
import 'package:no_ads_radio/src/controllers/radio_app_controller.dart';
import 'package:no_ads_radio/src/models/radio_station.dart';
import 'package:no_ads_radio/src/models/search_query.dart';
import 'package:no_ads_radio/src/services/connectivity_service.dart';
import 'package:no_ads_radio/src/services/catalog_station_repository.dart';
import 'package:no_ads_radio/src/services/fallback_station_repository.dart';
import 'package:no_ads_radio/src/services/favorites_store.dart';
import 'package:no_ads_radio/src/services/settings_store.dart';
import 'package:no_ads_radio/src/services/station_catalog_json.dart';
import 'package:no_ads_radio/src/services/station_catalog_diagnostics.dart';
import 'package:no_ads_radio/src/services/station_repository.dart';

void main() {
  testWidgets('first run confirms locale country before saving it', (
    tester,
  ) async {
    final settingsStore = InMemorySettingsStore(
      const AppSettings(hasCompletedCountrySetup: false),
    );
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
      startupCountryCode: 'US',
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Choose your station country'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);
    expect(
      find.text('You can add more countries later in Settings.'),
      findsOneWidget,
    );
    expect(controller.countryCodes, isEmpty);

    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Serbia');
    await tester.pump();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Serbia',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(controller.hasCompletedCountrySetup, isTrue);
    expect(controller.countryCodes, <String>['RS']);
    expect(find.text('Choose your station country'), findsNothing);
    expect(settingsStore.settings.hasCompletedCountrySetup, isTrue);
    expect(settingsStore.settings.countryCodes, <String>['RS']);

    controller.dispose();
  });

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
    await controller.toggleFavorite(controller.discoverStations.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Recently played'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Show station icon'), findsOneWidget);
  });

  testWidgets('bottom player opens now playing only while active', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(screenSize.width / 2, screenSize.height - 28));
    await tester.pumpAndSettle();

    expect(find.text('Now playing'), findsNothing);

    await controller.playStation(controller.discoverStations.first);
    await tester.pumpAndSettle();

    await tester.tapAt(Offset(screenSize.width / 2, screenSize.height - 28));
    await tester.pumpAndSettle();

    expect(find.text('Now playing'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Codec'), findsOneWidget);

    await controller.stopPlayback();
    await tester.pumpAndSettle();
  });

  testWidgets('filtered station count provides a clear filter action', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    controller.setDiscoverFilter('Test Station 1');
    await tester.pumpAndSettle();

    expect(find.text('1 filtered station'), findsOneWidget);
    expect(find.byTooltip('Clear filter'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear filter'));
    await tester.pumpAndSettle();

    expect(controller.discoverFilter, isEmpty);
    expect(find.text('4 stations'), findsOneWidget);
    expect(find.byTooltip('Clear filter'), findsNothing);

    controller.dispose();
  });

  testWidgets('station list filters as search text changes', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filter stations'));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Test Station');
    await tester.pump();

    expect(find.text('4 filtered stations'), findsOneWidget);

    await tester.enterText(searchField, 'Test Station 2');
    await tester.pump();

    expect(controller.discoverFilter, 'Test Station 2');
    expect(find.text('1 filtered station'), findsOneWidget);
    expect(find.text('Test Station 1'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Test Station 2',
      ),
      findsOneWidget,
    );

    controller.dispose();
  });

  testWidgets('debug view shows active catalog source and loading log', (
    tester,
  ) async {
    final loadedAt = DateTime(2026, 6, 8, 12, 30);
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
      initialActiveCatalogSource: StationCatalogSource.cache,
      initialCatalogLoadEvents: <StationCatalogLoadEvent>[
        StationCatalogLoadEvent(
          timestamp: loadedAt,
          source: StationCatalogSource.cache,
          status: StationCatalogEventStatus.success,
          message: 'Loaded cached stations. This source is now in use.',
          stationCount: 4,
        ),
      ],
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Debug view').last);
    await tester.pumpAndSettle();

    expect(find.text('Active source'), findsOneWidget);
    expect(find.text('Cached Sedlan catalog'), findsOneWidget);
    expect(
      find.textContaining('12:30:00  Cached Sedlan catalog'),
      findsOneWidget,
    );
    expect(find.text('Station loading log'), findsOneWidget);
    expect(find.text('4 playable stations loaded'), findsOneWidget);
  });

  test('station catalog object count includes unplayable sedlan objects', () {
    final objectCount = countStationCatalogJsonObjects('''
      {
        "stations": [
          {"stationuuid": "station-1", "name": "Station 1"},
          {"stationuuid": "station-2", "name": "Station 2", "url": ""}
        ]
      }
    ''');

    expect(objectCount, 2);
  });

  test(
    'controller records remote catalog load failure for debug view',
    () async {
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
      );

      controller.markRemoteStationCatalogFailed(Exception('offline'));

      expect(
        controller.remoteStationCatalog.status,
        RemoteStationCatalogStatus.failed,
      );
      expect(controller.remoteStationCatalog.debugLabel, contains('offline'));
      expect(
        controller.catalogLoadEvents.last.message,
        contains('Sedlan refresh failed'),
      );
    },
  );

  test(
    'controller records successful Sedlan GET and selects it as source',
    () async {
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
        initialActiveCatalogSource: StationCatalogSource.bundledAsset,
      );

      controller.markRemoteStationCatalogLoading();
      controller.markRemoteStationCatalogResponse(statusCode: 200);
      controller.markRemoteStationCatalogLoaded(
        objectCount: 8,
        stationCount: 6,
      );

      expect(controller.activeCatalogSource, StationCatalogSource.sedlanGet);
      expect(controller.catalogLoadEvents, hasLength(3));
      expect(controller.catalogLoadEvents[1].message, contains('HTTP 200'));
      expect(controller.catalogLoadEvents.last.stationCount, 6);
    },
  );

  test(
    'controller counts full catalog, not filtered discover stations',
    () async {
      final settingsStore = InMemorySettingsStore();
      await settingsStore.saveSettings(
        const AppSettings(countryCodes: <String>['RS']),
      );
      final controller = await RadioAppController.bootstrap(
        repository: FakeCatalogStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: settingsStore,
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
      );

      expect(controller.discoverStations, hasLength(3));
      expect(controller.loadedStationCount, 6);
    },
  );

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

  test('station parser derives country code for scraped Serbian stations', () {
    final station = RadioStation.fromJson(<String, dynamic>{
      'stationuuid': 'scraped-serbian-station',
      'name': 'Serbian Station',
      'url': 'https://example.com/stream',
      'url_resolved': 'https://example.com/stream',
      'country': 'Srbija',
      'countrycode': '',
    });

    expect(station.countryCode, 'RS');
  });

  test('station parser derives country code for English Serbia country', () {
    final station = RadioStation.fromJson(<String, dynamic>{
      'stationuuid': 'serbian-station',
      'name': 'Serbian Station',
      'url': 'https://example.com/stream',
      'url_resolved': 'https://example.com/stream',
      'country': 'Serbia',
      'countrycode': '',
    });

    expect(station.countryCode, 'RS');
  });

  test(
    'catalog country search includes Serbia stations without countrycode',
    () async {
      final repository = SingleStationCatalogRepository(
        RadioStation.fromJson(<String, dynamic>{
          'stationuuid': 'serbian-station',
          'name': 'Serbian Station',
          'url': 'https://example.com/stream',
          'url_resolved': 'https://example.com/stream',
          'country': 'Serbia',
          'countrycode': '',
        }),
      );

      final stations = await repository.searchStations(
        const StationSearchQuery(countryCode: 'RS'),
      );

      expect(stations, hasLength(1));
      expect(stations.single.stationUuid, 'serbian-station');
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

    expect(controller.themePreference, AppThemePreference.dark);
    expect(controller.showStationIcon, isFalse);

    await controller.setThemePreference(AppThemePreference.light);
    await controller.setShowStationIcon(true);

    final reloaded = await settingsStore.loadSettings();
    expect(reloaded.themePreference, AppThemePreference.light);
    expect(reloaded.showStationIcon, isTrue);
  });

  test(
    'controller records recently played stations after playback starts',
    () async {
      final settingsStore = InMemorySettingsStore();
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: settingsStore,
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
      );
      final firstStation = controller.discoverStations.first;
      final secondStation = controller.discoverStations[1];

      await controller.playStation(firstStation);
      await controller.playStation(secondStation);
      await controller.playStation(firstStation);

      expect(controller.recentlyPlayedStations, hasLength(2));
      expect(controller.recentlyPlayedStations.first.stationUuid, 'station-0');
      expect(controller.recentlyPlayedStations.last.stationUuid, 'station-1');

      final reloaded = await settingsStore.loadSettings();
      expect(reloaded.recentlyPlayedStations, hasLength(2));
      expect(reloaded.recentlyPlayedStations.first.stationUuid, 'station-0');

      controller.dispose();
    },
  );

  test('controller clears recently played stations', () async {
    final settingsStore = InMemorySettingsStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await controller.playStation(controller.discoverStations.first);
    await controller.clearRecentlyPlayed();

    expect(controller.recentlyPlayedStations, isEmpty);
    expect(
      (await settingsStore.loadSettings()).recentlyPlayedStations,
      isEmpty,
    );

    controller.dispose();
  });

  test('controller reorders favorites and persists the order', () async {
    final favoritesStore = InMemoryFavoritesStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: favoritesStore,
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    final categoryId = controller.activeFavoriteCategoryId;

    await controller.toggleFavorite(controller.discoverStations[0]);
    await controller.toggleFavorite(controller.discoverStations[1]);
    await controller.toggleFavorite(controller.discoverStations[2]);

    expect(
      controller
          .favoritesForCategory(categoryId)
          .map((station) => station.stationUuid),
      <String>['station-2', 'station-1', 'station-0'],
    );

    await controller.reorderFavorites(
      categoryId: categoryId,
      oldIndex: 0,
      newIndex: 3,
    );

    expect(
      controller
          .favoritesForCategory(categoryId)
          .map((station) => station.stationUuid),
      <String>['station-1', 'station-0', 'station-2'],
    );
    expect(
      (await favoritesStore.loadFavorites())[categoryId]!.map(
        (station) => station.stationUuid,
      ),
      <String>['station-1', 'station-0', 'station-2'],
    );

    controller.dispose();
  });

  test('favorite check without category searches all categories', () async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    await controller.setFavoriteCategories(<String>['Favorites', 'Other']);
    final favoritesCategoryId = controller.favoriteCategories[0].id;
    final otherCategoryId = controller.favoriteCategories[1].id;
    final station = controller.discoverStations.first;

    await controller.toggleFavorite(station, categoryId: otherCategoryId);

    expect(controller.isFavorite(station.stationUuid), isTrue);
    expect(
      controller.isFavorite(
        station.stationUuid,
        categoryId: favoritesCategoryId,
      ),
      isFalse,
    );
    expect(
      controller.isFavorite(station.stationUuid, categoryId: otherCategoryId),
      isTrue,
    );

    controller.dispose();
  });

  test('favorites distinguish stations with missing UUIDs', () async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    final first = _stationWithoutUuid(
      name: 'First Station',
      streamUrl: 'https://example.com/first',
    );
    final second = _stationWithoutUuid(
      name: 'Second Station',
      streamUrl: 'https://example.com/second',
    );

    await controller.toggleFavorite(first);

    expect(controller.isFavorite(first.identityKey), isTrue);
    expect(controller.isFavorite(second.identityKey), isFalse);

    await controller.toggleFavorite(first);

    expect(controller.isFavorite(first.identityKey), isFalse);
    expect(controller.isFavorite(second.identityKey), isFalse);

    controller.dispose();
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

  test('playback progress clears a stale offline state', () async {
    final audioEngine = FakeAudioEngine();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      favoritesStore: InMemoryFavoritesStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: audioEngine,
      connectivityService: FakeConnectivityService.offline(),
    );

    expect(controller.isOffline, isTrue);

    audioEngine.emitSnapshot(
      const PlaybackSnapshot(
        status: PlaybackStatus.playing,
        position: Duration(milliseconds: 500),
      ),
    );

    expect(controller.isOffline, isFalse);

    controller.dispose();
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

  test(
    'controller detects a new internet outage after playback recovers',
    () async {
      final audioEngine = FakeAudioEngine();
      final connectivityService = FakeConnectivityService.offline();
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: audioEngine,
        connectivityService: connectivityService,
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
      expect(
        controller.playbackStallReason,
        PlaybackStallReason.internetOutage,
      );

      audioEngine.emitSnapshot(
        const PlaybackSnapshot(
          status: PlaybackStatus.playing,
          position: Duration(milliseconds: 500),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(controller.playbackStalled, isFalse);
      expect(controller.playbackStallReason, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(controller.playbackStalled, isTrue);
      expect(
        controller.playbackStallReason,
        PlaybackStallReason.internetOutage,
      );

      controller.dispose();
    },
  );

  test(
    'controller does not notify listeners for position-only playback ticks',
    () async {
      final audioEngine = FakeAudioEngine();
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        favoritesStore: InMemoryFavoritesStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: audioEngine,
        connectivityService: FakeConnectivityService.online(),
      );

      var notificationCount = 0;
      void countNotification() {
        notificationCount += 1;
      }

      controller.addListener(countNotification);
      audioEngine.emitSnapshot(
        const PlaybackSnapshot(
          status: PlaybackStatus.playing,
          nowPlaying: NowPlayingMetadata(title: 'Artist - Song'),
        ),
      );
      expect(notificationCount, 1);

      notificationCount = 0;
      audioEngine.emitSnapshot(
        const PlaybackSnapshot(
          status: PlaybackStatus.playing,
          nowPlaying: NowPlayingMetadata(title: 'Artist - Song'),
          position: Duration(milliseconds: 500),
        ),
      );

      expect(controller.playback.position, const Duration(milliseconds: 500));
      expect(notificationCount, 0);

      audioEngine.emitSnapshot(
        const PlaybackSnapshot(
          status: PlaybackStatus.playing,
          nowPlaying: NowPlayingMetadata(title: 'Artist - Next Song'),
          position: Duration(milliseconds: 750),
        ),
      );

      expect(notificationCount, 1);

      controller.removeListener(countNotification);
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

RadioStation _stationWithoutUuid({
  required String name,
  required String streamUrl,
}) {
  return RadioStation(
    stationUuid: '',
    name: name,
    url: streamUrl,
    urlResolved: streamUrl,
    homepage: '',
    favicon: '',
    tags: '',
    country: '',
    countryCode: '',
    state: '',
    language: '',
    codec: 'MP3',
    bitrate: 128,
    votes: 0,
    clickCount: 0,
    clickTrend: 0,
    lastCheckOk: true,
    hls: false,
  );
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

class FakeCatalogStationRepository extends CatalogStationRepository {
  @override
  Future<List<RadioStation>> loadCatalog() async {
    return List<RadioStation>.generate(
      6,
      (index) => RadioStation(
        stationUuid: 'catalog-station-$index',
        name: 'Catalog Station ${index + 1}',
        url: 'https://example.com/catalog/$index',
        urlResolved: 'https://example.com/catalog/$index/stream',
        homepage: '',
        favicon: '',
        tags: 'test',
        country: index.isEven ? 'Serbia' : 'Germany',
        countryCode: index.isEven ? 'RS' : 'DE',
        state: '',
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

class SingleStationCatalogRepository extends CatalogStationRepository {
  SingleStationCatalogRepository(this.station);

  final RadioStation station;

  @override
  Future<List<RadioStation>> loadCatalog() async {
    return <RadioStation>[station];
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
  InMemorySettingsStore([this._settings = const AppSettings()]);

  AppSettings _settings;

  AppSettings get settings => _settings;

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
    : _probeIsOnline = initial.isOnline ?? false,
      _snapshot = ValueNotifier<ConnectivitySnapshot>(initial);

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
  final bool _probeIsOnline;

  @override
  ValueListenable<ConnectivitySnapshot> get snapshot => _snapshot;

  @override
  Future<void> dispose() async {
    _snapshot.dispose();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> internetReachable() async {
    _snapshot.value = ConnectivitySnapshot(
      isOnline: _probeIsOnline,
      isChecking: false,
      lastCheckedAt: DateTime.now(),
    );
  }

  @override
  void reportOnline() {
    if (_snapshot.value.isOnline == true) {
      return;
    }
    _snapshot.value = ConnectivitySnapshot(
      isOnline: true,
      isChecking: false,
      lastCheckedAt: DateTime.now(),
    );
  }
}
