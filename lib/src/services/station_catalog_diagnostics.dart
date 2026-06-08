enum StationCatalogSource { cache, bundledAsset, sedlanGet }

extension StationCatalogSourceLabel on StationCatalogSource {
  String get label {
    switch (this) {
      case StationCatalogSource.cache:
        return 'Cached Sedlan catalog';
      case StationCatalogSource.bundledAsset:
        return 'Bundled station catalog';
      case StationCatalogSource.sedlanGet:
        return 'Sedlan GET';
    }
  }
}

enum StationCatalogEventStatus { loading, success, failure, info }

class StationCatalogLoadEvent {
  const StationCatalogLoadEvent({
    required this.timestamp,
    required this.source,
    required this.status,
    required this.message,
    this.stationCount,
  });

  final DateTime timestamp;
  final StationCatalogSource source;
  final StationCatalogEventStatus status;
  final String message;
  final int? stationCount;
}
