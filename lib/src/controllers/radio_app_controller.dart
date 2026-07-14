import 'dart:async';

import 'package:flutter/foundation.dart';

import '../audio/audio_engine.dart';
import '../models/station_category.dart';
import '../models/radio_station.dart';
import '../models/search_query.dart';
import '../services/connectivity_service.dart';
import '../services/cast_service.dart';
import '../services/category_stations_store.dart';
import '../services/settings_store.dart';
import '../services/station_catalog_diagnostics.dart';
import '../services/station_repository.dart';

enum PlaybackStallReason { internetOutage, streamFailure }

enum DuplicateStationReason { stationUuid, nameLocation }

enum RemoteStationCatalogStatus { notLoaded, loading, loaded, failed }

class DuplicateStationInfo {
  const DuplicateStationInfo({
    required this.station,
    required this.originalStation,
    required this.reason,
  });

  final RadioStation station;
  final RadioStation originalStation;
  final DuplicateStationReason reason;
}

class _StationDeduplicationResult {
  const _StationDeduplicationResult({
    required this.stations,
    required this.duplicates,
  });

  final List<RadioStation> stations;
  final List<DuplicateStationInfo> duplicates;
}

class RemoteStationCatalogSnapshot {
  const RemoteStationCatalogSnapshot({
    required this.status,
    this.objectCount,
    this.errorMessage,
  });

  const RemoteStationCatalogSnapshot.notLoaded()
    : status = RemoteStationCatalogStatus.notLoaded,
      objectCount = null,
      errorMessage = null;

  final RemoteStationCatalogStatus status;
  final int? objectCount;
  final String? errorMessage;

  String get debugLabel {
    switch (status) {
      case RemoteStationCatalogStatus.notLoaded:
        return 'Not loaded yet';
      case RemoteStationCatalogStatus.loading:
        return 'Loading';
      case RemoteStationCatalogStatus.loaded:
        return objectCount?.toString() ?? 'Loaded';
      case RemoteStationCatalogStatus.failed:
        final message = errorMessage?.trim();
        return message == null || message.isEmpty
            ? 'Failed'
            : 'Failed: $message';
    }
  }
}

class RadioAppController extends ChangeNotifier {
  RadioAppController._({
    required StationRepository repository,
    required CategoryStationsStore categoryStationsStore,
    required SettingsStore settingsStore,
    required AudioEngine audioEngine,
    required CastService castService,
    required ConnectivityService connectivityService,
    required String startupCountryCode,
    required Duration playbackStallThreshold,
    required Duration playbackStallPollInterval,
    required Duration streamRecoveryRetryInterval,
    required Duration streamRecoveryWindow,
    required List<StationCatalogLoadEvent> initialCatalogLoadEvents,
    required StationCatalogSource? initialActiveCatalogSource,
  }) : _repository = repository,
       _categoryStationsStore = categoryStationsStore,
       _settingsStore = settingsStore,
       _audioEngine = audioEngine,
       _castService = castService,
       _connectivityService = connectivityService,
       _startupCountryCode = startupCountryCode,
       _playbackStallThreshold = playbackStallThreshold,
       _playbackStallPollInterval = playbackStallPollInterval,
       _streamRecoveryRetryInterval = streamRecoveryRetryInterval,
       _streamRecoveryWindow = streamRecoveryWindow,
       catalogLoadEvents = List<StationCatalogLoadEvent>.from(
         initialCatalogLoadEvents,
       ),
       activeCatalogSource = initialActiveCatalogSource {
    _audioEngine.snapshot.addListener(_handlePlaybackSnapshot);
    _castService.snapshot.addListener(_handleCastSnapshot);
    _connectivityService.snapshot.addListener(_handleConnectivitySnapshot);
  }

  static Future<RadioAppController> bootstrap({
    required StationRepository repository,
    required CategoryStationsStore categoryStationsStore,
    required SettingsStore settingsStore,
    required AudioEngine audioEngine,
    CastService? castService,
    required ConnectivityService connectivityService,
    String startupCountryCode = '',
    Duration playbackStallThreshold = const Duration(seconds: 8),
    Duration playbackStallPollInterval = const Duration(seconds: 1),
    Duration streamRecoveryRetryInterval = const Duration(seconds: 5),
    Duration streamRecoveryWindow = const Duration(seconds: 30),
    List<StationCatalogLoadEvent> initialCatalogLoadEvents =
        const <StationCatalogLoadEvent>[],
    StationCatalogSource? initialActiveCatalogSource,
  }) async {
    final controller = RadioAppController._(
      repository: repository,
      categoryStationsStore: categoryStationsStore,
      settingsStore: settingsStore,
      audioEngine: audioEngine,
      castService: castService ?? DisabledCastService(),
      connectivityService: connectivityService,
      startupCountryCode: startupCountryCode,
      playbackStallThreshold: playbackStallThreshold,
      playbackStallPollInterval: playbackStallPollInterval,
      streamRecoveryRetryInterval: streamRecoveryRetryInterval,
      streamRecoveryWindow: streamRecoveryWindow,
      initialCatalogLoadEvents: initialCatalogLoadEvents,
      initialActiveCatalogSource: initialActiveCatalogSource,
    );
    await controller._initialize();
    return controller;
  }

  final StationRepository _repository;
  final CategoryStationsStore _categoryStationsStore;
  final SettingsStore _settingsStore;
  final AudioEngine _audioEngine;
  final CastService _castService;
  final ConnectivityService _connectivityService;
  final String _startupCountryCode;
  final Duration _playbackStallThreshold;
  final Duration _playbackStallPollInterval;
  final Duration _streamRecoveryRetryInterval;
  final Duration _streamRecoveryWindow;
  static const Duration _internetRetryInterval = Duration(seconds: 5);
  static const List<Duration> sleepTimerOptions = <Duration>[
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
  ];
  static const int _recentlyPlayedLimit = 50;

  List<RadioStation> discoverStations = const <RadioStation>[];
  bool hasCompletedCountrySetup = true;
  List<RadioStation> searchResults = const <RadioStation>[];
  List<RadioStation> manualStations = const <RadioStation>[];
  List<RadioStation> recentlyPlayedStations = const <RadioStation>[];
  List<DuplicateStationInfo> duplicateStations = const <DuplicateStationInfo>[];
  int loadedStationCount = 0;
  final List<StationCatalogLoadEvent> catalogLoadEvents;
  StationCatalogSource? activeCatalogSource;
  RemoteStationCatalogSnapshot remoteStationCatalog =
      const RemoteStationCatalogSnapshot.notLoaded();
  Map<String, List<RadioStation>> stationsByCategory =
      const <String, List<RadioStation>>{};

  bool isBootstrapping = true;
  bool isRefreshingDiscover = false;
  bool isSearching = false;
  String? discoverError;
  String? searchError;
  String? categoriesError;
  String discoverFilter = '';
  AppThemePreference themePreference = AppThemePreference.dark;
  AppLanguagePreference languagePreference = AppLanguagePreference.system;
  bool showStationIcon = false;
  bool autoPlayNextCategoryStation = true;
  List<String> countryCodes = const <String>[];
  List<StationCategory> stationCategories = const <StationCategory>[
    StationCategory(id: 'category-0-saved', name: 'Saved'),
  ];

  StationSearchQuery activeSearchQuery = const StationSearchQuery();
  RadioStation? currentStation;
  PlaybackSnapshot playback = const PlaybackSnapshot.idle();
  CastSnapshot casting = const CastSnapshot.unavailable();
  ConnectivitySnapshot connectivity = const ConnectivitySnapshot.unknown();
  bool playbackStalled = false;
  PlaybackStallReason? playbackStallReason;
  DateTime? sleepTimerEndsAt;
  int selectedTab = 0;
  int _activeStationCategoryIndex = 0;
  String _activeStationCategoryId = '';

  bool get isOffline => connectivity.isOffline;
  bool get isCasting => casting.isConnected;
  bool get isSleepTimerActive => sleepTimerEndsAt != null;
  Duration get sleepTimerRemaining {
    final endsAt = sleepTimerEndsAt;
    if (endsAt == null) {
      return Duration.zero;
    }
    final remaining = endsAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  bool get canAutoPlayNextCategoryStation => stationCategories.any(
    (category) => stationsForCategory(category.id).length >= 2,
  );
  StationCategory get activeStationCategory {
    if (stationCategories.isEmpty) {
      return const StationCategory(id: 'category-0-saved', name: 'Saved');
    }
    final activeCategory = stationCategories
        .where((category) => category.id == _activeStationCategoryId)
        .firstOrNull;
    if (activeCategory != null) {
      return activeCategory;
    }
    final index = _activeStationCategoryIndex.clamp(
      0,
      stationCategories.length - 1,
    );
    return stationCategories[index];
  }

  String get activeStationCategoryId => activeStationCategory.id;

  List<RadioStation> get savedStations =>
      stationsForCategory(activeStationCategoryId);

  bool get canPlayAdjacentCategoryStation {
    final station = currentStation;
    if (station == null) {
      return false;
    }
    final categoryId = _categoryIdForStation(station);
    return categoryId != null && stationsForCategory(categoryId).length >= 2;
  }

  Timer? _playbackStallTimer;
  Timer? _internetRetryTimer;
  Timer? _streamRecoveryRetryTimer;
  Timer? _simulatedStallTimer;
  Timer? _sleepTimer;
  Duration _lastObservedPosition = Duration.zero;
  Duration _lastObservedBufferedPosition = Duration.zero;
  DateTime? _lastPositionAdvancedAt;
  bool _isHandlingPlaybackStall = false;
  bool _isRetryingCurrentStation = false;
  bool _isRetryingStreamFailure = false;
  DateTime? _streamRecoveryStartedAt;
  String? _streamRecoveryStationKey;
  String? _currentStreamUrl;

  Future<void> _initialize() async {
    try {
      try {
        await _castService.initialize();
        casting = _castService.snapshot.value;
      } catch (_) {
        casting = const CastSnapshot.unavailable();
      }
      await _connectivityService.initialize();
      connectivity = _connectivityService.snapshot.value;
      stationsByCategory = await _categoryStationsStore
          .loadStationsByCategory();
      final settings = await _settingsStore.loadSettings();
      themePreference = settings.themePreference;
      languagePreference = settings.languagePreference;
      showStationIcon = settings.showStationIcon;
      autoPlayNextCategoryStation = settings.autoPlayNextCategoryStation;
      countryCodes = settings.countryCodes;
      hasCompletedCountrySetup = settings.hasCompletedCountrySetup;
      manualStations = settings.manualStations;
      recentlyPlayedStations = settings.recentlyPlayedStations;
      stationCategories = settings.stationCategories.isEmpty
          ? const <StationCategory>[
              StationCategory(id: 'category-0-saved', name: 'Saved'),
            ]
          : settings.stationCategories;
      _activeStationCategoryId = settings.activeStationCategoryId;
      _syncStationCategoriesWithSavedData();
      await refreshDiscover();
      if (allCategorizedStations.isEmpty) {
        searchResults = discoverStations.take(6).toList(growable: false);
      }
    } catch (error) {
      discoverError = _errorMessage(error);
    } finally {
      isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> refreshDiscover() async {
    discoverError = null;
    isRefreshingDiscover = true;
    notifyListeners();

    try {
      final catalogStationCount = await _catalogStationCount();
      discoverStations = await _loadDiscoverStations();
      loadedStationCount = catalogStationCount ?? discoverStations.length;
    } catch (error) {
      discoverError = _errorMessage(error);
      discoverStations = const <RadioStation>[];
      duplicateStations = const <DuplicateStationInfo>[];
      loadedStationCount = 0;
    } finally {
      isRefreshingDiscover = false;
      notifyListeners();
    }
  }

  void markRemoteStationCatalogLoading({
    List<String> countryCodes = const <String>[],
  }) {
    final normalizedCountryCodes = countryCodes
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final query = normalizedCountryCodes.isEmpty
        ? ''
        : '?${normalizedCountryCodes.map((code) => 'country=$code').join('&')}';
    _recordCatalogLoadEvent(
      source: StationCatalogSource.sedlanGet,
      status: StationCatalogEventStatus.loading,
      message: 'GET https://api.noadsradio.sedlan.com/stations$query started.',
    );
    remoteStationCatalog = const RemoteStationCatalogSnapshot(
      status: RemoteStationCatalogStatus.loading,
    );
    notifyListeners();
  }

  void markRemoteStationCatalogResponse({required int statusCode}) {
    _recordCatalogLoadEvent(
      source: StationCatalogSource.sedlanGet,
      status: StationCatalogEventStatus.success,
      message: 'GET succeeded with HTTP $statusCode.',
    );
    notifyListeners();
  }

  void markRemoteStationCatalogLoaded({
    required int objectCount,
    required int stationCount,
  }) {
    _connectivityService.reportOnline();
    activeCatalogSource = StationCatalogSource.sedlanGet;
    _recordCatalogLoadEvent(
      source: StationCatalogSource.sedlanGet,
      status: StationCatalogEventStatus.success,
      message:
          '$objectCount catalog objects received and parsed. '
          'This source is now in use.',
      stationCount: stationCount,
    );
    remoteStationCatalog = RemoteStationCatalogSnapshot(
      status: RemoteStationCatalogStatus.loaded,
      objectCount: objectCount,
    );
    notifyListeners();
  }

  void markRemoteStationCatalogFailed(Object error) {
    _recordCatalogLoadEvent(
      source: StationCatalogSource.sedlanGet,
      status: StationCatalogEventStatus.failure,
      message:
          'Sedlan refresh failed: ${_errorMessage(error)} '
          'Continuing with ${activeCatalogSource?.label ?? 'no catalog source'}.',
    );
    remoteStationCatalog = RemoteStationCatalogSnapshot(
      status: RemoteStationCatalogStatus.failed,
      errorMessage: _errorMessage(error),
    );
    notifyListeners();
  }

  void _recordCatalogLoadEvent({
    required StationCatalogSource source,
    required StationCatalogEventStatus status,
    required String message,
    int? stationCount,
  }) {
    catalogLoadEvents.add(
      StationCatalogLoadEvent(
        timestamp: DateTime.now(),
        source: source,
        status: status,
        message: message,
        stationCount: stationCount,
      ),
    );
  }

  Future<List<RadioStation>> _loadDiscoverStations() async {
    final stations = <RadioStation>[...manualStations];
    if (countryCodes.isEmpty) {
      stations.addAll(
        await _repository.searchStations(
          const StationSearchQuery(),
          limit: 5000,
        ),
      );
      return _deduplicateDiscoverStations(stations);
    }

    final repository = _repository;
    if (repository is CountryStationRepository) {
      stations.addAll(
        await (repository as CountryStationRepository)
            .searchStationsForCountries(countryCodes, limit: 5000),
      );
      return _deduplicateDiscoverStations(stations);
    }

    for (final countryCode in countryCodes) {
      stations.addAll(
        await _repository.searchStations(
          StationSearchQuery(countryCode: countryCode),
          limit: 5000,
        ),
      );
    }
    return _deduplicateDiscoverStations(stations);
  }

  Future<int?> _catalogStationCount() async {
    final repository = _repository;
    if (repository is StationCatalogMetrics) {
      return (repository as StationCatalogMetrics).countStations();
    }
    return null;
  }

  List<RadioStation> _deduplicateDiscoverStations(List<RadioStation> stations) {
    final result = _deduplicateStations(stations);
    duplicateStations = List<DuplicateStationInfo>.unmodifiable(
      result.duplicates,
    );
    return result.stations;
  }

  _StationDeduplicationResult _deduplicateStations(
    List<RadioStation> stations,
  ) {
    final seenIds = <String>{};
    final stationsById = <String, RadioStation>{};
    final seenNameLocations = <String>{};
    final stationsByNameLocation = <String, RadioStation>{};
    final result = <RadioStation>[];
    final duplicates = <DuplicateStationInfo>[];

    for (final station in stations) {
      final stationId = station.stationUuid.trim();
      final stationNameLocation =
          '${station.displayName.toLowerCase()}|'
          '${station.displayLocation.toLowerCase()}';
      if (stationId.isNotEmpty && seenIds.contains(stationId)) {
        duplicates.add(
          DuplicateStationInfo(
            station: station,
            originalStation: stationsById[stationId]!,
            reason: DuplicateStationReason.stationUuid,
          ),
        );
        continue;
      }
      if (seenNameLocations.contains(stationNameLocation)) {
        duplicates.add(
          DuplicateStationInfo(
            station: station,
            originalStation: stationsByNameLocation[stationNameLocation]!,
            reason: DuplicateStationReason.nameLocation,
          ),
        );
        continue;
      }
      if (stationId.isNotEmpty) {
        seenIds.add(stationId);
        stationsById[stationId] = station;
      }
      seenNameLocations.add(stationNameLocation);
      stationsByNameLocation[stationNameLocation] = station;
      result.add(station);
    }

    return _StationDeduplicationResult(
      stations: List<RadioStation>.unmodifiable(result),
      duplicates: List<DuplicateStationInfo>.unmodifiable(duplicates),
    );
  }

  bool _sameStringValues(List<String> first, List<String> second) {
    if (first.length != second.length) {
      return false;
    }
    for (var index = 0; index < first.length; index += 1) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }

  List<RadioStation> stationsForCategory(String categoryId) {
    return List<RadioStation>.unmodifiable(
      stationsByCategory[categoryId] ?? const <RadioStation>[],
    );
  }

  List<RadioStation> get allCategorizedStations => stationCategories
      .expand((category) => stationsForCategory(category.id))
      .toList(growable: false);

  String _normalizedStationCategoryId(String? categoryId) {
    final normalized = categoryId?.trim();
    if (normalized != null &&
        normalized.isNotEmpty &&
        stationCategories.any((category) => category.id == normalized)) {
      return normalized;
    }
    return activeStationCategoryId;
  }

  void _syncStationCategoriesWithSavedData() {
    final nextMap = <String, List<RadioStation>>{};
    for (final category in stationCategories) {
      nextMap[category.id] = List<RadioStation>.unmodifiable(
        stationsByCategory[category.id] ??
            stationsByCategory[category.name] ??
            const <RadioStation>[],
      );
    }
    stationsByCategory = Map<String, List<RadioStation>>.unmodifiable(nextMap);
    if (_activeStationCategoryIndex >= stationCategories.length) {
      _activeStationCategoryIndex = stationCategories.isEmpty
          ? 0
          : stationCategories.length - 1;
    }
    _syncActiveStationCategory();
    _syncSelectedTabWithCategoriesTab();
  }

  void _syncActiveStationCategory() {
    if (stationCategories.isEmpty) {
      _activeStationCategoryIndex = 0;
      _activeStationCategoryId = '';
      return;
    }

    final activeIndex = stationCategories.indexWhere(
      (category) => category.id == _activeStationCategoryId,
    );
    if (activeIndex >= 0) {
      _activeStationCategoryIndex = activeIndex;
      return;
    }

    if (_activeStationCategoryIndex >= stationCategories.length) {
      _activeStationCategoryIndex = stationCategories.length - 1;
    }
    _activeStationCategoryId =
        stationCategories[_activeStationCategoryIndex].id;
  }

  void _syncSelectedTabWithCategoriesTab() {
    if (selectedTab > 1) {
      selectedTab = 1;
    }
  }

  Map<String, List<RadioStation>> _withCategoryStations(
    String categoryId,
    List<RadioStation> stations,
  ) {
    final nextMap = Map<String, List<RadioStation>>.from(stationsByCategory);
    nextMap[categoryId] = List<RadioStation>.unmodifiable(stations);
    return Map<String, List<RadioStation>>.unmodifiable(nextMap);
  }

  Map<String, List<RadioStation>> _remapStationsByCategory(
    List<StationCategory> previousCategories,
    List<StationCategory> nextCategories,
  ) {
    final remapped = <String, List<RadioStation>>{};
    for (var index = 0; index < nextCategories.length; index += 1) {
      final nextCategory = nextCategories[index];
      final previousCategory = previousCategories
          .where((category) => category.id == nextCategory.id)
          .firstOrNull;
      final fallbackCategory = index < previousCategories.length
          ? previousCategories[index]
          : null;
      remapped[nextCategory.id] = List<RadioStation>.unmodifiable(
        previousCategory == null && fallbackCategory == null
            ? const <RadioStation>[]
            : (stationsByCategory[previousCategory?.id] ??
                  stationsByCategory[previousCategory?.name] ??
                  stationsByCategory[fallbackCategory?.id] ??
                  stationsByCategory[fallbackCategory?.name] ??
                  const <RadioStation>[]),
      );
    }
    return Map<String, List<RadioStation>>.unmodifiable(remapped);
  }

  String? _categoryIdForStation(RadioStation station) {
    for (final category in stationCategories) {
      if (stationsForCategory(
        category.id,
      ).any((item) => item.identityKey == station.identityKey)) {
        return category.id;
      }
    }
    return null;
  }

  Future<void> runSearch(StationSearchQuery query) async {
    activeSearchQuery = query;
    searchError = null;
    isSearching = true;
    notifyListeners();

    try {
      searchResults = await _repository.searchStations(query);
    } catch (error) {
      searchError = _errorMessage(error);
      searchResults = const <RadioStation>[];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> toggleStationInCategory(
    RadioStation station, {
    String? categoryId,
  }) async {
    categoriesError = null;
    final targetCategory = _normalizedStationCategoryId(categoryId);
    final currentCategoryStations = List<RadioStation>.from(
      stationsForCategory(targetCategory),
    );
    final existingIndex = currentCategoryStations.indexWhere(
      (item) => item.identityKey == station.identityKey,
    );

    if (existingIndex >= 0) {
      currentCategoryStations.removeAt(existingIndex);
    } else {
      currentCategoryStations.insert(0, station);
    }

    stationsByCategory = _withCategoryStations(
      targetCategory,
      currentCategoryStations,
    );
    notifyListeners();

    try {
      await _categoryStationsStore.saveStationsByCategory(stationsByCategory);
    } catch (error) {
      categoriesError = _errorMessage(error);
      notifyListeners();
    }
  }

  Future<void> reorderCategoryStations({
    required String categoryId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final targetCategory = _normalizedStationCategoryId(categoryId);
    final currentCategoryStations = List<RadioStation>.from(
      stationsForCategory(targetCategory),
    );
    if (oldIndex < 0 ||
        oldIndex >= currentCategoryStations.length ||
        newIndex < 0 ||
        newIndex > currentCategoryStations.length) {
      return;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) {
      return;
    }

    final movedStation = currentCategoryStations.removeAt(oldIndex);
    currentCategoryStations.insert(newIndex, movedStation);
    stationsByCategory = _withCategoryStations(
      targetCategory,
      currentCategoryStations,
    );
    notifyListeners();

    try {
      await _categoryStationsStore.saveStationsByCategory(stationsByCategory);
    } catch (error) {
      categoriesError = _errorMessage(error);
      notifyListeners();
    }
  }

  bool isStationInCategory(String stationUuid, {String? categoryId}) {
    if (categoryId == null) {
      return stationCategories.any(
        (category) => stationsForCategory(
          category.id,
        ).any((station) => station.identityKey == stationUuid),
      );
    }

    return stationsForCategory(
      _normalizedStationCategoryId(categoryId),
    ).any((station) => station.identityKey == stationUuid);
  }

  Future<void> playStation(
    RadioStation station, {
    bool fromInternetRecoveryRetry = false,
    bool fromStreamRecoveryRetry = false,
  }) async {
    if (!fromInternetRecoveryRetry && !fromStreamRecoveryRetry) {
      _stopInternetRecoveryRetryLoop();
      _stopStreamRecoveryRetryLoop();
    }
    currentStation = station;
    playbackStalled = false;
    playbackStallReason = null;
    _isHandlingPlaybackStall = false;
    _simulatedStallTimer?.cancel();
    _lastObservedPosition = Duration.zero;
    _lastObservedBufferedPosition = Duration.zero;
    _lastPositionAdvancedAt = null;
    playback = const PlaybackSnapshot(status: PlaybackStatus.loading);
    notifyListeners();

    try {
      final url = station.bestStreamUrl.isNotEmpty
          ? station.bestStreamUrl
          : await _repository.resolveStreamUrl(station.stationUuid);
      _currentStreamUrl = url;
      if (isCasting) {
        await _loadStationOnCast(station, url);
      } else {
        await _audioEngine.playStream(
          url,
          metadata: PlaybackMediaMetadata(
            id: station.stationUuid,
            title: station.displayName,
            album: station.displayLocation.isEmpty
                ? 'NoAds Radio'
                : station.displayLocation,
            artUri: station.hasArtwork
                ? Uri.tryParse(station.favicon.trim())
                : null,
          ),
        );
      }
      await _handleImmediateRetryPlaybackFailureIfNeeded(
        station,
        fromInternetRecoveryRetry: fromInternetRecoveryRetry,
      );
      if (!playback.hasError && !fromStreamRecoveryRetry) {
        await _recordRecentlyPlayed(station);
      }
    } catch (error) {
      playback = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: _errorMessage(error),
      );
      notifyListeners();
      await _handleImmediateRetryPlaybackFailureIfNeeded(
        station,
        fromInternetRecoveryRetry: fromInternetRecoveryRetry,
      );
    }
  }

  Future<void> resumePlayback() async {
    try {
      if (isCasting) {
        await _castService.resume();
      } else {
        await _audioEngine.resume();
      }
    } catch (error) {
      playback = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: _errorMessage(error),
      );
      notifyListeners();
    }
  }

  Future<void> pausePlayback() async {
    _stopInternetRecoveryRetryLoop();
    _stopStreamRecoveryRetryLoop();
    try {
      if (isCasting) {
        await _castService.pause();
      } else {
        await _audioEngine.pause();
      }
    } catch (error) {
      playback = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: _errorMessage(error),
      );
      notifyListeners();
    }
  }

  Future<void> playPreviousCategoryStation() async {
    final previous = _previousCategoryStationFor(currentStation);
    if (previous == null) {
      return;
    }
    await playStation(previous);
  }

  Future<void> playNextCategoryStation() async {
    final next = _nextCategoryStationFor(currentStation);
    if (next == null) {
      return;
    }
    await playStation(next);
  }

  Future<void> stopPlayback() async {
    _cancelSleepTimer(notify: false);
    _stopInternetRecoveryRetryLoop();
    _stopStreamRecoveryRetryLoop();
    if (isCasting) {
      await _castService.stop();
    }
    await _audioEngine.stop();
    currentStation = null;
    _currentStreamUrl = null;
    _stopPlaybackStallWatchdog();
    playback = const PlaybackSnapshot.idle();
    notifyListeners();
  }

  Future<void> startCastDiscovery() => _castService.startDiscovery();

  Future<void> stopCastDiscovery() => _castService.stopDiscovery();

  Future<void> connectToCastDevice(CastDevice device) async {
    final wasPlayingLocally = playback.isPlaying && !isCasting;
    await _castService.connect(device);
    final station = currentStation;
    if (station == null) {
      return;
    }

    final url = _currentStreamUrl ?? station.bestStreamUrl;
    if (url.isEmpty) {
      await _castService.disconnect();
      throw StateError('The current station has no playable stream URL.');
    }
    try {
      if (wasPlayingLocally) {
        await _audioEngine.pause();
      }
      await _loadStationOnCast(station, url);
    } catch (_) {
      await _castService.disconnect();
      if (wasPlayingLocally) {
        await _audioEngine.resume();
      }
      playback = _audioEngine.snapshot.value;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnectFromCast() async {
    await _castService.disconnect();
    if (currentStation != null) {
      playback = PlaybackSnapshot(
        status: PlaybackStatus.paused,
        nowPlaying: playback.nowPlaying,
      );
      notifyListeners();
    }
  }

  Future<void> _loadStationOnCast(RadioStation station, String url) async {
    await _castService.load(
      CastMedia(
        url: url,
        title: station.displayName,
        album: station.displayLocation.isEmpty
            ? 'NoAds Radio'
            : station.displayLocation,
        artUri: station.hasArtwork
            ? Uri.tryParse(station.favicon.trim())
            : null,
        contentType: _castContentType(station, url),
      ),
    );
  }

  String _castContentType(RadioStation station, String url) {
    if (station.hls || url.toLowerCase().contains('.m3u8')) {
      return 'application/x-mpegURL';
    }
    return switch (station.codec.trim().toLowerCase()) {
      'aac' || 'aac+' || 'heaac' => 'audio/aac',
      'ogg' || 'opus' => 'audio/ogg',
      'flac' => 'audio/flac',
      'wav' => 'audio/wav',
      _ => 'audio/mpeg',
    };
  }

  void setSleepTimer(Duration? duration) {
    _cancelSleepTimer(notify: false);
    if (duration == null || duration <= Duration.zero) {
      notifyListeners();
      return;
    }

    sleepTimerEndsAt = DateTime.now().add(duration);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = sleepTimerRemaining;
      if (remaining <= Duration.zero) {
        unawaited(_handleSleepTimerFinished());
        return;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _cancelSleepTimer();
  }

  void _cancelSleepTimer({bool notify = true}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepTimerEndsAt = null;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _handleSleepTimerFinished() async {
    if (_sleepTimer == null && sleepTimerEndsAt == null) {
      return;
    }

    _cancelSleepTimer(notify: false);
    await stopPlayback();
  }

  void selectTab(int value) {
    selectedTab = value.clamp(0, 1).toInt();
    notifyListeners();
  }

  Future<void> selectStationCategory(String categoryId) async {
    final index = stationCategories.indexWhere(
      (category) => category.id == categoryId,
    );
    if (index < 0) {
      return;
    }

    selectedTab = 1;
    _activeStationCategoryIndex = index;
    _activeStationCategoryId = stationCategories[index].id;
    notifyListeners();
    await _saveSettings();
  }

  void setDiscoverFilter(String value) {
    final normalized = value.trim();
    if (discoverFilter == normalized) {
      return;
    }
    discoverFilter = normalized;
    notifyListeners();
  }

  Future<void> setShowStationIcon(bool value) async {
    showStationIcon = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setThemePreference(AppThemePreference value) async {
    if (themePreference == value) {
      return;
    }
    themePreference = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setLanguagePreference(AppLanguagePreference value) async {
    if (languagePreference == value) {
      return;
    }
    languagePreference = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setAutoPlayNextCategoryStation(bool value) async {
    autoPlayNextCategoryStation = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setCountryCodes(List<String> values) async {
    final normalizedCountryCodes = List<String>.unmodifiable(
      values
          .map((value) => value.trim().toUpperCase())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
    if (_sameStringValues(countryCodes, normalizedCountryCodes)) {
      return;
    }
    countryCodes = normalizedCountryCodes;
    isRefreshingDiscover = true;
    notifyListeners();

    try {
      discoverStations = await _loadDiscoverStations();
      discoverError = null;
      await _saveSettings();
    } catch (error) {
      discoverError = _errorMessage(error);
    } finally {
      isRefreshingDiscover = false;
      notifyListeners();
    }
  }

  String get suggestedCountryCode {
    if (countryCodes.isNotEmpty) {
      return countryCodes.first.trim().toUpperCase();
    }
    return _startupCountryCode.trim().toUpperCase();
  }

  Future<void> completeCountrySetup(String countryCode) async {
    final normalized = countryCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      return;
    }
    countryCodes = List<String>.unmodifiable(<String>[normalized]);
    hasCompletedCountrySetup = true;
    discoverStations = await _loadDiscoverStations();
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setStationCategories(List<String> values) async {
    final previousCategories = stationCategories;
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final categoryNames = normalized.isEmpty
        ? const <String>['Saved']
        : normalized;
    stationCategories = List<StationCategory>.unmodifiable(
      List<StationCategory>.generate(categoryNames.length, (index) {
        if (index < previousCategories.length) {
          return previousCategories[index].copyWith(name: categoryNames[index]);
        }
        return StationCategory(
          id: 'category-${DateTime.now().microsecondsSinceEpoch}-$index',
          name: categoryNames[index],
        );
      }),
    );
    stationsByCategory = _remapStationsByCategory(
      previousCategories,
      stationCategories,
    );
    _syncStationCategoriesWithSavedData();
    notifyListeners();
    await _saveSettings();
    await _categoryStationsStore.saveStationsByCategory(stationsByCategory);
  }

  Future<void> setStationCategoryItems(List<StationCategory> values) async {
    final previousCategories = stationCategories;
    final normalized = values
        .map((category) => category.copyWith(name: category.name.trim()))
        .where((category) => category.name.isNotEmpty)
        .toList(growable: false);
    stationCategories = List<StationCategory>.unmodifiable(
      normalized.isEmpty
          ? const <StationCategory>[
              StationCategory(id: 'category-0-saved', name: 'Saved'),
            ]
          : normalized,
    );
    stationsByCategory = _remapStationsByCategory(
      previousCategories,
      stationCategories,
    );
    _syncStationCategoriesWithSavedData();
    notifyListeners();
    await _saveSettings();
    await _categoryStationsStore.saveStationsByCategory(stationsByCategory);
  }

  Future<void> addManualStation({
    required String name,
    required String streamUrl,
  }) async {
    final trimmedName = name.trim();
    final trimmedStreamUrl = streamUrl.trim();
    if (trimmedName.isEmpty || trimmedStreamUrl.isEmpty) {
      return;
    }

    final station = RadioStation(
      stationUuid: 'manual-${DateTime.now().microsecondsSinceEpoch}',
      name: trimmedName,
      url: trimmedStreamUrl,
      urlResolved: trimmedStreamUrl,
      homepage: '',
      favicon: '',
      tags: 'Manual',
      country: '',
      countryCode: countryCodes.isEmpty ? '' : countryCodes.first,
      state: '',
      language: '',
      codec: '',
      bitrate: 0,
      votes: 0,
      clickCount: 0,
      clickTrend: 0,
      lastCheckOk: true,
      hls: false,
      isScraped: false,
      rawSource: <String, dynamic>{
        'source': 'manual',
        'name': trimmedName,
        'stream_url': trimmedStreamUrl,
      },
    );

    manualStations = List<RadioStation>.unmodifiable(<RadioStation>[
      station,
      ...manualStations,
    ]);
    discoverStations = await _loadDiscoverStations();
    notifyListeners();
    await _saveSettings();
  }

  Future<void> removeManualStation(String stationUuid) async {
    final nextManualStations = manualStations
        .where((station) => station.stationUuid != stationUuid)
        .toList(growable: false);
    await _replaceManualStations(nextManualStations);
  }

  Future<void> removeAllManualStations() async {
    await _replaceManualStations(const <RadioStation>[]);
  }

  Future<void> clearRecentlyPlayed() async {
    if (recentlyPlayedStations.isEmpty) {
      return;
    }

    recentlyPlayedStations = const <RadioStation>[];
    notifyListeners();
    await _saveSettings();
  }

  Future<void> _recordRecentlyPlayed(RadioStation station) async {
    final nextStations = <RadioStation>[
      station,
      ...recentlyPlayedStations.where(
        (item) => item.stationUuid != station.stationUuid,
      ),
    ].take(_recentlyPlayedLimit).toList(growable: false);

    recentlyPlayedStations = List<RadioStation>.unmodifiable(nextStations);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> _replaceManualStations(List<RadioStation> stations) async {
    final removedStationIds = manualStations
        .map((station) => station.stationUuid)
        .where(
          (stationUuid) =>
              !stations.any((station) => station.stationUuid == stationUuid),
        )
        .toSet();

    manualStations = List<RadioStation>.unmodifiable(stations);
    stationsByCategory = stationsByCategory.map((category, stations) {
      return MapEntry(
        category,
        stations
            .where(
              (station) => !removedStationIds.contains(station.stationUuid),
            )
            .toList(growable: false),
      );
    });

    if (currentStation != null &&
        removedStationIds.contains(currentStation!.stationUuid)) {
      await stopPlayback();
    }

    discoverStations = await _loadDiscoverStations();
    notifyListeners();
    await _categoryStationsStore.saveStationsByCategory(stationsByCategory);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    await _settingsStore.saveSettings(
      AppSettings(
        themePreference: themePreference,
        languagePreference: languagePreference,
        showStationIcon: showStationIcon,
        autoPlayNextCategoryStation: autoPlayNextCategoryStation,
        countryCodes: countryCodes,
        hasCompletedCountrySetup: hasCompletedCountrySetup,
        manualStations: manualStations,
        recentlyPlayedStations: recentlyPlayedStations,
        stationCategories: stationCategories,
        activeStationCategoryId: activeStationCategoryId,
      ),
    );
  }

  void _handlePlaybackSnapshot() {
    if (isCasting) {
      return;
    }
    final previousPlayback = playback;
    playback = _audioEngine.snapshot.value;
    final didUpdatePlaybackStallDisplay = _trackPlaybackProgress(
      position: playback.position,
      bufferedPosition: playback.bufferedPosition,
    );
    if (playback.isPlaying) {
      _stopStreamRecoveryRetryLoop();
      _startPlaybackStallWatchdog();
    } else {
      _stopPlaybackStallWatchdog();
    }
    final didUpdateStreamRecoveryDisplay = _handleStreamRecoveryState();
    if (_playbackDisplayChanged(previousPlayback, playback) ||
        didUpdatePlaybackStallDisplay ||
        didUpdateStreamRecoveryDisplay) {
      notifyListeners();
    }
  }

  void _handleCastSnapshot() {
    final previousCasting = casting;
    casting = _castService.snapshot.value;

    if (casting.isConnected) {
      final status = switch (casting.playbackStatus) {
        CastPlaybackStatus.playing => PlaybackStatus.playing,
        CastPlaybackStatus.loading => PlaybackStatus.loading,
        CastPlaybackStatus.paused => PlaybackStatus.paused,
        CastPlaybackStatus.error => PlaybackStatus.error,
        CastPlaybackStatus.idle =>
          currentStation == null ? PlaybackStatus.idle : PlaybackStatus.paused,
      };
      playback = PlaybackSnapshot(
        status: status,
        message: casting.message,
        nowPlaying: playback.nowPlaying,
      );
      _stopPlaybackStallWatchdog();
    } else if (previousCasting.isConnected && currentStation != null) {
      playback = PlaybackSnapshot(
        status: PlaybackStatus.paused,
        nowPlaying: playback.nowPlaying,
      );
    }
    notifyListeners();
  }

  void _handleConnectivitySnapshot() {
    connectivity = _connectivityService.snapshot.value;
    notifyListeners();
  }

  bool _trackPlaybackProgress({
    required Duration position,
    required Duration bufferedPosition,
  }) {
    if (position > _lastObservedPosition ||
        bufferedPosition > _lastObservedBufferedPosition) {
      final wasStalled = playbackStalled;
      final previousStallReason = playbackStallReason;
      _connectivityService.reportOnline();
      _stopInternetRecoveryRetryLoop();
      _stopStreamRecoveryRetryLoop();
      _lastObservedPosition = position;
      _lastObservedBufferedPosition = bufferedPosition;
      _lastPositionAdvancedAt = DateTime.now();
      playbackStalled = false;
      playbackStallReason = null;
      _isHandlingPlaybackStall = false;
      return wasStalled != playbackStalled ||
          previousStallReason != playbackStallReason;
    } else if (_lastPositionAdvancedAt == null && playback.isPlaying) {
      _lastPositionAdvancedAt = DateTime.now();
    }
    return false;
  }

  bool _playbackDisplayChanged(
    PlaybackSnapshot previous,
    PlaybackSnapshot next,
  ) {
    return previous.status != next.status ||
        previous.message != next.message ||
        !_nowPlayingMetadataMatches(previous.nowPlaying, next.nowPlaying);
  }

  bool _nowPlayingMetadataMatches(
    NowPlayingMetadata? previous,
    NowPlayingMetadata? next,
  ) {
    return previous?.title == next?.title &&
        previous?.url == next?.url &&
        previous?.stationName == next?.stationName &&
        previous?.genre == next?.genre;
  }

  void _startPlaybackStallWatchdog() {
    _playbackStallTimer ??= Timer.periodic(_playbackStallPollInterval, (_) {
      if (!playback.isPlaying) {
        return;
      }

      final lastAdvancedAt = _lastPositionAdvancedAt ?? DateTime.now();
      final elapsed = DateTime.now().difference(lastAdvancedAt);
      if (elapsed >= _playbackStallThreshold && !playbackStalled) {
        unawaited(_handlePlaybackStall());
      }
    });
  }

  Future<void> _handlePlaybackStall() async {
    if (_isHandlingPlaybackStall || !playback.isPlaying) {
      return;
    }

    _isHandlingPlaybackStall = true;
    playbackStalled = true;
    notifyListeners();

    try {
      await _connectivityService.internetReachable();
      connectivity = _connectivityService.snapshot.value;
      final isOffline = connectivity.isOffline;

      playbackStallReason = isOffline
          ? PlaybackStallReason.internetOutage
          : PlaybackStallReason.streamFailure;
      notifyListeners();

      if (isOffline) {
        _startInternetRecoveryRetryLoop();
      } else {
        _stopInternetRecoveryRetryLoop();
      }

      if (!isOffline &&
          autoPlayNextCategoryStation &&
          canAutoPlayNextCategoryStation) {
        final nextCategoryStation = _nextStationInCurrentCategory();
        if (nextCategoryStation != null) {
          await playStation(nextCategoryStation);
        }
      }
    } catch (error) {
      playbackStallReason = PlaybackStallReason.streamFailure;
      playback = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: _errorMessage(error),
        nowPlaying: playback.nowPlaying,
        position: playback.position,
      );
      notifyListeners();
    } finally {
      if (!playback.isLoading) {
        _isHandlingPlaybackStall = false;
      }
    }
  }

  RadioStation? _nextStationInCurrentCategory() {
    return _nextCategoryStationFor(currentStation);
  }

  RadioStation? _nextCategoryStationFor(RadioStation? station) {
    if (station == null) {
      return null;
    }

    final categoryId = _categoryIdForStation(station);
    if (categoryId == null) {
      return null;
    }

    final stations = stationsForCategory(categoryId);
    if (stations.length < 2) {
      return null;
    }

    final currentIndex = stations.indexWhere(
      (item) => item.identityKey == station.identityKey,
    );
    if (currentIndex < 0) {
      return null;
    }

    final nextIndex = (currentIndex + 1) % stations.length;
    return stations[nextIndex];
  }

  RadioStation? _previousCategoryStationFor(RadioStation? station) {
    if (station == null) {
      return null;
    }

    final categoryId = _categoryIdForStation(station);
    if (categoryId == null) {
      return null;
    }

    final stations = stationsForCategory(categoryId);
    if (stations.length < 2) {
      return null;
    }

    final currentIndex = stations.indexWhere(
      (item) => item.identityKey == station.identityKey,
    );
    if (currentIndex < 0) {
      return null;
    }

    final previousIndex =
        (currentIndex - 1 + stations.length) % stations.length;
    return stations[previousIndex];
  }

  void _startInternetRecoveryRetryLoop() {
    _internetRetryTimer ??= Timer.periodic(_internetRetryInterval, (_) {
      unawaited(_retryCurrentStationAfterInternetOutage());
    });
  }

  bool _handleStreamRecoveryState() {
    if (isCasting) {
      return false;
    }

    if (playback.hasError && currentStation != null) {
      return _startStreamRecoveryRetryLoop();
    }

    if (playback.isPaused || playback.status == PlaybackStatus.idle) {
      _stopStreamRecoveryRetryLoop();
    }
    return false;
  }

  bool _startStreamRecoveryRetryLoop() {
    final station = currentStation;
    if (station == null) {
      return false;
    }

    final wasStalled = playbackStalled;
    final previousStallReason = playbackStallReason;
    playbackStalled = true;
    playbackStallReason = PlaybackStallReason.streamFailure;

    if (_streamRecoveryRetryTimer != null &&
        _streamRecoveryStationKey == station.identityKey) {
      return wasStalled != playbackStalled ||
          previousStallReason != playbackStallReason;
    }

    _streamRecoveryRetryTimer?.cancel();
    _streamRecoveryStartedAt = DateTime.now();
    _streamRecoveryStationKey = station.identityKey;
    _streamRecoveryRetryTimer = Timer.periodic(
      _streamRecoveryRetryInterval,
      (_) => unawaited(_retryCurrentStationAfterStreamFailure()),
    );

    return wasStalled != playbackStalled ||
        previousStallReason != playbackStallReason;
  }

  Future<void> _retryCurrentStationAfterStreamFailure() async {
    final station = currentStation;
    final startedAt = _streamRecoveryStartedAt;
    if (_isRetryingStreamFailure ||
        station == null ||
        startedAt == null ||
        playback.isLoading ||
        !playback.hasError) {
      return;
    }

    if (DateTime.now().difference(startedAt) >= _streamRecoveryWindow) {
      _stopStreamRecoveryRetryLoop();
      if (autoPlayNextCategoryStation && canAutoPlayNextCategoryStation) {
        final nextCategoryStation = _nextCategoryStationFor(station);
        if (nextCategoryStation != null) {
          await playStation(nextCategoryStation);
        }
      }
      return;
    }

    _isRetryingStreamFailure = true;
    try {
      await playStation(station, fromStreamRecoveryRetry: true);
    } finally {
      _isRetryingStreamFailure = false;
    }
  }

  Future<void> _retryCurrentStationAfterInternetOutage() async {
    if (_isRetryingCurrentStation ||
        currentStation == null ||
        playbackStallReason != PlaybackStallReason.internetOutage ||
        playback.isLoading) {
      return;
    }

    _isRetryingCurrentStation = true;

    try {
      await _connectivityService.internetReachable();
      connectivity = _connectivityService.snapshot.value;
      notifyListeners();

      if (connectivity.isOffline || currentStation == null) {
        return;
      }

      await playStation(currentStation!, fromInternetRecoveryRetry: true);
    } finally {
      _isRetryingCurrentStation = false;
    }
  }

  Future<void> _handleImmediateRetryPlaybackFailureIfNeeded(
    RadioStation station, {
    required bool fromInternetRecoveryRetry,
  }) async {
    if (!fromInternetRecoveryRetry || !playback.hasError) {
      return;
    }

    playbackStalled = true;
    playbackStallReason = PlaybackStallReason.streamFailure;
    notifyListeners();

    if (!autoPlayNextCategoryStation || !canAutoPlayNextCategoryStation) {
      return;
    }

    final nextCategoryStation = _nextCategoryStationFor(station);
    if (nextCategoryStation != null) {
      await playStation(nextCategoryStation);
    }
  }

  void _stopInternetRecoveryRetryLoop() {
    _internetRetryTimer?.cancel();
    _internetRetryTimer = null;
    _isRetryingCurrentStation = false;
  }

  void _stopStreamRecoveryRetryLoop() {
    _streamRecoveryRetryTimer?.cancel();
    _streamRecoveryRetryTimer = null;
    _isRetryingStreamFailure = false;
    _streamRecoveryStartedAt = null;
    _streamRecoveryStationKey = null;
  }

  void _stopPlaybackStallWatchdog() {
    _playbackStallTimer?.cancel();
    _playbackStallTimer = null;
    _simulatedStallTimer?.cancel();
    _simulatedStallTimer = null;
    _lastObservedPosition = playback.isPlaying
        ? _lastObservedPosition
        : Duration.zero;
    _lastObservedBufferedPosition = playback.isPlaying
        ? _lastObservedBufferedPosition
        : Duration.zero;
    _lastPositionAdvancedAt = null;
    playbackStalled = false;
    playbackStallReason = null;
    _isHandlingPlaybackStall = false;
  }

  String _errorMessage(Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) {
      return 'Something went wrong.';
    }
    return message;
  }

  @override
  void dispose() {
    _audioEngine.snapshot.removeListener(_handlePlaybackSnapshot);
    _castService.snapshot.removeListener(_handleCastSnapshot);
    _connectivityService.snapshot.removeListener(_handleConnectivitySnapshot);
    _playbackStallTimer?.cancel();
    _internetRetryTimer?.cancel();
    _streamRecoveryRetryTimer?.cancel();
    _simulatedStallTimer?.cancel();
    _sleepTimer?.cancel();
    unawaited(_audioEngine.dispose());
    unawaited(_castService.dispose());
    unawaited(_connectivityService.dispose());
    super.dispose();
  }
}
