import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';
import 'station_catalog_json.dart';

class LocalStationsService {
  static const String _assetPath = 'assets/stationList.json';
  static const String _cachedCatalogKey = 'cached_station_catalog_json';

  List<RadioStation> _stations = const <RadioStation>[];

  Future<void> initialize({SharedPreferences? preferences}) async {
    final cachedCatalog = preferences?.getString(_cachedCatalogKey);
    if (cachedCatalog != null && cachedCatalog.trim().isNotEmpty) {
      try {
        _stations = parseStationCatalogJson(cachedCatalog);
        return;
      } catch (_) {
        await preferences?.remove(_cachedCatalogKey);
      }
    }

    try {
      final stationData = await rootBundle.loadString(_assetPath);
      _stations = parseStationCatalogJson(stationData);
    } catch (e) {
      // If assets fail to load, just start with empty local stations.
      _stations = const <RadioStation>[];
    }
  }

  Future<void> replaceWithCatalogJson(
    String catalogJson, {
    required SharedPreferences preferences,
  }) async {
    _stations = parseStationCatalogJson(catalogJson);
    await preferences.setString(_cachedCatalogKey, catalogJson);
  }

  List<RadioStation> get allStations => _stations;
}
