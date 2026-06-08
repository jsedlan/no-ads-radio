import 'dart:io';

import 'package:flutter/services.dart';

import '../models/radio_station.dart';
import 'station_catalog_json.dart';

class LocalStationsService {
  LocalStationsService({File? cacheFile}) : _cacheFile = cacheFile;

  static const String _assetPath = 'assets/stationList.json';
  static const String _cacheFileName = 'no_ads_radio_station_catalog.json';

  List<RadioStation> _stations = const <RadioStation>[];
  final File? _cacheFile;

  Future<void> initialize() async {
    final cacheFile = _resolvedCacheFile;
    if (await cacheFile.exists()) {
      try {
        final cachedCatalog = await cacheFile.readAsString();
        if (cachedCatalog.trim().isNotEmpty) {
          _stations = (await parseStationCatalogJsonInBackground(
            cachedCatalog,
          )).stations;
          return;
        }
      } catch (_) {
        await _deleteCacheFile(cacheFile);
      }
    }

    try {
      final stationData = await rootBundle.loadString(_assetPath);
      _stations = (await parseStationCatalogJsonInBackground(
        stationData,
      )).stations;
    } catch (e) {
      // If assets fail to load, just start with empty local stations.
      _stations = const <RadioStation>[];
    }
  }

  Future<int> replaceWithCatalogJson(String catalogJson) async {
    final parseResult = await parseStationCatalogJsonInBackground(catalogJson);
    _stations = parseResult.stations;
    await _resolvedCacheFile.writeAsString(catalogJson, flush: true);
    return parseResult.objectCount;
  }

  List<RadioStation> get allStations => _stations;

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
}
