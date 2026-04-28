import 'dart:async';

import 'package:flutter/foundation.dart';

import '../audio/audio_engine.dart';
import '../models/radio_station.dart';
import '../models/search_query.dart';
import '../services/connectivity_service.dart';
import '../services/favorites_store.dart';
import '../services/settings_store.dart';
import '../services/station_repository.dart';

enum PlaybackStallReason { internetOutage, streamFailure }

class RadioAppController extends ChangeNotifier {
  RadioAppController._({
    required StationRepository repository,
    required FavoritesStore favoritesStore,
    required SettingsStore settingsStore,
    required AudioEngine audioEngine,
    required ConnectivityService connectivityService,
    required String startupCountryCode,
    required Duration playbackStallThreshold,
    required Duration playbackStallPollInterval,
  }) : _repository = repository,
       _favoritesStore = favoritesStore,
       _settingsStore = settingsStore,
       _audioEngine = audioEngine,
       _connectivityService = connectivityService,
       _startupCountryCode = startupCountryCode,
       _playbackStallThreshold = playbackStallThreshold,
       _playbackStallPollInterval = playbackStallPollInterval {
    _audioEngine.snapshot.addListener(_handlePlaybackSnapshot);
    _connectivityService.snapshot.addListener(_handleConnectivitySnapshot);
  }

  static Future<RadioAppController> bootstrap({
    required StationRepository repository,
    required FavoritesStore favoritesStore,
    required SettingsStore settingsStore,
    required AudioEngine audioEngine,
    required ConnectivityService connectivityService,
    String startupCountryCode = '',
    Duration playbackStallThreshold = const Duration(seconds: 8),
    Duration playbackStallPollInterval = const Duration(seconds: 1),
  }) async {
    final controller = RadioAppController._(
      repository: repository,
      favoritesStore: favoritesStore,
      settingsStore: settingsStore,
      audioEngine: audioEngine,
      connectivityService: connectivityService,
      startupCountryCode: startupCountryCode,
      playbackStallThreshold: playbackStallThreshold,
      playbackStallPollInterval: playbackStallPollInterval,
    );
    await controller._initialize();
    return controller;
  }

  final StationRepository _repository;
  final FavoritesStore _favoritesStore;
  final SettingsStore _settingsStore;
  final AudioEngine _audioEngine;
  final ConnectivityService _connectivityService;
  final String _startupCountryCode;
  final Duration _playbackStallThreshold;
  final Duration _playbackStallPollInterval;
  static const Duration _internetRetryInterval = Duration(seconds: 5);

  List<RadioStation> discoverStations = const <RadioStation>[];
  List<RadioStation> searchResults = const <RadioStation>[];
  List<RadioStation> manualStations = const <RadioStation>[];
  Map<String, List<RadioStation>> favoritesByCategory =
      const <String, List<RadioStation>>{};

  bool isBootstrapping = true;
  bool isRefreshingDiscover = false;
  bool isSearching = false;
  String? discoverError;
  String? searchError;
  String? favoritesError;
  String discoverFilter = '';
  bool showStationIcon = false;
  bool circleThroughFavorites = true;
  List<String> countryCodes = const <String>[];
  List<String> favoriteCategories = const <String>['Favorites'];

  StationSearchQuery activeSearchQuery = const StationSearchQuery();
  RadioStation? currentStation;
  PlaybackSnapshot playback = const PlaybackSnapshot.idle();
  ConnectivitySnapshot connectivity = const ConnectivitySnapshot.unknown();
  bool playbackStalled = false;
  PlaybackStallReason? playbackStallReason;
  int selectedTab = 0;
  int _activeFavoriteCategoryIndex = 0;

  bool get isOffline => connectivity.isOffline;
  bool get canCircleThroughFavorites => favoriteCategories.any(
    (category) => favoritesForCategory(category).length >= 2,
  );
  String get activeFavoriteCategoryName {
    if (favoriteCategories.isEmpty) {
      return 'Favorites';
    }
    final index = _activeFavoriteCategoryIndex.clamp(
      0,
      favoriteCategories.length - 1,
    );
    return favoriteCategories[index];
  }

  List<RadioStation> get favorites =>
      favoritesForCategory(activeFavoriteCategoryName);

  Timer? _playbackStallTimer;
  Timer? _internetRetryTimer;
  Timer? _simulatedStallTimer;
  Duration _lastObservedPosition = Duration.zero;
  Duration _lastObservedBufferedPosition = Duration.zero;
  DateTime? _lastPositionAdvancedAt;
  bool _isHandlingPlaybackStall = false;
  bool _isRetryingCurrentStation = false;

  Future<void> _initialize() async {
    try {
      await _connectivityService.initialize();
      connectivity = _connectivityService.snapshot.value;
      favoritesByCategory = await _favoritesStore.loadFavorites();
      var settings = await _settingsStore.loadSettings();
      if (settings.countryCodes.isEmpty && _startupCountryCode.isNotEmpty) {
        settings = settings.copyWith(
          countryCodes: <String>[_startupCountryCode],
        );
        await _settingsStore.saveSettings(settings);
      }
      showStationIcon = settings.showStationIcon;
      circleThroughFavorites = settings.circleThroughFavorites;
      countryCodes = settings.countryCodes;
      manualStations = settings.manualStations;
      favoriteCategories = settings.favoriteCategories.isEmpty
          ? const <String>['Favorites']
          : settings.favoriteCategories;
      _syncFavoriteCategoriesWithSavedData();
      await refreshDiscover();
      if (allFavoriteStations.isEmpty) {
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
      discoverStations = await _loadDiscoverStations();
    } catch (error) {
      discoverError = _errorMessage(error);
      discoverStations = const <RadioStation>[];
    } finally {
      isRefreshingDiscover = false;
      notifyListeners();
    }
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
      return _deduplicateStations(stations);
    }

    final merged = <RadioStation>[];

    for (final countryCode in countryCodes) {
      final stations = await _repository.searchStations(
        StationSearchQuery(countryCode: countryCode),
        limit: 5000,
      );

      merged.addAll(stations);
    }

    stations.addAll(merged);
    return _deduplicateStations(stations);
  }

  List<RadioStation> _deduplicateStations(List<RadioStation> stations) {
    final seenIds = <String>{};
    final seenNames = <String>{};
    final result = <RadioStation>[];

    for (final station in stations) {
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
    }

    return List<RadioStation>.unmodifiable(result);
  }

  List<RadioStation> favoritesForCategory(String categoryName) {
    return List<RadioStation>.unmodifiable(
      favoritesByCategory[categoryName] ?? const <RadioStation>[],
    );
  }

  List<RadioStation> get allFavoriteStations =>
      favoriteCategories.expand(favoritesForCategory).toList(growable: false);

  String _normalizedFavoriteCategoryName(String? categoryName) {
    final normalized = categoryName?.trim();
    if (normalized != null &&
        normalized.isNotEmpty &&
        favoriteCategories.contains(normalized)) {
      return normalized;
    }
    return activeFavoriteCategoryName;
  }

  void _syncFavoriteCategoriesWithSavedData() {
    final nextMap = <String, List<RadioStation>>{};
    for (final category in favoriteCategories) {
      nextMap[category] = List<RadioStation>.unmodifiable(
        favoritesByCategory[category] ?? const <RadioStation>[],
      );
    }
    favoritesByCategory = Map<String, List<RadioStation>>.unmodifiable(nextMap);
    if (_activeFavoriteCategoryIndex >= favoriteCategories.length) {
      _activeFavoriteCategoryIndex = favoriteCategories.isEmpty
          ? 0
          : favoriteCategories.length - 1;
    }
    if (selectedTab > favoriteCategories.length) {
      selectedTab = favoriteCategories.isEmpty ? 0 : favoriteCategories.length;
    }
  }

  Map<String, List<RadioStation>> _withCategoryFavorites(
    String categoryName,
    List<RadioStation> stations,
  ) {
    final nextMap = Map<String, List<RadioStation>>.from(favoritesByCategory);
    nextMap[categoryName] = List<RadioStation>.unmodifiable(stations);
    return Map<String, List<RadioStation>>.unmodifiable(nextMap);
  }

  Map<String, List<RadioStation>> _remapFavoritesByCategory(
    List<String> previousCategories,
    List<String> nextCategories,
  ) {
    final remapped = <String, List<RadioStation>>{};
    for (var index = 0; index < nextCategories.length; index += 1) {
      final nextCategory = nextCategories[index];
      final previousCategory = index < previousCategories.length
          ? previousCategories[index]
          : null;
      remapped[nextCategory] = List<RadioStation>.unmodifiable(
        previousCategory == null
            ? const <RadioStation>[]
            : (favoritesByCategory[previousCategory] ?? const <RadioStation>[]),
      );
    }
    return Map<String, List<RadioStation>>.unmodifiable(remapped);
  }

  String? _favoriteCategoryNameForStation(RadioStation station) {
    for (final category in favoriteCategories) {
      if (favoritesForCategory(
        category,
      ).any((item) => item.stationUuid == station.stationUuid)) {
        return category;
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

  Future<void> toggleFavorite(
    RadioStation station, {
    String? categoryName,
  }) async {
    favoritesError = null;
    final targetCategory = _normalizedFavoriteCategoryName(categoryName);
    final currentFavorites = List<RadioStation>.from(
      favoritesForCategory(targetCategory),
    );
    final existingIndex = currentFavorites.indexWhere(
      (item) => item.stationUuid == station.stationUuid,
    );

    if (existingIndex >= 0) {
      currentFavorites.removeAt(existingIndex);
    } else {
      currentFavorites.insert(0, station);
    }

    favoritesByCategory = _withCategoryFavorites(
      targetCategory,
      currentFavorites,
    );
    notifyListeners();

    try {
      await _favoritesStore.saveFavorites(favoritesByCategory);
    } catch (error) {
      favoritesError = _errorMessage(error);
      notifyListeners();
    }
  }

  bool isFavorite(String stationUuid, {String? categoryName}) {
    return favoritesForCategory(
      _normalizedFavoriteCategoryName(categoryName),
    ).any((station) => station.stationUuid == stationUuid);
  }

  Future<void> playStation(
    RadioStation station, {
    bool fromInternetRecoveryRetry = false,
  }) async {
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
      await _audioEngine.playStream(
        url,
        metadata: PlaybackMediaMetadata(
          id: station.stationUuid,
          title: station.displayName,
          album: station.displayLocation.isEmpty
              ? 'No Ads Radio'
              : station.displayLocation,
          artUri: station.hasArtwork
              ? Uri.tryParse(station.favicon.trim())
              : null,
        ),
      );
      await _handleImmediateRetryPlaybackFailureIfNeeded(
        station,
        fromInternetRecoveryRetry: fromInternetRecoveryRetry,
      );
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
      await _audioEngine.resume();
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
    try {
      await _audioEngine.pause();
    } catch (error) {
      playback = PlaybackSnapshot(
        status: PlaybackStatus.error,
        message: _errorMessage(error),
      );
      notifyListeners();
    }
  }

  Future<void> stopPlayback() async {
    _stopInternetRecoveryRetryLoop();
    await _audioEngine.stop();
    currentStation = null;
    _stopPlaybackStallWatchdog();
    playback = const PlaybackSnapshot.idle();
    notifyListeners();
  }

  void selectTab(int value) {
    selectedTab = value;
    if (value > 0) {
      _activeFavoriteCategoryIndex = value - 1;
    }
    notifyListeners();
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
    await _settingsStore.saveSettings(
      AppSettings(
        showStationIcon: value,
        circleThroughFavorites: circleThroughFavorites,
        countryCodes: countryCodes,
        manualStations: manualStations,
        favoriteCategories: favoriteCategories,
      ),
    );
  }

  Future<void> setCircleThroughFavorites(bool value) async {
    circleThroughFavorites = value;
    notifyListeners();
    await _settingsStore.saveSettings(
      AppSettings(
        showStationIcon: showStationIcon,
        circleThroughFavorites: value,
        countryCodes: countryCodes,
        manualStations: manualStations,
        favoriteCategories: favoriteCategories,
      ),
    );
  }

  Future<void> setCountryCodes(List<String> values) async {
    countryCodes = List<String>.unmodifiable(
      values
          .map((value) => value.trim().toUpperCase())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
    notifyListeners();
    await _settingsStore.saveSettings(
      AppSettings(
        showStationIcon: showStationIcon,
        circleThroughFavorites: circleThroughFavorites,
        countryCodes: countryCodes,
        manualStations: manualStations,
        favoriteCategories: favoriteCategories,
      ),
    );
  }

  Future<void> setFavoriteCategories(List<String> values) async {
    final previousCategories = favoriteCategories;
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    favoriteCategories = List<String>.unmodifiable(
      normalized.isEmpty ? const <String>['Favorites'] : normalized,
    );
    favoritesByCategory = _remapFavoritesByCategory(
      previousCategories,
      favoriteCategories,
    );
    _syncFavoriteCategoriesWithSavedData();
    notifyListeners();
    await _settingsStore.saveSettings(
      AppSettings(
        showStationIcon: showStationIcon,
        circleThroughFavorites: circleThroughFavorites,
        countryCodes: countryCodes,
        manualStations: manualStations,
        favoriteCategories: favoriteCategories,
      ),
    );
    await _favoritesStore.saveFavorites(favoritesByCategory);
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
    await _settingsStore.saveSettings(
      AppSettings(
        showStationIcon: showStationIcon,
        circleThroughFavorites: circleThroughFavorites,
        countryCodes: countryCodes,
        manualStations: manualStations,
        favoriteCategories: favoriteCategories,
      ),
    );
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

  Future<void> _replaceManualStations(List<RadioStation> stations) async {
    final removedStationIds = manualStations
        .map((station) => station.stationUuid)
        .where(
          (stationUuid) =>
              !stations.any((station) => station.stationUuid == stationUuid),
        )
        .toSet();

    manualStations = List<RadioStation>.unmodifiable(stations);
    favoritesByCategory = favoritesByCategory.map((category, stations) {
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
    await _favoritesStore.saveFavorites(favoritesByCategory);
    await _settingsStore.saveSettings(
      AppSettings(
        showStationIcon: showStationIcon,
        circleThroughFavorites: circleThroughFavorites,
        countryCodes: countryCodes,
        manualStations: manualStations,
        favoriteCategories: favoriteCategories,
      ),
    );
  }

  void _handlePlaybackSnapshot() {
    playback = _audioEngine.snapshot.value;
    _trackPlaybackProgress(
      position: playback.position,
      bufferedPosition: playback.bufferedPosition,
    );
    if (playback.isPlaying) {
      _startPlaybackStallWatchdog();
    } else {
      _stopPlaybackStallWatchdog();
    }
    notifyListeners();
  }

  void _handleConnectivitySnapshot() {
    connectivity = _connectivityService.snapshot.value;
    notifyListeners();
  }

  void _trackPlaybackProgress({
    required Duration position,
    required Duration bufferedPosition,
  }) {
    if (position > _lastObservedPosition ||
        bufferedPosition > _lastObservedBufferedPosition) {
      _stopInternetRecoveryRetryLoop();
      _lastObservedPosition = position;
      _lastObservedBufferedPosition = bufferedPosition;
      _lastPositionAdvancedAt = DateTime.now();
      playbackStalled = false;
      playbackStallReason = null;
      _isHandlingPlaybackStall = false;
    } else if (_lastPositionAdvancedAt == null && playback.isPlaying) {
      _lastPositionAdvancedAt = DateTime.now();
    }
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

      if (!isOffline && circleThroughFavorites && canCircleThroughFavorites) {
        final nextFavorite = _nextFavoriteStation();
        if (nextFavorite != null) {
          await playStation(nextFavorite);
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

  RadioStation? _nextFavoriteStation() {
    return _nextFavoriteStationFor(currentStation);
  }

  RadioStation? _nextFavoriteStationFor(RadioStation? station) {
    if (station == null) {
      return null;
    }

    final categoryName = _favoriteCategoryNameForStation(station);
    if (categoryName == null) {
      return null;
    }

    final stations = favoritesForCategory(categoryName);
    if (stations.length < 2) {
      return null;
    }

    final currentIndex = stations.indexWhere(
      (item) => item.stationUuid == station.stationUuid,
    );
    if (currentIndex < 0) {
      return null;
    }

    final nextIndex = (currentIndex + 1) % stations.length;
    return stations[nextIndex];
  }

  void _startInternetRecoveryRetryLoop() {
    _internetRetryTimer ??= Timer.periodic(_internetRetryInterval, (_) {
      unawaited(_retryCurrentStationAfterInternetOutage());
    });
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

    if (!circleThroughFavorites || !canCircleThroughFavorites) {
      return;
    }

    final nextFavorite = _nextFavoriteStationFor(station);
    if (nextFavorite != null) {
      await playStation(nextFavorite);
    }
  }

  void _stopInternetRecoveryRetryLoop() {
    _internetRetryTimer?.cancel();
    _internetRetryTimer = null;
    _isRetryingCurrentStation = false;
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
    _connectivityService.snapshot.removeListener(_handleConnectivitySnapshot);
    _playbackStallTimer?.cancel();
    _internetRetryTimer?.cancel();
    _simulatedStallTimer?.cancel();
    unawaited(_audioEngine.dispose());
    unawaited(_connectivityService.dispose());
    super.dispose();
  }
}
