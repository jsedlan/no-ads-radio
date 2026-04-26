import '../models/radio_station.dart';
import '../models/search_query.dart';
import 'station_repository.dart';

class StackedStationRepository implements StationRepository {
  StackedStationRepository({
    required StationRepository primary,
    required StationRepository secondary,
  }) : _primary = primary,
       _secondary = secondary;

  final StationRepository _primary;
  final StationRepository _secondary;

  @override
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12}) async {
    return _mergeAndLimit(
      await _primary.fetchRecentlyClicked(limit: limit),
      await _secondary.fetchRecentlyClicked(limit: limit),
      limit: limit,
    );
  }

  @override
  Future<List<RadioStation>> fetchTopClicked({int limit = 12}) async {
    return _mergeAndLimit(
      await _primary.fetchTopClicked(limit: limit),
      await _secondary.fetchTopClicked(limit: limit),
      limit: limit,
    );
  }

  @override
  Future<List<RadioStation>> fetchTopVoted({int limit = 12}) async {
    return _mergeAndLimit(
      await _primary.fetchTopVoted(limit: limit),
      await _secondary.fetchTopVoted(limit: limit),
      limit: limit,
    );
  }

  @override
  Future<String> resolveStreamUrl(String stationUuid) async {
    try {
      return await _primary.resolveStreamUrl(stationUuid);
    } catch (_) {
      return _secondary.resolveStreamUrl(stationUuid);
    }
  }

  @override
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  }) async {
    return _mergeAndLimit(
      await _primary.searchStations(query, limit: limit),
      await _secondary.searchStations(query, limit: limit),
      limit: limit,
    );
  }

  List<RadioStation> _mergeAndLimit(
    List<RadioStation> primary,
    List<RadioStation> secondary, {
    required int limit,
  }) {
    final merged = <RadioStation>[...primary, ...secondary];
    final seenIds = <String>{};
    final seenNames = <String>{};
    final result = <RadioStation>[];

    for (final station in merged) {
      final stationId = station.stationUuid.trim();
      final stationName = station.displayName.toLowerCase();
      if (stationId.isNotEmpty && seenIds.contains(stationId)) {
        continue;
      }
      if (seenNames.contains(stationName)) {
        continue;
      }
      if (stationId.isNotEmpty) {
        seenIds.add(stationId);
      }
      seenNames.add(stationName);
      result.add(station);
      if (result.length >= limit) {
        break;
      }
    }

    return result;
  }
}
