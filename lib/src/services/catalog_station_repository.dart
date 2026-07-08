import '../models/radio_station.dart';
import '../models/search_query.dart';
import 'station_repository.dart';

abstract class CatalogStationRepository
    implements
        StationRepository,
        CountryStationRepository,
        StationCatalogMetrics {
  Future<List<RadioStation>> loadCatalog();

  @override
  Future<int> countStations() async {
    return (await loadCatalog()).length;
  }

  @override
  Future<List<RadioStation>> fetchTopClicked({int limit = 12}) async {
    final stations = await loadCatalog();
    final ranked = List<RadioStation>.from(stations)
      ..sort((a, b) => _compareByMetric(b.clickCount, a.clickCount, b, a));
    return ranked.take(limit).toList(growable: false);
  }

  @override
  Future<List<RadioStation>> fetchTopVoted({int limit = 12}) async {
    final stations = await loadCatalog();
    final ranked = List<RadioStation>.from(stations)
      ..sort((a, b) => _compareByMetric(b.votes, a.votes, b, a));
    return ranked.take(limit).toList(growable: false);
  }

  @override
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12}) async {
    final stations = await loadCatalog();
    final ranked = List<RadioStation>.from(stations)
      ..sort((a, b) => _compareByMetric(b.clickTrend, a.clickTrend, b, a));
    return ranked.take(limit).toList(growable: false);
  }

  @override
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  }) async {
    final nameLower = query.name.trim().toLowerCase();
    final tagLower = query.tag.trim().toLowerCase();
    final languageLower = query.language.trim().toLowerCase();
    final countryLower = query.countryCode.trim().toLowerCase();

    final stations = await loadCatalog();
    final filtered = stations
        .where((station) {
          if (station.bestStreamUrl.isEmpty) {
            return false;
          }
          if (nameLower.isNotEmpty &&
              !station.displayName.toLowerCase().contains(nameLower)) {
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
            final stationCountry = station.countryCode.trim().toLowerCase();
            if (stationCountry != countryLower &&
                !station.isDiasporaForCountryCode(countryLower)) {
              return false;
            }
          }
          return true;
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final primary = _orderSearchResults(a, b, query.ordering.apiValue);
      if (primary != 0) {
        return primary;
      }
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return filtered.take(limit).toList(growable: false);
  }

  @override
  Future<List<RadioStation>> searchStationsForCountries(
    List<String> countryCodes, {
    int limit = 30,
  }) async {
    final normalizedCountryCodes = countryCodes
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalizedCountryCodes.isEmpty) {
      return searchStations(const StationSearchQuery(), limit: limit);
    }

    final stations = await loadCatalog();
    final stationsByCountry = <String, List<RadioStation>>{};
    final diasporaStations = <RadioStation>[];

    for (final station in stations) {
      if (station.bestStreamUrl.isEmpty) {
        continue;
      }
      if (station.isDiaspora) {
        diasporaStations.add(station);
        continue;
      }

      final stationCountryCode = station.countryCode.trim().toUpperCase();
      if (!normalizedCountryCodes.contains(stationCountryCode)) {
        continue;
      }
      stationsByCountry
          .putIfAbsent(stationCountryCode, () => <RadioStation>[])
          .add(station);
    }

    final orderedStations = <RadioStation>[];
    for (final countryCode in normalizedCountryCodes) {
      final countryStations = stationsByCountry[countryCode];
      if (countryStations == null) {
        continue;
      }
      countryStations.sort((a, b) {
        final primary = _orderSearchResults(
          a,
          b,
          StationOrdering.clickCount.apiValue,
        );
        if (primary != 0) {
          return primary;
        }
        return a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        );
      });
      orderedStations.addAll(countryStations);
    }

    if (normalizedCountryCodes.any(
      RadioStation.diasporaCountryCodes.contains,
    )) {
      diasporaStations.sort((a, b) {
        final primary = _orderSearchResults(
          a,
          b,
          StationOrdering.clickCount.apiValue,
        );
        if (primary != 0) {
          return primary;
        }
        return a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        );
      });
      orderedStations.addAll(diasporaStations);
    }

    return orderedStations.take(limit).toList(growable: false);
  }

  @override
  Future<String> resolveStreamUrl(String stationUuid) async {
    final stations = await loadCatalog();
    for (final station in stations) {
      if (station.stationUuid == stationUuid &&
          station.bestStreamUrl.isNotEmpty) {
        return station.bestStreamUrl;
      }
    }
    throw const StationCatalogException(
      'The station did not return a playable stream URL.',
    );
  }

  int _orderSearchResults(RadioStation a, RadioStation b, String ordering) {
    switch (ordering) {
      case 'votes':
        return b.votes.compareTo(a.votes);
      case 'clickcount':
        return b.clickCount.compareTo(a.clickCount);
      case 'clicktrend':
        return b.clickTrend.compareTo(a.clickTrend);
      case 'bitrate':
        return b.bitrate.compareTo(a.bitrate);
      case 'name':
      default:
        return a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        );
    }
  }

  int _compareByMetric(
    int leftMetric,
    int rightMetric,
    RadioStation left,
    RadioStation right,
  ) {
    final metricCompare = leftMetric.compareTo(rightMetric);
    if (metricCompare != 0) {
      return metricCompare;
    }
    return left.displayName.toLowerCase().compareTo(
      right.displayName.toLowerCase(),
    );
  }
}

class StationCatalogException implements Exception {
  const StationCatalogException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
