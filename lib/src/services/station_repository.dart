import '../models/radio_station.dart';
import '../models/search_query.dart';

abstract class StationRepository {
  Future<List<RadioStation>> fetchTopClicked({int limit = 12});
  Future<List<RadioStation>> fetchTopVoted({int limit = 12});
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12});
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  });
  Future<String> resolveStreamUrl(String stationUuid);
}

abstract interface class CountryStationRepository {
  Future<List<RadioStation>> searchStationsForCountries(
    List<String> countryCodes, {
    int limit = 30,
  });
}

abstract interface class StationCatalogMetrics {
  Future<int> countStations();
}
