import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/radio_station.dart';
import 'catalog_station_repository.dart';

class StationCatalogParseResult {
  const StationCatalogParseResult({
    required this.objectCount,
    required this.stations,
  });

  final int objectCount;
  final List<RadioStation> stations;
}

int countStationCatalogJsonObjects(String value) {
  return _stationCatalogPayload(value).length;
}

List<RadioStation> parseStationCatalogJson(String value) {
  return _parseStationCatalogJson(value).stations;
}

Future<StationCatalogParseResult> parseStationCatalogJsonInBackground(
  String value,
) {
  return compute(_parseStationCatalogJson, value);
}

StationCatalogParseResult _parseStationCatalogJson(String value) {
  final stationsPayload = _stationCatalogPayload(value);

  final stations = stationsPayload
      .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
      .where((station) => station.bestStreamUrl.isNotEmpty)
      .toList(growable: false);

  if (stations.isEmpty) {
    throw const StationCatalogException('Station catalog is empty.');
  }

  return StationCatalogParseResult(
    objectCount: stationsPayload.length,
    stations: stations,
  );
}

List<dynamic> _stationCatalogPayload(String value) {
  final payload = jsonDecode(value);
  final stationsPayload = switch (payload) {
    List<dynamic>() => payload,
    {'stations': final List<dynamic> stations} => stations,
    _ => null,
  };
  if (stationsPayload == null) {
    throw const StationCatalogException('Unexpected station catalog response.');
  }

  return stationsPayload;
}
