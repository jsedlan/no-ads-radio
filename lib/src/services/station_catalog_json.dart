import 'dart:convert';

import '../models/radio_station.dart';
import 'catalog_station_repository.dart';

List<RadioStation> parseStationCatalogJson(String value) {
  final payload = jsonDecode(value);
  final stationsPayload = switch (payload) {
    List<dynamic>() => payload,
    {'stations': final List<dynamic> stations} => stations,
    _ => null,
  };
  if (stationsPayload == null) {
    throw const StationCatalogException('Unexpected station catalog response.');
  }

  final stations = stationsPayload
      .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
      .where((station) => station.bestStreamUrl.isNotEmpty)
      .toList(growable: false);

  if (stations.isEmpty) {
    throw const StationCatalogException('Station catalog is empty.');
  }

  return stations;
}
