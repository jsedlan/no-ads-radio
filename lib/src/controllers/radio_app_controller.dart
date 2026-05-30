import 'dart:async';

import 'package:flutter/foundation.dart';

import '../audio/audio_engine.dart';
import '../models/favorite_category.dart';
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
  static const List<Duration> sleepTimerOptions = <Duration>[
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
  ];
  static const int _recentlyPlayedLimit = 50;

  List<RadioStation> discoverStations = const <RadioStation>[];
  List<RadioStation> searchResults = const <RadioStation>[];
  List<RadioStation> manualStations = const <RadioStation>[];
  List<RadioStation> recentlyPlayedStations = const <RadioStation>[];
  Map<String, List<RadioStation>> favoritesByCategory =
      const <String, List<RadioStation>>{};

  bool isBootstrapping = true;
  bool isRefreshingDiscover = false;
  bool isSearching = false;
  String? discoverError;
  String? searchError;
  String? favoritesError;
  String discoverFilter = '';
  AppThemePreference themePreference = AppThemePreference.dark;
  bool showStationIcon = false;
  bool circleThroughFavorites = true;
  List<String> countryCodes = const <String>[];
  List<FavoriteCategory> favoriteCategories = const <FavoriteCategory>[
    FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
  ];

  StationSearchQuery activeSearchQuery = const StationSearchQuery();
  RadioStation? currentStation;
  PlaybackSnapshot playback = const PlaybackSnapshot.idle();
  ConnectivitySnapshot connectivity = const ConnectivitySnapshot.unknown();
  bool playbackStalled = false;
  PlaybackStallReason? playbackStallReason;
  DateTime? sleepTimerEndsAt;
  int selectedTab = 0;
  int _activeFavoriteCategoryIndex = 0;

  bool get isOffline => connectivity.isOffline;
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

  bool get canCircleThroughFavorites => favoriteCategories.any(
    (category) => favoritesForCategory(category.id).length >= 2,
  );
  FavoriteCategory get activeFavoriteCategory {
    if (favoriteCategories.isEmpty) {
      return const FavoriteCategory(
        id: 'category-0-favorites',
        name: 'Favorites',
      );
    }
    final index = _activeFavoriteCategoryIndex.clamp(
      0,
      favoriteCategories.length - 1,
    );
    return favoriteCategories[index];
  }

  String get activeFavoriteCategoryId => activeFavoriteCategory.id;

  List<RadioStation> get favorites =>
      favoritesForCategory(activeFavoriteCategoryId);

  bool get canPlayAdjacentFavorite {
    final station = currentStation;
    if (station == null) {
      return false;
    }
    final categoryId = _favoriteCategoryIdForStation(station);
    return categoryId != null && favoritesForCategory(categoryId).length >= 2;
  }

  Timer? _playbackStallTimer;
  Timer? _internetRetryTimer;
  Timer? _simulatedStallTimer;
  Timer? _sleepTimer;
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
      themePreference = settings.themePreference;
      showStationIcon = settings.showStationIcon;
      circleThroughFavorites = settings.circleThroughFavorites;
      countryCodes = settings.countryCodes;
      manualStations = settings.manualStations;
      recentlyPlayedStations = settings.recentlyPlayedStations;
      favoriteCategories = settings.favoriteCategories.isEmpty
          ? const <FavoriteCategory>[
              FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
            ]
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

  List<RadioStation> favoritesForCategory(String categoryId) {
    return List<RadioStation>.unmodifiable(
      favoritesByCategory[categoryId] ?? const <RadioStation>[],
    );
  }

  List<RadioStation> get allFavoriteStations => favoriteCategories
      .expand((category) => favoritesForCategory(category.id))
      .toList(growable: false);

  String _normalizedFavoriteCategoryId(String? categoryId) {
    final normalized = categoryId?.trim();
    if (normalized != null &&
        normalized.isNotEmpty &&
        favoriteCategories.any((category) => category.id == normalized)) {
      return normalized;
    }
    return activeFavoriteCategoryId;
  }

  void _syncFavoriteCategoriesWithSavedData() {
    final nextMap = <String, List<RadioStation>>{};
    for (final category in favoriteCategories) {
      nextMap[category.id] = List<RadioStation>.unmodifiable(
        favoritesByCategory[category.id] ??
            favoritesByCategory[category.name] ??
            const <RadioStation>[],
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
    String categoryId,
    List<RadioStation> stations,
  ) {
    final nextMap = Map<String, List<RadioStation>>.from(favoritesByCategory);
    nextMap[categoryId] = List<RadioStation>.unmodifiable(stations);
    return Map<String, List<RadioStation>>.unmodifiable(nextMap);
  }

  Map<String, List<RadioStation>> _remapFavoritesByCategory(
    List<FavoriteCategory> previousCategories,
    List<FavoriteCategory> nextCategories,
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
            : (favoritesByCategory[previousCategory?.id] ??
                  favoritesByCategory[previousCategory?.name] ??
                  favoritesByCategory[fallbackCategory?.id] ??
                  favoritesByCategory[fallbackCategory?.name] ??
                  const <RadioStation>[]),
      );
    }
    return Map<String, List<RadioStation>>.unmodifiable(remapped);
  }

  String? _favoriteCategoryIdForStation(RadioStation station) {
    for (final category in favoriteCategories) {
      if (favoritesForCategory(
        category.id,
      ).any((item) => item.stationUuid == station.stationUuid)) {
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

  Future<void> toggleFavorite(
    RadioStation station, {
    String? categoryId,
  }) async {
    favoritesError = null;
    final targetCategory = _normalizedFavoriteCategoryId(categoryId);
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

  Future<void> reorderFavorites({
    required String categoryId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final targetCategory = _normalizedFavoriteCategoryId(categoryId);
    final currentFavorites = List<RadioStation>.from(
      favoritesForCategory(targetCategory),
    );
    if (oldIndex < 0 ||
        oldIndex >= currentFavorites.length ||
        newIndex < 0 ||
        newIndex > currentFavorites.length) {
      return;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) {
      return;
    }

    final movedStation = currentFavorites.removeAt(oldIndex);
    currentFavorites.insert(newIndex, movedStation);
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

  bool isFavorite(String stationUuid, {String? categoryId}) {
    if (categoryId == null) {
      return favoriteCategories.any(
        (category) => favoritesForCategory(
          category.id,
        ).any((station) => station.stationUuid == stationUuid),
      );
    }

    return favoritesForCategory(
      _normalizedFavoriteCategoryId(categoryId),
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
              ? 'NoAds Radio'
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
      if (!playback.hasError) {
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

  Future<void> playPreviousFavorite() async {
    final previous = _previousFavoriteStationFor(currentStation);
    if (previous == null) {
      return;
    }
    await playStation(previous);
  }

  Future<void> playNextFavorite() async {
    final next = _nextFavoriteStationFor(currentStation);
    if (next == null) {
      return;
    }
    await playStation(next);
  }

  Future<void> stopPlayback() async {
    _cancelSleepTimer(notify: false);
    _stopInternetRecoveryRetryLoop();
    await _audioEngine.stop();
    currentStation = null;
    _stopPlaybackStallWatchdog();
    playback = const PlaybackSnapshot.idle();
    notifyListeners();
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

  Future<void> setCircleThroughFavorites(bool value) async {
    circleThroughFavorites = value;
    notifyListeners();
    await _saveSettings();
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
    await _saveSettings();
  }

  Future<void> setFavoriteCategories(List<String> values) async {
    final previousCategories = favoriteCategories;
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final categoryNames = normalized.isEmpty
        ? const <String>['Favorites']
        : normalized;
    favoriteCategories = List<FavoriteCategory>.unmodifiable(
      List<FavoriteCategory>.generate(categoryNames.length, (index) {
        if (index < previousCategories.length) {
          return previousCategories[index].copyWith(name: categoryNames[index]);
        }
        return FavoriteCategory(
          id: 'category-${DateTime.now().microsecondsSinceEpoch}-$index',
          name: categoryNames[index],
        );
      }),
    );
    favoritesByCategory = _remapFavoritesByCategory(
      previousCategories,
      favoriteCategories,
    );
    _syncFavoriteCategoriesWithSavedData();
    notifyListeners();
    await _saveSettings();
    await _favoritesStore.saveFavorites(favoritesByCategory);
  }

  Future<void> setFavoriteCategoryItems(List<FavoriteCategory> values) async {
    final previousCategories = favoriteCategories;
    final normalized = values
        .map((category) => category.copyWith(name: category.name.trim()))
        .where((category) => category.name.isNotEmpty)
        .toList(growable: false);
    favoriteCategories = List<FavoriteCategory>.unmodifiable(
      normalized.isEmpty
          ? const <FavoriteCategory>[
              FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
            ]
          : normalized,
    );
    favoritesByCategory = _remapFavoritesByCategory(
      previousCategories,
      favoriteCategories,
    );
    _syncFavoriteCategoriesWithSavedData();
    notifyListeners();
    await _saveSettings();
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
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    await _settingsStore.saveSettings(
      AppSettings(
        themePreference: themePreference,
        showStationIcon: showStationIcon,
        circleThroughFavorites: circleThroughFavorites,
        countryCodes: countryCodes,
        manualStations: manualStations,
        recentlyPlayedStations: recentlyPlayedStations,
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

    final categoryId = _favoriteCategoryIdForStation(station);
    if (categoryId == null) {
      return null;
    }

    final stations = favoritesForCategory(categoryId);
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

  RadioStation? _previousFavoriteStationFor(RadioStation? station) {
    if (station == null) {
      return null;
    }

    final categoryId = _favoriteCategoryIdForStation(station);
    if (categoryId == null) {
      return null;
    }

    final stations = favoritesForCategory(categoryId);
    if (stations.length < 2) {
      return null;
    }

    final currentIndex = stations.indexWhere(
      (item) => item.stationUuid == station.stationUuid,
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
    _sleepTimer?.cancel();
    unawaited(_audioEngine.dispose());
    unawaited(_connectivityService.dispose());
    super.dispose();
  }
}
