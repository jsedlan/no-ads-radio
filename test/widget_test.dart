import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:no_ads_radio/l10n/app_localizations.dart';

import 'package:no_ads_radio/src/app.dart';
import 'package:no_ads_radio/src/audio/audio_engine.dart';
import 'package:no_ads_radio/src/controllers/radio_app_controller.dart';
import 'package:no_ads_radio/src/models/station_category.dart';
import 'package:no_ads_radio/src/models/radio_station.dart';
import 'package:no_ads_radio/src/models/search_query.dart';
import 'package:no_ads_radio/src/services/connectivity_service.dart';
import 'package:no_ads_radio/src/services/catalog_station_repository.dart';
import 'package:no_ads_radio/src/services/cast_service.dart';
import 'package:no_ads_radio/src/services/fallback_station_repository.dart';
import 'package:no_ads_radio/src/services/category_stations_store.dart';
import 'package:no_ads_radio/src/services/remote_json_station_repository.dart';
import 'package:no_ads_radio/src/services/settings_store.dart';
import 'package:no_ads_radio/src/services/station_catalog_json.dart';
import 'package:no_ads_radio/src/services/station_catalog_diagnostics.dart';
import 'package:no_ads_radio/src/services/station_repository.dart';

void main() {
  test('Serbian station counts use one, few, and other plural forms', () async {
    final latinLocalizations = await AppLocalizations.delegate.load(
      const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
    );
    final cyrillicLocalizations = await AppLocalizations.delegate.load(
      const Locale('sr'),
    );

    expect(latinLocalizations.stationCount(0), 'Nema stanica');
    expect(latinLocalizations.stationCount(1), '1 stanica');
    expect(latinLocalizations.stationCount(2), '2 stanice');
    expect(latinLocalizations.stationCount(5), '5 stanica');
    expect(latinLocalizations.stationCount(21), '21 stanica');
    expect(
      latinLocalizations.filteredStationCount(22),
      '22 filtrirane stanice',
    );
    expect(cyrillicLocalizations.stationCount(0), 'Нема станица');
    expect(cyrillicLocalizations.stationCount(2), '2 станице');
    expect(
      cyrillicLocalizations.filteredStationCount(22),
      '22 филтриране станице',
    );
  });

  testWidgets('first run confirms locale country before saving it', (
    tester,
  ) async {
    final settingsStore = InMemorySettingsStore(
      const AppSettings(hasCompletedCountrySetup: false),
    );
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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

  testWidgets('renders discover list and saved flow', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsOneWidget);
    await controller.toggleStationInCategory(controller.discoverStations.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Recently played'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Show station icon'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('recent stations are available as a third home tab', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();
    await controller.playStation(controller.discoverStations.first);
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    expect(controller.selectedTab, 2);
    expect(find.text('Test Station 1'), findsWidgets);
    expect(find.byIcon(Icons.delete_sweep_rounded), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(controller.recentlyPlayedStations, isEmpty);
    expect(find.text('No recently played stations yet.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('overflow menu opens about page', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version $appVersion'), findsOneWidget);
    expect(find.text('No ad clutter'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('language preference switches the app to Serbian Latin', (
    tester,
  ) async {
    final settingsStore = InMemorySettingsStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serbian (Latin)').last);
    await tester.pumpAndSettle();

    expect(find.text('Jezik'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(controller.languagePreference, AppLanguagePreference.serbianLatin);
    expect(
      settingsStore.settings.languagePreference,
      AppLanguagePreference.serbianLatin,
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await controller.playStation(controller.discoverStations.first);
    await tester.pumpAndSettle();
    final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(screenSize.width / 2, screenSize.height - 28));
    await tester.pumpAndSettle();

    expect(find.text('Slušate'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('language preference switches the app to Serbian Cyrillic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final settingsStore = InMemorySettingsStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serbian (Cyrillic)').last);
    await tester.pumpAndSettle();

    expect(find.text('Језик'), findsOneWidget);
    expect(find.text('Тема'), findsOneWidget);
    expect(
      controller.languagePreference,
      AppLanguagePreference.serbianCyrillic,
    );
    expect(
      settingsStore.settings.languagePreference,
      AppLanguagePreference.serbianCyrillic,
    );

    controller.dispose();
  });

  testWidgets('only the canonical Saved category is localized', (tester) async {
    final settingsStore = InMemorySettingsStore(
      const AppSettings(
        languagePreference: AppLanguagePreference.serbianLatin,
        stationCategories: <StationCategory>[
          StationCategory(id: 'saved', name: 'Saved'),
          StationCategory(id: 'rock', name: 'Rock'),
        ],
      ),
    );
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Kategorije'), findsOneWidget);
    expect(find.text('Rock'), findsNothing);

    await tester.tap(find.text('Kategorije'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Uredi kategorije'));
    await tester.pumpAndSettle();

    final categoryFields = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((field) => field.controller?.text)
        .toList(growable: false);
    expect(categoryFields, containsAll(<String?>['Sačuvane', 'Rock']));

    await tester.tap(find.text('Gotovo'));
    await tester.pumpAndSettle();

    expect(controller.stationCategories[0].name, 'Saved');
    expect(controller.stationCategories[1].name, 'Rock');

    controller.dispose();
  });

  testWidgets('categories tab switches station categories', (tester) async {
    final settingsStore = InMemorySettingsStore(
      const AppSettings(
        stationCategories: <StationCategory>[
          StationCategory(id: 'saved', name: 'Saved'),
          StationCategory(id: 'rock', name: 'Rock'),
        ],
      ),
    );
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    await controller.toggleStationInCategory(
      controller.discoverStations.first,
      categoryId: 'rock',
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Saved'), findsNothing);
    expect(find.text('Rock'), findsNothing);

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('0 stations'), findsWidgets);
    expect(find.text('Rock'), findsNothing);
    expect(find.text('Test Station 1'), findsNothing);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Choose category'), findsOneWidget);
    expect(find.text('Rock'), findsOneWidget);
    expect(find.text('1 station'), findsOneWidget);

    await tester.tap(find.text('Rock'));
    await tester.pumpAndSettle();

    expect(controller.activeStationCategoryId, 'rock');
    expect(settingsStore.settings.activeStationCategoryId, 'rock');
    expect(find.text('Test Station 1'), findsOneWidget);

    controller.dispose();

    final reloadedController = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    expect(reloadedController.activeStationCategoryId, 'rock');

    reloadedController.dispose();
  });

  testWidgets('categories tab opens category management', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Add category'), findsNothing);

    await tester.tap(find.byTooltip('Manage categories'));
    await tester.pumpAndSettle();

    expect(find.text('Add category'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('station subtitles follow selected Serbian scripts', (
    tester,
  ) async {
    final latinController = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(
        const AppSettings(
          languagePreference: AppLanguagePreference.serbianLatin,
        ),
      ),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: latinController));
    await tester.pumpAndSettle();

    expect(find.text('Srbija • test • rok'), findsWidgets);

    latinController.dispose();

    final cyrillicController = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(
        const AppSettings(
          languagePreference: AppLanguagePreference.serbianCyrillic,
        ),
      ),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: cyrillicController));
    await tester.pumpAndSettle();

    expect(find.text('Србија • test • рок'), findsWidgets);

    cyrillicController.dispose();
  });

  testWidgets('bottom player opens now playing only while active', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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

  testWidgets('bottom player falls back to station name without metadata', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    controller.selectTab(1);
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsNothing);

    await controller.playStation(controller.discoverStations.first);
    await tester.pumpAndSettle();

    expect(find.text('Test Station 1'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('tapping current station opens now playing', (tester) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await controller.playStation(controller.discoverStations.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Station 1').first);
    await tester.pumpAndSettle();

    expect(find.text('Now playing'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('tapping paused current station starts playback', (tester) async {
    final audioEngine = FakeAudioEngine();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: audioEngine,
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    await controller.playStation(controller.discoverStations.first);
    await controller.pausePlayback();
    await tester.pumpAndSettle();

    expect(controller.playback.isPaused, isTrue);
    expect(audioEngine.playStreamCount, 1);

    await tester.tap(find.text('Test Station 1').first);
    await tester.pumpAndSettle();

    expect(find.text('Now playing'), findsNothing);
    expect(audioEngine.playStreamCount, 2);
    expect(controller.playback.isPlaying, isTrue);

    controller.dispose();
  });

  testWidgets('filtered station count provides a clear filter action', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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
      categoryStationsStore: InMemoryCategoryStationsStore(),
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

  test('controller records remote catalog load failure', () async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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
  });

  test(
    'controller records successful Sedlan GET and selects it as source',
    () async {
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        categoryStationsStore: InMemoryCategoryStationsStore(),
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
        categoryStationsStore: InMemoryCategoryStationsStore(),
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

  test(
    'remote catalog fetch sends selected countries as query params',
    () async {
      final client = RecordingHttpClient(body: '[]');
      final repository = RemoteJsonStationRepository(
        catalogUrl: 'https://api.noadsradio.sedlan.com/stations',
        client: client,
      );

      final response = await repository.fetchCatalog(
        countryCodes: const <String>['rs', 'MK'],
      );

      expect(response.statusCode, 200);
      expect(client.requests, hasLength(1));
      expect(client.requests.single.url.scheme, 'https');
      expect(client.requests.single.url.host, 'api.noadsradio.sedlan.com');
      expect(client.requests.single.url.path, '/stations');
      expect(client.requests.single.url.queryParametersAll['country'], <String>[
        'rs',
        'MK',
      ]);
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

  test(
    'diaspora stations are included for every former Yugoslav country',
    () async {
      final repository = SingleStationCatalogRepository(
        RadioStation.fromJson(<String, dynamic>{
          'stationuuid': 'diaspora-station',
          'name': 'Diaspora Station',
          'url': 'https://example.com/stream',
          'url_resolved': 'https://example.com/stream',
          'country': 'Dijaspora',
          'countrycode': '',
          'state': 'Germany',
        }),
      );

      for (final countryCode in <String>['RS', 'HR', 'SI', 'ME', 'BA', 'MK']) {
        final stations = await repository.searchStations(
          StationSearchQuery(countryCode: countryCode),
        );
        expect(stations, hasLength(1), reason: countryCode);
      }

      final germanStations = await repository.searchStations(
        const StationSearchQuery(countryCode: 'DE'),
      );
      expect(germanStations, isEmpty);
    },
  );

  testWidgets('diaspora stations show a badge and broadcast country', (
    tester,
  ) async {
    final settingsStore = InMemorySettingsStore(
      const AppSettings(countryCodes: <String>['RS']),
    );
    final controller = await RadioAppController.bootstrap(
      repository: SingleStationCatalogRepository(
        RadioStation.fromJson(<String, dynamic>{
          'stationuuid': 'diaspora-station',
          'name': 'Diaspora Station',
          'url': 'https://example.com/stream',
          'url_resolved': 'https://example.com/stream',
          'country': 'Dijaspora',
          'countrycode': '',
          'state': 'Germany',
          'tags': 'folk',
        }),
      ),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: settingsStore,
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Diaspora Station'), findsOneWidget);
    expect(find.text('Diaspora'), findsOneWidget);
    expect(find.text('Germany • folk'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Station countries'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Diaspora stations are automatically included when you select any '
        'former Yugoslav country.',
      ),
      findsOneWidget,
    );

    controller.dispose();
  });

  test(
    'multi-country discover does not count shared diaspora matches as duplicates',
    () async {
      final settingsStore = InMemorySettingsStore(
        const AppSettings(countryCodes: <String>['RS', 'MK']),
      );
      final controller = await RadioAppController.bootstrap(
        repository: StaticCatalogStationRepository(<RadioStation>[
          RadioStation.fromJson(<String, dynamic>{
            'stationuuid': 'diaspora-station',
            'name': 'Diaspora Station',
            'url': 'https://example.com/stream',
            'url_resolved': 'https://example.com/stream',
            'country': 'Dijaspora',
            'countrycode': '',
            'state': 'Germany',
          }),
        ]),
        categoryStationsStore: InMemoryCategoryStationsStore(),
        settingsStore: settingsStore,
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
      );

      expect(controller.discoverStations, hasLength(1));
      expect(controller.duplicateStations, isEmpty);

      controller.dispose();
    },
  );

  testWidgets('selected station countries scroll without reordering', (
    tester,
  ) async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(
        const AppSettings(countryCodes: <String>['RS', 'HR', 'SI', 'ME', 'BA']),
      ),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );

    await tester.pumpWidget(NoAdsRadioApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Station countries'));
    await tester.pumpAndSettle();

    final selectedCountriesCard = find.widgetWithText(
      Card,
      'Selected countries',
    );
    final selectedCountriesList = find.descendant(
      of: selectedCountriesCard,
      matching: find.byType(ListView),
    );
    expect(selectedCountriesList, findsOneWidget);
    expect(find.byType(ReorderableListView), findsNothing);
    expect(find.byIcon(Icons.drag_handle_rounded), findsNothing);

    final scrollable = find.descendant(
      of: selectedCountriesList,
      matching: find.byType(Scrollable),
    );
    expect(tester.state<ScrollableState>(scrollable).position.pixels, 0);
    await tester.drag(selectedCountriesList, const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      greaterThan(0),
    );

    controller.dispose();
  });

  test(
    'country setting changes reload discover stations immediately',
    () async {
      final settingsStore = InMemorySettingsStore(
        const AppSettings(countryCodes: <String>['RS']),
      );
      final controller = await RadioAppController.bootstrap(
        repository: StaticCatalogStationRepository(<RadioStation>[
          RadioStation.fromJson(<String, dynamic>{
            'stationuuid': 'serbian-impuls',
            'name': 'Impuls Radio',
            'url': 'https://example.com/serbia',
            'url_resolved': 'https://example.com/serbia',
            'country': 'Srbija',
            'countrycode': '',
            'state': 'Bačka Palanka',
          }),
          RadioStation.fromJson(<String, dynamic>{
            'stationuuid': 'mk-impuls',
            'name': 'Impuls Radio',
            'url': 'https://example.com/macedonia',
            'url_resolved': 'https://example.com/macedonia',
            'country': 'Makedonija',
            'countrycode': '',
          }),
        ]),
        categoryStationsStore: InMemoryCategoryStationsStore(),
        settingsStore: settingsStore,
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
      );

      expect(
        controller.discoverStations.map((station) => station.displayName),
        <String>['Impuls Radio'],
      );

      await controller.setCountryCodes(<String>['RS', 'MK']);

      expect(controller.discoverStations, hasLength(2));
      expect(
        controller.discoverStations.map((station) => station.countryCode),
        containsAll(<String>['RS', 'MK']),
      );
      expect(settingsStore.settings.countryCodes, <String>['RS', 'MK']);

      controller.dispose();
    },
  );

  test('controller persists settings changes', () async {
    final settingsStore = InMemorySettingsStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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
        categoryStationsStore: InMemoryCategoryStationsStore(),
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

  test('recent history keeps multiple stations without UUIDs', () async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    final firstStation = RadioStation.fromJson(<String, dynamic>{
      'stationuuid': '',
      'name': 'First UUID-less Station',
      'url': 'https://example.com/first-stream',
      'url_resolved': 'https://example.com/first-stream',
      'country': 'Serbia',
    });
    final secondStation = RadioStation.fromJson(<String, dynamic>{
      'stationuuid': '',
      'name': 'Second UUID-less Station',
      'url': 'https://example.com/second-stream',
      'url_resolved': 'https://example.com/second-stream',
      'country': 'Serbia',
    });

    await controller.playStation(firstStation);
    await controller.playStation(secondStation);

    expect(controller.recentlyPlayedStations, <RadioStation>[
      secondStation,
      firstStation,
    ]);

    controller.dispose();
  });

  test('controller retries a failed stream before giving up', () async {
    final audioEngine = FakeAudioEngine();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: audioEngine,
      connectivityService: FakeConnectivityService.online(),
      streamRecoveryRetryInterval: const Duration(milliseconds: 10),
      streamRecoveryWindow: const Duration(milliseconds: 100),
    );

    final station = controller.discoverStations.first;
    await controller.playStation(station);
    expect(audioEngine.playStreamCount, 1);

    audioEngine.emitSnapshot(
      const PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: 'stream ended',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(controller.currentStation?.identityKey, station.identityKey);
    expect(controller.playback.isPlaying, isTrue);
    expect(audioEngine.playStreamCount, greaterThanOrEqualTo(2));

    controller.dispose();
  });

  test(
    'controller advances to next category when stream retries keep failing',
    () async {
      final audioEngine = FakeAudioEngine()
        ..failingUrls.addAll(<String>[
          'https://example.com/0',
          'https://example.com/0/stream',
          'https://example.com/station-0.mp3',
        ]);
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        categoryStationsStore: InMemoryCategoryStationsStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: audioEngine,
        connectivityService: FakeConnectivityService.online(),
        streamRecoveryRetryInterval: const Duration(milliseconds: 5),
        streamRecoveryWindow: const Duration(milliseconds: 25),
      );

      final first = controller.discoverStations[0];
      final second = controller.discoverStations[1];
      await controller.toggleStationInCategory(first);
      await controller.toggleStationInCategory(second);

      await controller.playStation(first);
      await Future<void>.delayed(const Duration(milliseconds: 45));

      expect(audioEngine.playStreamCount, greaterThan(1));
      expect(controller.currentStation?.identityKey, second.identityKey);
      expect(controller.playback.isPlaying, isTrue);

      controller.dispose();
    },
  );

  test('controller hands playback controls to an active Cast device', () async {
    final audioEngine = FakeAudioEngine();
    final castService = FakeCastService();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: audioEngine,
      castService: castService,
      connectivityService: FakeConnectivityService.online(),
    );

    final station = controller.discoverStations.first;
    await controller.playStation(station);
    await controller.connectToCastDevice(castService.device);

    expect(controller.isCasting, isTrue);
    expect(audioEngine.pauseCount, 1);
    expect(castService.loadedMedia?.title, station.displayName);
    expect(castService.loadedMedia?.contentType, 'audio/mpeg');

    await controller.pausePlayback();
    await controller.resumePlayback();
    await controller.stopPlayback();

    expect(castService.pauseCount, 1);
    expect(castService.resumeCount, 1);
    expect(castService.stopCount, 1);
    controller.dispose();
  });

  test('controller restores local playback when Cast loading fails', () async {
    final audioEngine = FakeAudioEngine();
    final castService = FakeCastService()..failLoading = true;
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: audioEngine,
      castService: castService,
      connectivityService: FakeConnectivityService.online(),
    );

    await controller.playStation(controller.discoverStations.first);

    await expectLater(
      controller.connectToCastDevice(castService.device),
      throwsStateError,
    );

    expect(controller.isCasting, isFalse);
    expect(audioEngine.pauseCount, 1);
    expect(audioEngine.resumeCount, 1);
    expect(controller.playback.isPlaying, isTrue);
    controller.dispose();
  });

  test('controller clears recently played stations', () async {
    final settingsStore = InMemorySettingsStore();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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

  test(
    'controller reorders category stations and persists the order',
    () async {
      final categoryStationsStore = InMemoryCategoryStationsStore();
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        categoryStationsStore: categoryStationsStore,
        settingsStore: InMemorySettingsStore(),
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.online(),
      );
      final categoryId = controller.activeStationCategoryId;

      await controller.toggleStationInCategory(controller.discoverStations[0]);
      await controller.toggleStationInCategory(controller.discoverStations[1]);
      await controller.toggleStationInCategory(controller.discoverStations[2]);

      expect(
        controller
            .stationsForCategory(categoryId)
            .map((station) => station.stationUuid),
        <String>['station-2', 'station-1', 'station-0'],
      );

      await controller.reorderCategoryStations(
        categoryId: categoryId,
        oldIndex: 0,
        newIndex: 3,
      );

      expect(
        controller
            .stationsForCategory(categoryId)
            .map((station) => station.stationUuid),
        <String>['station-1', 'station-0', 'station-2'],
      );
      expect(
        (await categoryStationsStore.loadStationsByCategory())[categoryId]!.map(
          (station) => station.stationUuid,
        ),
        <String>['station-1', 'station-0', 'station-2'],
      );

      controller.dispose();
    },
  );

  test('category check without category searches all categories', () async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
      settingsStore: InMemorySettingsStore(),
      audioEngine: FakeAudioEngine(),
      connectivityService: FakeConnectivityService.online(),
    );
    await controller.setStationCategories(<String>['Saved', 'Other']);
    final savedCategoryId = controller.stationCategories[0].id;
    final otherCategoryId = controller.stationCategories[1].id;
    final station = controller.discoverStations.first;

    await controller.toggleStationInCategory(
      station,
      categoryId: otherCategoryId,
    );

    expect(controller.isStationInCategory(station.stationUuid), isTrue);
    expect(
      controller.isStationInCategory(
        station.stationUuid,
        categoryId: savedCategoryId,
      ),
      isFalse,
    );
    expect(
      controller.isStationInCategory(
        station.stationUuid,
        categoryId: otherCategoryId,
      ),
      isTrue,
    );

    controller.dispose();
  });

  test('station categories distinguish stations with missing UUIDs', () async {
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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

    await controller.toggleStationInCategory(first);

    expect(controller.isStationInCategory(first.identityKey), isTrue);
    expect(controller.isStationInCategory(second.identityKey), isFalse);

    await controller.toggleStationInCategory(first);

    expect(controller.isStationInCategory(first.identityKey), isFalse);
    expect(controller.isStationInCategory(second.identityKey), isFalse);

    controller.dispose();
  });

  testWidgets(
    'shows offline message on current station when connectivity is down',
    (tester) async {
      final controller = await RadioAppController.bootstrap(
        repository: FakeStationRepository(),
        categoryStationsStore: InMemoryCategoryStationsStore(),
        settingsStore: InMemorySettingsStore(),
        audioEngine: FakeAudioEngine(),
        connectivityService: FakeConnectivityService.offline(),
      );

      await tester.pumpWidget(NoAdsRadioApp(controller: controller));
      await tester.pumpAndSettle();
      await controller.playStation(controller.discoverStations.first);
      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsNothing);
      expect(find.text('Internet connection lost'), findsOneWidget);

      controller.dispose();
    },
  );

  test('playback progress clears a stale offline state', () async {
    final audioEngine = FakeAudioEngine();
    final controller = await RadioAppController.bootstrap(
      repository: FakeStationRepository(),
      categoryStationsStore: InMemoryCategoryStationsStore(),
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
        categoryStationsStore: InMemoryCategoryStationsStore(),
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
        categoryStationsStore: InMemoryCategoryStationsStore(),
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
        categoryStationsStore: InMemoryCategoryStationsStore(),
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
      categoryStationsStore: InMemoryCategoryStationsStore(),
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
      categoryStationsStore: InMemoryCategoryStationsStore(),
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

class StaticCatalogStationRepository extends CatalogStationRepository {
  StaticCatalogStationRepository(this.stations);

  final List<RadioStation> stations;

  @override
  Future<List<RadioStation>> loadCatalog() async {
    return stations;
  }
}

class RecordingHttpClient extends http.BaseClient {
  RecordingHttpClient({required this.body, this.statusCode = 200});

  final String body;
  final int statusCode;
  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(body.codeUnits),
      statusCode,
    );
  }
}

class InMemoryCategoryStationsStore implements CategoryStationsStore {
  Map<String, List<RadioStation>> _stationsByCategory =
      const <String, List<RadioStation>>{};

  @override
  Future<Map<String, List<RadioStation>>> loadStationsByCategory() async =>
      _stationsByCategory;

  @override
  Future<void> saveStationsByCategory(
    Map<String, List<RadioStation>> stationsByCategory,
  ) async {
    _stationsByCategory = Map<String, List<RadioStation>>.unmodifiable(
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
  int pauseCount = 0;
  int resumeCount = 0;
  int playStreamCount = 0;
  final List<String> playedUrls = <String>[];
  final Set<String> failingUrls = <String>{};

  @override
  Future<void> dispose() async {}

  @override
  Future<void> pause() async {
    pauseCount += 1;
    _snapshot.value = const PlaybackSnapshot(status: PlaybackStatus.paused);
  }

  @override
  Future<void> playStream(
    String url, {
    Map<String, String>? headers,
    PlaybackMediaMetadata? metadata,
  }) async {
    playStreamCount += 1;
    playedUrls.add(url);
    _snapshot.value = failingUrls.contains(url)
        ? PlaybackSnapshot(
            status: PlaybackStatus.error,
            message: 'stream failed $playStreamCount',
          )
        : const PlaybackSnapshot(status: PlaybackStatus.playing);
  }

  @override
  Future<void> resume() async {
    resumeCount += 1;
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

class FakeCastService implements CastService {
  final CastDevice device = const CastDevice(
    id: 'living-room',
    name: 'Living Room',
    modelName: 'Chromecast',
  );
  final ValueNotifier<CastSnapshot> _snapshot = ValueNotifier<CastSnapshot>(
    const CastSnapshot.unavailable(),
  );
  CastMedia? loadedMedia;
  int pauseCount = 0;
  int resumeCount = 0;
  int stopCount = 0;
  bool failLoading = false;

  @override
  ValueListenable<CastSnapshot> get snapshot => _snapshot;

  @override
  Future<void> initialize() async {
    _snapshot.value = CastSnapshot(
      connectionStatus: CastConnectionStatus.disconnected,
      devices: <CastDevice>[device],
    );
  }

  @override
  Future<void> connect(CastDevice device) async {
    _snapshot.value = CastSnapshot(
      connectionStatus: CastConnectionStatus.connected,
      deviceName: device.name,
      devices: <CastDevice>[device],
    );
  }

  @override
  Future<void> disconnect() async {
    _snapshot.value = CastSnapshot(
      connectionStatus: CastConnectionStatus.disconnected,
      devices: <CastDevice>[device],
    );
  }

  @override
  Future<void> load(CastMedia media) async {
    if (failLoading) {
      throw StateError('Cast load failed.');
    }
    loadedMedia = media;
    _snapshot.value = CastSnapshot(
      connectionStatus: CastConnectionStatus.connected,
      playbackStatus: CastPlaybackStatus.playing,
      deviceName: device.name,
      devices: <CastDevice>[device],
    );
  }

  @override
  Future<void> pause() async {
    pauseCount += 1;
  }

  @override
  Future<void> resume() async {
    resumeCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<void> startDiscovery() async {}

  @override
  Future<void> stopDiscovery() async {}

  @override
  Future<void> dispose() async {
    _snapshot.dispose();
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
