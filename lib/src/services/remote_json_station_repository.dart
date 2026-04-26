import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/radio_station.dart';
import 'catalog_station_repository.dart';

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

    final payload = jsonDecode(response.body);
    if (payload is! List<dynamic>) {
      throw const StationCatalogException(
        'Unexpected station catalog response.',
      );
    }

    _cachedStations = payload
        .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
        .where((station) => station.bestStreamUrl.isNotEmpty)
        .toList(growable: false);

    if (_cachedStations!.isEmpty) {
      throw const StationCatalogException('Station catalog is empty.');
    }

    return _cachedStations!;
  }
}
