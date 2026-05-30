import 'package:http/http.dart' as http;

import '../models/radio_station.dart';
import 'catalog_station_repository.dart';
import 'station_catalog_json.dart';

class RemoteJsonStationRepository extends CatalogStationRepository {
  RemoteJsonStationRepository({required String catalogUrl, http.Client? client})
    : _client = client ?? http.Client(),
      _catalogUri = Uri.parse(catalogUrl);

  static const String userAgent = 'no-ads-radio/1.0';

  final http.Client _client;
  final Uri _catalogUri;

  List<RadioStation>? _cachedStations;

  @override
  Future<List<RadioStation>> loadCatalog() async {
    if (_cachedStations != null) {
      return _cachedStations!;
    }

    _cachedStations = parseStationCatalogJson(await fetchCatalogJson());
    return _cachedStations!;
  }

  Future<String> fetchCatalogJson() async {
    final response = await _client.get(
      _catalogUri,
      headers: const <String, String>{
        'User-Agent': userAgent,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StationCatalogException(
        'Station catalog returned ${response.statusCode}.',
      );
    }

    return response.body;
  }
}
