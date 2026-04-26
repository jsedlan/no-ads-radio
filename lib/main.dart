import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/audio/audio_engine.dart';
import 'src/controllers/radio_app_controller.dart';
import 'src/services/fallback_station_repository.dart';
import 'src/services/favorites_store.dart';
import 'src/services/connectivity_service.dart';
import 'src/services/hardcoded_station_repository.dart';
import 'src/services/local_catalog_station_repository.dart';
import 'src/services/local_stations_service.dart';
import 'src/services/radio_browser_repository.dart';
import 'src/services/remote_json_station_repository.dart';
import 'src/services/settings_store.dart';
import 'src/services/station_repository.dart';
import 'src/services/stacked_station_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.no_ads_radio.channel.audio',
    androidNotificationChannelName: 'Radio playback',
    androidNotificationOngoing: true,
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  final preferences = await SharedPreferences.getInstance();
  final localStations = LocalStationsService();
  await localStations.initialize();
  const remoteCatalogUrl = String.fromEnvironment('STATION_CATALOG_URL');
  final startupCountryCode =
      WidgetsBinding.instance.platformDispatcher.locale.countryCode
          ?.trim()
          .toUpperCase() ??
      '';

  final repositories = <StationRepository>[
    if (remoteCatalogUrl.trim().isNotEmpty)
      RemoteJsonStationRepository(catalogUrl: remoteCatalogUrl.trim()),
    StackedStationRepository(
      primary: RadioBrowserRepository(),
      secondary: LocalCatalogStationRepository(localStations),
    ),
    HardcodedStationRepository(),
  ];

  final controller = await RadioAppController.bootstrap(
    repository: FallbackStationRepository(repositories),
    favoritesStore: SharedPreferencesFavoritesStore(preferences),
    settingsStore: SharedPreferencesSettingsStore(preferences),
    audioEngine: JustAudioEngine(),
    connectivityService: ReachabilityConnectivityService(),
    startupCountryCode: startupCountryCode,
  );

  runApp(NoAdsRadioApp(controller: controller));
}
