import '../models/radio_station.dart';
import '../models/search_query.dart';
import 'station_repository.dart';

class FallbackStationRepository implements StationRepository {
  FallbackStationRepository(this._repositories);

  final List<StationRepository> _repositories;

  @override
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12}) {
    return _firstListResult(
      (repository) => repository.fetchRecentlyClicked(limit: limit),
    );
  }

  @override
  Future<List<RadioStation>> fetchTopClicked({int limit = 12}) {
    return _firstListResult(
      (repository) => repository.fetchTopClicked(limit: limit),
    );
  }

  @override
  Future<List<RadioStation>> fetchTopVoted({int limit = 12}) {
    return _firstListResult(
      (repository) => repository.fetchTopVoted(limit: limit),
    );
  }

  @override
  Future<String> resolveStreamUrl(String stationUuid) async {
    Object? lastError;
    for (final repository in _repositories) {
      try {
        final url = await repository.resolveStreamUrl(stationUuid);
        if (url.trim().isNotEmpty) {
          return url.trim();
        }
      } catch (error) {
        lastError = error;
      }
    }
    throw StationRepositoryFallbackException(
      'Unable to resolve a playable stream URL.',
      cause: lastError,
    );
  }

  @override
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  }) {
    return _firstListResult(
      (repository) => repository.searchStations(query, limit: limit),
    );
  }

  Future<List<RadioStation>> _firstListResult(
    Future<List<RadioStation>> Function(StationRepository repository) action,
  ) async {
    Object? lastError;
    for (final repository in _repositories) {
      try {
        final stations = await action(repository);
        if (stations.isNotEmpty) {
          return stations;
        }
      } catch (error) {
        lastError = error;
      }
    }
    throw StationRepositoryFallbackException(
      'Unable to load stations from any configured source.',
      cause: lastError,
    );
  }
}

class StationRepositoryFallbackException implements Exception {
  const StationRepositoryFallbackException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
