import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/audio/audio_engine.dart';
import 'src/controllers/radio_app_controller.dart';
import 'src/services/category_stations_store.dart';
import 'src/services/connectivity_service.dart';
import 'src/services/cast_service.dart';
import 'src/services/local_catalog_station_repository.dart';
import 'src/services/local_stations_service.dart';
import 'src/services/remote_json_station_repository.dart';
import 'src/services/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.sedlan.noadsradio.channel.audio',
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
    categoryStationsStore: SharedPreferencesCategoryStationsStore(preferences),
    settingsStore: SharedPreferencesSettingsStore(preferences),
    audioEngine: JustAudioEngine(),
    castService: GoogleCastService(),
    connectivityService: ReachabilityConnectivityService(),
    startupCountryCode: startupCountryCode,
    initialCatalogLoadEvents: localStations.loadEvents,
    initialActiveCatalogSource: localStations.activeSource,
  );

  runApp(NoAdsRadioApp(controller: controller));
  _RemoteCatalogRefreshCoordinator(
    remoteStations: remoteStations,
    localStations: localStations,
    controller: controller,
  ).start();
}

class _RemoteCatalogRefreshCoordinator {
  _RemoteCatalogRefreshCoordinator({
    required this.remoteStations,
    required this.localStations,
    required this.controller,
  });

  final RemoteJsonStationRepository remoteStations;
  final LocalStationsService localStations;
  final RadioAppController controller;

  List<String>? _lastCountryCodes;
  bool _isRefreshing = false;

  void start() {
    controller.addListener(_refreshWhenCountryCodesChange);
    _refreshWhenCountryCodesChange();
  }

  void _refreshWhenCountryCodesChange() {
    final countryCodes = _normalizedCountryCodes(controller.countryCodes);
    if (_sameStringValues(_lastCountryCodes, countryCodes) || _isRefreshing) {
      return;
    }

    _lastCountryCodes = countryCodes;
    _isRefreshing = true;
    unawaited(
      _refreshStationCatalog(
        remoteStations: remoteStations,
        localStations: localStations,
        controller: controller,
        countryCodes: countryCodes,
      ).whenComplete(() {
        _isRefreshing = false;
        _refreshWhenCountryCodesChange();
      }),
    );
  }
}

List<String> _normalizedCountryCodes(List<String> countryCodes) {
  return List<String>.unmodifiable(
    countryCodes
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false),
  );
}

Future<void> _refreshStationCatalog({
  required RemoteJsonStationRepository remoteStations,
  required LocalStationsService localStations,
  required RadioAppController controller,
  required List<String> countryCodes,
}) async {
  controller.markRemoteStationCatalogLoading(countryCodes: countryCodes);
  try {
    final response = await remoteStations.fetchCatalog(
      countryCodes: countryCodes,
    );
    controller.markRemoteStationCatalogResponse(
      statusCode: response.statusCode,
    );
    final parseResult = await localStations.replaceWithCatalogJson(
      response.body,
    );
    controller.markRemoteStationCatalogLoaded(
      objectCount: parseResult.objectCount,
      stationCount: parseResult.stations.length,
    );
    await controller.refreshDiscover();
  } catch (error) {
    controller.markRemoteStationCatalogFailed(error);
    // Keep using the cached or bundled station list.
  }
}

bool _sameStringValues(List<String>? first, List<String> second) {
  if (first == null || first.length != second.length) {
    return false;
  }
  for (var index = 0; index < first.length; index += 1) {
    if (first[index] != second[index]) {
      return false;
    }
  }
  return true;
}

Future<void> _deleteOversizedLegacyCatalogPreferences() async {
  if (!Platform.isAndroid) {
    return;
  }

  const maxReasonablePreferencesBytes = 8 * 1024 * 1024;
  const legacyPreferenceFiles = <String>[
    '/data/data/com.sedlan.noadsradio/shared_prefs/FlutterSharedPreferences.xml',
    '/data/user/0/com.sedlan.noadsradio/shared_prefs/FlutterSharedPreferences.xml',
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
