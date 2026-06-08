import 'dart:io';

import 'package:flutter/services.dart';

import '../models/radio_station.dart';
import 'station_catalog_diagnostics.dart';
import 'station_catalog_json.dart';

class LocalStationsService {
  LocalStationsService({File? cacheFile}) : _cacheFile = cacheFile;

  static const String _assetPath = 'assets/stationList.json';
  static const String _cacheFileName = 'no_ads_radio_station_catalog.json';

  List<RadioStation> _stations = const <RadioStation>[];
  final List<StationCatalogLoadEvent> _loadEvents = <StationCatalogLoadEvent>[];
  final File? _cacheFile;
  StationCatalogSource? _activeSource;

  Future<void> initialize() async {
    final cacheFile = _resolvedCacheFile;
    _record(
      StationCatalogSource.cache,
      StationCatalogEventStatus.loading,
      'Checking for a cached station catalog.',
    );
    if (await cacheFile.exists()) {
      try {
        final cachedCatalog = await cacheFile.readAsString();
        if (cachedCatalog.trim().isNotEmpty) {
          _stations = (await parseStationCatalogJsonInBackground(
            cachedCatalog,
          )).stations;
          _activeSource = StationCatalogSource.cache;
          _record(
            StationCatalogSource.cache,
            StationCatalogEventStatus.success,
            'Loaded cached stations. This source is now in use.',
            stationCount: _stations.length,
          );
          return;
        }
        _record(
          StationCatalogSource.cache,
          StationCatalogEventStatus.failure,
          'The cached catalog was empty.',
        );
      } catch (error) {
        _record(
          StationCatalogSource.cache,
          StationCatalogEventStatus.failure,
          'Could not load the cached catalog: $error',
        );
        await _deleteCacheFile(cacheFile);
      }
    } else {
      _record(
        StationCatalogSource.cache,
        StationCatalogEventStatus.info,
        'No cached catalog was found.',
      );
    }

    _record(
      StationCatalogSource.bundledAsset,
      StationCatalogEventStatus.loading,
      'Loading stations from $_assetPath.',
    );
    try {
      final stationData = await rootBundle.loadString(_assetPath);
      _stations = (await parseStationCatalogJsonInBackground(
        stationData,
      )).stations;
      _activeSource = StationCatalogSource.bundledAsset;
      _record(
        StationCatalogSource.bundledAsset,
        StationCatalogEventStatus.success,
        'Loaded bundled stations. This source is now in use.',
        stationCount: _stations.length,
      );
    } catch (error) {
      // If assets fail to load, just start with empty local stations.
      _stations = const <RadioStation>[];
      _record(
        StationCatalogSource.bundledAsset,
        StationCatalogEventStatus.failure,
        'Could not load the bundled catalog: $error',
      );
    }
  }

  Future<StationCatalogParseResult> replaceWithCatalogJson(
    String catalogJson,
  ) async {
    final parseResult = await parseStationCatalogJsonInBackground(catalogJson);
    await _resolvedCacheFile.writeAsString(catalogJson, flush: true);
    _stations = parseResult.stations;
    _activeSource = StationCatalogSource.sedlanGet;
    return parseResult;
  }

  List<RadioStation> get allStations => _stations;
  List<StationCatalogLoadEvent> get loadEvents =>
      List<StationCatalogLoadEvent>.unmodifiable(_loadEvents);
  StationCatalogSource? get activeSource => _activeSource;

  File get _resolvedCacheFile {
    return _cacheFile ??
        File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}$_cacheFileName',
        );
  }

  Future<void> _deleteCacheFile(File cacheFile) async {
    try {
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (_) {
      // Keep falling back to bundled stations.
    }
  }

  void _record(
    StationCatalogSource source,
    StationCatalogEventStatus status,
    String message, {
    int? stationCount,
  }) {
    _loadEvents.add(
      StationCatalogLoadEvent(
        timestamp: DateTime.now(),
        source: source,
        status: status,
        message: message,
        stationCount: stationCount,
      ),
    );
  }
}
