import '../models/radio_station.dart';
import 'catalog_station_repository.dart';
import 'local_stations_service.dart';

class LocalCatalogStationRepository extends CatalogStationRepository {
  LocalCatalogStationRepository(this._service);

  final LocalStationsService _service;

  @override
  Future<List<RadioStation>> loadCatalog() async {
    return _service.allStations
        .where((station) => station.bestStreamUrl.isNotEmpty)
        .toList(growable: false);
  }
}
