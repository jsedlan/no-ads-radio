import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/radio_station.dart';
import '../models/search_query.dart';

class LocalStationsService {
  List<RadioStation> _stations = const <RadioStation>[];

  Future<void> initialize() async {
    try {
      final balkanData = await rootBundle.loadString(
        'assets/balkanradio_stations.json',
      );
      final exyuData = await rootBundle.loadString(
        'assets/exyuradio_stations.json',
      );

      final balkanList = jsonDecode(balkanData) as List<dynamic>;
      final exyuList = jsonDecode(exyuData) as List<dynamic>;

      _stations = [
        ...balkanList.map(
          (item) => RadioStation.fromScraperJson(item as Map<String, dynamic>),
        ),
        ...exyuList.map(
          (item) => RadioStation.fromScraperJson(item as Map<String, dynamic>),
        ),
      ];
    } catch (e) {
      // If assets fail to load, just start with empty local stations.
      _stations = const <RadioStation>[];
    }
  }

  List<RadioStation> get allStations => _stations;

  List<RadioStation> search(StationSearchQuery query, {int limit = 30}) {
    final nameLower = query.name.trim().toLowerCase();
    final tagLower = query.tag.trim().toLowerCase();
    final languageLower = query.language.trim().toLowerCase();
    final countryLower = query.countryCode.trim().toLowerCase();

    final filtered = _stations
        .where((station) {
          if (nameLower.isNotEmpty &&
              !station.name.toLowerCase().contains(nameLower)) {
            return false;
          }
          if (tagLower.isNotEmpty &&
              !station.tags.toLowerCase().contains(tagLower)) {
            return false;
          }
          if (languageLower.isNotEmpty &&
              !station.language.toLowerCase().contains(languageLower)) {
            return false;
          }
          if (countryLower.isNotEmpty) {
            final code = _mapScraperCountryToCode(station.country);
            if (code != countryLower) {
              return false;
            }
          }
          return true;
        })
        .toList(growable: false);

    return filtered.take(limit).toList(growable: false);
  }

  String _mapScraperCountryToCode(String country) {
    switch (country.toLowerCase()) {
      case 'bih':
      case 'bosna i hercegovina':
        return 'ba';
      case 'srbija':
        return 'rs';
      case 'hrvatska':
        return 'hr';
      case 'crna gora':
        return 'me';
      case 'makedonija':
      case 'severna makedonija':
        return 'mk';
      case 'slovenija':
        return 'si';
      case 'austria':
      case 'austrija':
        return 'at';
      case 'nemačka':
      case 'njemacka':
      case 'germany':
        return 'de';
      case 'švajcarska':
      case 'switzerland':
        return 'ch';
      default:
        return country.toLowerCase();
    }
  }
}
