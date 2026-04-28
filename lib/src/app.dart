import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/audio_engine.dart';
import 'controllers/radio_app_controller.dart';
import 'models/radio_station.dart';

part 'app_settings_pages.dart';
part 'app_station_widgets.dart';

class NoAdsRadioApp extends StatelessWidget {
  const NoAdsRadioApp({super.key, required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(brightness: Brightness.dark);
    final textTheme = GoogleFonts.spaceGroteskTextTheme(
      baseTheme.textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white);
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFEF6C32),
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
    );

    return MaterialApp(
      title: 'No Ads Radio',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        cardTheme: const CardThemeData(
          color: Color(0xFF111A24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF162231),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: RadioHomePage(controller: controller),
    );
  }
}

class RadioHomePage extends StatefulWidget {
  const RadioHomePage({super.key, required this.controller});

  final RadioAppController controller;

  @override
  State<RadioHomePage> createState() => _RadioHomePageState();
}

class _RadioHomePageState extends State<RadioHomePage> {
  int? _favoriteDropTargetIndex;
  bool _isDraggingDiscoverStation = false;

  RadioAppController get controller => widget.controller;

  void _handleFavoriteDrop(RadioStation station, int categoryIndex) {
    unawaited(_saveFavoriteFromDrop(station, categoryIndex));
  }

  Future<void> _saveFavoriteFromDrop(
    RadioStation station,
    int categoryIndex,
  ) async {
    final categoryName = _visibleCategoryNames(
      controller.favoriteCategories,
    )[categoryIndex];
    if (!controller.isFavorite(
      station.stationUuid,
      categoryName: categoryName,
    )) {
      await controller.toggleFavorite(station, categoryName: categoryName);
    }
    controller.selectTab(categoryIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visibleCategoryNames = _visibleCategoryNames(
          controller.favoriteCategories,
        );
        final totalTabCount = 1 + visibleCategoryNames.length;
        final selectedIndex = controller.selectedTab >= totalTabCount
            ? 0
            : controller.selectedTab;
        if (controller.isBootstrapping) {
          return const _Shell(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _Shell(
          bottomNavigationBar: SizedBox(
            height: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    NavigationBar(
                      backgroundColor: const Color(0xFF0F1620),
                      selectedIndex: selectedIndex,
                      onDestinationSelected: controller.selectTab,
                      destinations: [
                        const NavigationDestination(
                          icon: Icon(Icons.explore_outlined),
                          selectedIcon: Icon(Icons.explore),
                          label: 'Stations',
                        ),
                        ...visibleCategoryNames.map(
                          (categoryName) => NavigationDestination(
                            icon: const Icon(Icons.favorite_border),
                            selectedIcon: const Icon(Icons.favorite),
                            label: categoryName,
                          ),
                        ),
                      ],
                    ),
                    if (_isDraggingDiscoverStation)
                      Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        width:
                            constraints.maxWidth *
                            (visibleCategoryNames.length / totalTabCount),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Row(
                            children: List<Widget>.generate(
                              visibleCategoryNames.length,
                              (index) {
                                final categoryName =
                                    visibleCategoryNames[index];
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: index == 0 ? 0 : 4,
                                      right:
                                          index ==
                                              visibleCategoryNames.length - 1
                                          ? 0
                                          : 4,
                                    ),
                                    child: DragTarget<RadioStation>(
                                      onWillAcceptWithDetails: (details) {
                                        final canAccept = !controller
                                            .isFavorite(
                                              details.data.stationUuid,
                                              categoryName: categoryName,
                                            );
                                        setState(() {
                                          _favoriteDropTargetIndex = canAccept
                                              ? index
                                              : null;
                                        });
                                        return canAccept;
                                      },
                                      onLeave: (_) {
                                        setState(() {
                                          _favoriteDropTargetIndex = null;
                                        });
                                      },
                                      onAcceptWithDetails: (details) {
                                        setState(() {
                                          _favoriteDropTargetIndex = null;
                                          _isDraggingDiscoverStation = false;
                                        });
                                        _handleFavoriteDrop(
                                          details.data,
                                          index,
                                        );
                                      },
                                      builder:
                                          (
                                            context,
                                            candidateData,
                                            rejectedData,
                                          ) {
                                            final isActive =
                                                _favoriteDropTargetIndex ==
                                                    index &&
                                                candidateData.isNotEmpty;
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 120,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? const Color(
                                                        0xFFFF8A5B,
                                                      ).withValues(alpha: 0.18)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: isActive
                                                      ? const Color(0xFFFF8A5B)
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _Header(controller: controller),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: IndexedStack(
                      index: selectedIndex,
                      children: [
                        _DiscoverTab(
                          controller: controller,
                          onDragStateChanged: (isDragging) {
                            if (_isDraggingDiscoverStation == isDragging) {
                              return;
                            }
                            setState(() {
                              _isDraggingDiscoverStation = isDragging;
                              if (!isDragging) {
                                _favoriteDropTargetIndex = null;
                              }
                            });
                          },
                        ),
                        ...visibleCategoryNames.map(
                          (categoryName) => _FavoritesTab(
                            controller: controller,
                            categoryName: categoryName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.currentStation != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _PlayerBar(controller: controller),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child, this.bottomNavigationBar});

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1117), Color(0xFF111827), Color(0xFF1A1025)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: bottomNavigationBar,
        body: child,
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.controller});

  final RadioAppController controller;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late final TextEditingController _discoverFilterController;

  RadioAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _discoverFilterController = TextEditingController(
      text: controller.discoverFilter,
    );
  }

  @override
  void didUpdateWidget(covariant _Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_discoverFilterController.text != controller.discoverFilter) {
      _discoverFilterController.value = TextEditingValue(
        text: controller.discoverFilter,
        selection: TextSelection.collapsed(
          offset: controller.discoverFilter.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _discoverFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (controller.isOffline) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Offline',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (controller.selectedTab == 0) ...[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _discoverFilterController,
                      onChanged: controller.setDiscoverFilter,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Filter',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: controller.discoverFilter.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _discoverFilterController.clear();
                                  controller.setDiscoverFilter('');
                                },
                                icon: const Icon(Icons.close_rounded),
                                tooltip: 'Clear filter',
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              PopupMenuButton<_HeaderAction>(
                tooltip: 'More',
                icon: const Icon(Icons.more_vert_rounded),
                color: const Color(0xFF111A24),
                onSelected: (value) {
                  switch (value) {
                    case _HeaderAction.settings:
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              _SettingsPage(controller: controller),
                        ),
                      );
                    case _HeaderAction.debugView:
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              _DebugViewPage(controller: controller),
                        ),
                      );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<_HeaderAction>(
                    value: _HeaderAction.debugView,
                    child: Text('Debug view'),
                  ),
                  PopupMenuItem<_HeaderAction>(
                    value: _HeaderAction.settings,
                    child: Text('Settings'),
                  ),
                ],
              ),
            ],
          ),
          if (controller.discoverError != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  controller.discoverError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _HeaderAction { settings, debugView }

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab({
    required this.controller,
    required this.onDragStateChanged,
  });

  final RadioAppController controller;
  final ValueChanged<bool> onDragStateChanged;

  @override
  Widget build(BuildContext context) {
    final stations = _filterDiscoverStationsByQuery(
      _filterStationsByCountryCodesInOrder(
        controller.discoverStations,
        controller.countryCodes,
      ),
      controller.discoverFilter,
    );

    return RefreshIndicator(
      onRefresh: controller.refreshDiscover,
      child: _StationList(
        controller: controller,
        stations: stations,
        isLoading: controller.isRefreshingDiscover,
        emptyMessage: 'No stations available right now.',
        draggableStations: true,
        onDragStateChanged: onDragStateChanged,
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({required this.controller, required this.categoryName});

  final RadioAppController controller;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return _StationList(
      controller: controller,
      stations: controller.favoritesForCategory(categoryName),
      emptyMessage:
          'No favorites in $categoryName yet. Save stations from Stations to build this category.',
    );
  }
}

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final station = controller.currentStation;
    if (station == null) {
      return const SizedBox.shrink();
    }

    final playback = controller.playback;
    final useVerticalLayout =
        MediaQuery.sizeOf(context).width < 420 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.15;

    return Card(
      color: const Color(0xFF151F2B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: useVerticalLayout
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.showStationIcon) ...[
                        _StationArtwork(station: station),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: _PlayerBarText(
                          station: station,
                          playback: playback,
                          playbackStalled: controller.playbackStalled,
                          playbackStallReason: controller.playbackStallReason,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _playerBarActions(playback),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  if (controller.showStationIcon) ...[
                    _StationArtwork(station: station),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: _PlayerBarText(
                      station: station,
                      playback: playback,
                      playbackStalled: controller.playbackStalled,
                      playbackStallReason: controller.playbackStallReason,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ..._playerBarActions(playback),
                ],
              ),
      ),
    );
  }

  List<Widget> _playerBarActions(PlaybackSnapshot playback) {
    return <Widget>[
      if (playback.isLoading)
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      else
        IconButton.filledTonal(
          onPressed: playback.isPlaying
              ? controller.pausePlayback
              : controller.resumePlayback,
          icon: Icon(
            playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
      IconButton(
        onPressed: controller.stopPlayback,
        icon: const Icon(Icons.close_rounded),
      ),
    ];
  }
}

class _PlayerBarText extends StatelessWidget {
  const _PlayerBarText({
    required this.station,
    required this.playback,
    required this.playbackStalled,
    required this.playbackStallReason,
    required this.theme,
  });

  final RadioStation station;
  final PlaybackSnapshot playback;
  final bool playbackStalled;
  final PlaybackStallReason? playbackStallReason;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final stationTitleStyle = GoogleFonts.notoSans(
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
    final stationSubtitleStyle = GoogleFonts.notoSans(
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        color: playback.hasError ? theme.colorScheme.error : Colors.white70,
      ),
    );
    final stationMetaStyle = GoogleFonts.notoSans(
      textStyle: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          station.displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: stationTitleStyle,
        ),
        const SizedBox(height: 4),
        Text(
          playbackStalled
              ? playbackStallReason == PlaybackStallReason.internetOutage
                    ? 'Internet connection lost'
                    : playbackStallReason == PlaybackStallReason.streamFailure
                    ? 'Stream stopped responding'
                    : 'Playback stalled'
              : playback.hasError
              ? playback.message ?? 'Playback failed'
              : playback.isLoading
              ? 'Buffering stream...'
              : playback.isPlaying && playback.nowPlaying?.displayTitle != null
              ? playback.nowPlaying!.displayTitle!
              : playback.isPlaying
              ? 'Now playing'
              : 'Paused',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: stationSubtitleStyle,
        ),
        if (playback.isPlaying &&
            playback.nowPlaying?.displayTitle != null &&
            (playback.nowPlaying?.stationName?.trim().isNotEmpty ?? false)) ...[
          const SizedBox(height: 2),
          Text(
            playback.nowPlaying!.stationName!.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: stationMetaStyle,
          ),
        ],
      ],
    );
  }
}
