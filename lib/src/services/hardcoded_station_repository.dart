import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/radio_station.dart';
import 'catalog_station_repository.dart';

class HardcodedStationRepository extends CatalogStationRepository {
  static const String assetPath = 'assets/station_catalog_fallback.json';

  static const List<Map<String, dynamic>>
  _emergencyStationsJson = <Map<String, dynamic>>[
    <String, dynamic>{
      'stationuuid': 'hardcoded-055-radio',
      'name': '055 Radio',
      'url': 'http://ip.bijeljina.rs:9996/stream',
      'url_resolved': 'http://ip.bijeljina.rs:9996/stream',
      'homepage':
          'https://www.balkanradiostanice.com/radio-stanica-uzivo/296/055-radio/bih/',
      'favicon':
          'https://www.balkanradiostanice.com/radio-stanice-logo/balkan-radio-stanice-logo-stanica-320.svg',
      'tags': 'Narodna',
      'country': 'BiH',
      'countrycode': 'BA',
      'state': '',
      'language': '',
      'codec': 'audio/mpeg',
      'bitrate': 128,
      'votes': 1,
      'clickcount': 1,
      'clicktrend': 1,
      'lastcheckok': 1,
      'hls': 0,
      'is_scraped': 0,
    },
    <String, dynamic>{
      'stationuuid': 'hardcoded-kitt-radio',
      'name': 'Kitt Radio',
      'url': 'http://www.kittradio.at:7110/;',
      'url_resolved': 'http://www.kittradio.at:7110/;',
      'homepage': 'http://www.kittradio.at',
      'favicon': 'https://www.exyuradio.net/pub/catalog/kitt.jpg',
      'tags': 'zabavna,narodna',
      'country': 'BiH',
      'countrycode': 'BA',
      'state': 'Austria',
      'language': '',
      'codec': 'audio/mpeg',
      'bitrate': 128,
      'votes': 1,
      'clickcount': 1,
      'clicktrend': 1,
      'lastcheckok': 1,
      'hls': 0,
      'is_scraped': 0,
    },
    <String, dynamic>{
      'stationuuid': 'hardcoded-balkan-hip-hop-radio',
      'name': 'Balkan Hip-Hop Radio',
      'url': 'https://stream.zeno.fm/r4mpcrfwfzzuv',
      'url_resolved': 'https://stream.zeno.fm/r4mpcrfwfzzuv',
      'homepage': '',
      'favicon': '',
      'tags': 'hip hop,rap,balkan',
      'country': 'Serbia',
      'countrycode': 'RS',
      'state': '',
      'language': '',
      'codec': 'audio/mpeg',
      'bitrate': 128,
      'votes': 1,
      'clickcount': 1,
      'clicktrend': 1,
      'lastcheckok': 1,
      'hls': 0,
      'is_scraped': 0,
    },
  ];

  List<RadioStation>? _cachedStations;

  @override
  Future<List<RadioStation>> loadCatalog() async {
    if (_cachedStations != null) {
      return _cachedStations!;
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final payload = jsonDecode(raw);
      if (payload is List<dynamic>) {
        _cachedStations = payload
            .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
            .where((station) => station.bestStreamUrl.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      _cachedStations = null;
    }

    _cachedStations ??= _emergencyStationsJson
        .map(RadioStation.fromJson)
        .where((station) => station.bestStreamUrl.isNotEmpty)
        .toList(growable: false);

    return _cachedStations!;
  }
}
