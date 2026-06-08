import 'dart:async';
import 'dart:io';

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

  await _deleteOversizedLegacyCatalogPreferences();
  final preferences = await SharedPreferences.getInstance();
  final localStations = LocalStationsService();
  await localStations.initialize();
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
      controller: controller,
    ),
  );
}

Future<void> _refreshStationCatalog({
  required RemoteJsonStationRepository remoteStations,
  required LocalStationsService localStations,
  required RadioAppController controller,
}) async {
  controller.markRemoteStationCatalogLoading();
  try {
    final catalogJson = await remoteStations.fetchCatalogJson();
    final objectCount = await localStations.replaceWithCatalogJson(catalogJson);
    controller.markRemoteStationCatalogLoaded(objectCount: objectCount);
    await controller.refreshDiscover();
  } catch (error) {
    controller.markRemoteStationCatalogFailed(error);
    // Keep using the cached or bundled station list.
  }
}

Future<void> _deleteOversizedLegacyCatalogPreferences() async {
  if (!Platform.isAndroid) {
    return;
  }

  const maxReasonablePreferencesBytes = 8 * 1024 * 1024;
  const legacyPreferenceFiles = <String>[
    '/data/data/com.example.no_ads_radio/shared_prefs/FlutterSharedPreferences.xml',
    '/data/user/0/com.example.no_ads_radio/shared_prefs/FlutterSharedPreferences.xml',
  ];

  for (final path in legacyPreferenceFiles) {
    try {
      final file = File(path);
      if (await file.exists() &&
          await file.length() > maxReasonablePreferencesBytes) {
        await file.delete();
      }
    } catch (_) {
      // If this path is not readable, continue startup normally.
    }
  }
}
