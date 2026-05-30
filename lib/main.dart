import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/audio/audio_engine.dart';
import 'src/controllers/radio_app_controller.dart';
import 'src/services/favorites_store.dart';
import 'src/services/connectivity_service.dart';
import 'src/services/local_catalog_station_repository.dart';
import 'src/services/local_stations_service.dart';
import 'src/services/remote_json_station_repository.dart';
import 'src/services/settings_store.dart';

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
  await localStations.initialize(preferences: preferences);
  const remoteCatalogUrl = 'https://api.noadsradio.sedlan.com/stations';
  final remoteStations = RemoteJsonStationRepository(
    catalogUrl: remoteCatalogUrl,
  );
  final startupCountryCode =
      WidgetsBinding.instance.platformDispatcher.locale.countryCode
          ?.trim()
          .toUpperCase() ??
      '';

  final controller = await RadioAppController.bootstrap(
    repository: LocalCatalogStationRepository(localStations),
    favoritesStore: SharedPreferencesFavoritesStore(preferences),
    settingsStore: SharedPreferencesSettingsStore(preferences),
    audioEngine: JustAudioEngine(),
    connectivityService: ReachabilityConnectivityService(),
    startupCountryCode: startupCountryCode,
  );

  runApp(NoAdsRadioApp(controller: controller));
  unawaited(
    _refreshStationCatalog(
      remoteStations: remoteStations,
      localStations: localStations,
      preferences: preferences,
      controller: controller,
    ),
  );
}

Future<void> _refreshStationCatalog({
  required RemoteJsonStationRepository remoteStations,
  required LocalStationsService localStations,
  required SharedPreferences preferences,
  required RadioAppController controller,
}) async {
  try {
    final catalogJson = await remoteStations.fetchCatalogJson();
    await localStations.replaceWithCatalogJson(
      catalogJson,
      preferences: preferences,
    );
    await controller.refreshDiscover();
  } catch (_) {
    // Keep using the cached or bundled station list.
  }
}
