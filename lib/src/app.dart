import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/audio_engine.dart';
import 'controllers/radio_app_controller.dart';
import 'models/favorite_category.dart';
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
    final category = _visibleCategories(
      controller.favoriteCategories,
    )[categoryIndex];
    if (!controller.isFavorite(station.stationUuid, categoryId: category.id)) {
      await controller.toggleFavorite(station, categoryId: category.id);
    }
    controller.selectTab(categoryIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visibleCategories = _visibleCategories(
          controller.favoriteCategories,
        );
        final totalTabCount = 1 + visibleCategories.length;
        final selectedIndex = controller.selectedTab >= totalTabCount
            ? 0
            : controller.selectedTab;
        if (controller.isBootstrapping) {
          return const _Shell(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _Shell(
          child: SafeArea(
            child: Column(
              children: [
                _Header(controller: controller),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    height: 80,
                    child: _TopTabBar(
                      controller: controller,
                      selectedIndex: selectedIndex,
                      visibleCategories: visibleCategories,
                      isDraggingDiscoverStation: _isDraggingDiscoverStation,
                      favoriteDropTargetIndex: _favoriteDropTargetIndex,
                      onFavoriteDropTargetChanged: (index) {
                        setState(() {
                          _favoriteDropTargetIndex = index;
                        });
                      },
                      onFavoriteDropAccepted: (station, categoryIndex) {
                        setState(() {
                          _favoriteDropTargetIndex = null;
                          _isDraggingDiscoverStation = false;
                        });
                        _handleFavoriteDrop(station, categoryIndex);
                      },
                    ),
                  ),
                ),
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
                        ...visibleCategories.map(
                          (category) => _FavoritesTab(
                            controller: controller,
                            category: category,
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
  const _Shell({required this.child});

  final Widget child;

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
      child: Scaffold(backgroundColor: Colors.transparent, body: child),
    );
  }
}

class _TopTabBar extends StatelessWidget {
  const _TopTabBar({
    required this.controller,
    required this.selectedIndex,
    required this.visibleCategories,
    required this.isDraggingDiscoverStation,
    required this.favoriteDropTargetIndex,
    required this.onFavoriteDropTargetChanged,
    required this.onFavoriteDropAccepted,
  });

  final RadioAppController controller;
  final int selectedIndex;
  final List<FavoriteCategory> visibleCategories;
  final bool isDraggingDiscoverStation;
  final int? favoriteDropTargetIndex;
  final ValueChanged<int?> onFavoriteDropTargetChanged;
  final void Function(RadioStation station, int categoryIndex)
  onFavoriteDropAccepted;

  @override
  Widget build(BuildContext context) {
    final totalTabCount = 1 + visibleCategories.length;
    return LayoutBuilder(
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
                ...visibleCategories.map(
                  (category) => NavigationDestination(
                    icon: const Icon(Icons.favorite_border),
                    selectedIcon: const Icon(Icons.favorite),
                    label: category.name,
                  ),
                ),
              ],
            ),
            if (isDraggingDiscoverStation)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width:
                    constraints.maxWidth *
                    (visibleCategories.length / totalTabCount),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: List<Widget>.generate(visibleCategories.length, (
                      index,
                    ) {
                      final category = visibleCategories[index];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: index == visibleCategories.length - 1
                                ? 0
                                : 4,
                          ),
                          child: DragTarget<RadioStation>(
                            onWillAcceptWithDetails: (details) {
                              final canAccept = !controller.isFavorite(
                                details.data.stationUuid,
                                categoryId: category.id,
                              );
                              onFavoriteDropTargetChanged(
                                canAccept ? index : null,
                              );
                              return canAccept;
                            },
                            onLeave: (_) => onFavoriteDropTargetChanged(null),
                            onAcceptWithDetails: (details) {
                              onFavoriteDropAccepted(details.data, index);
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isActive =
                                  favoriteDropTargetIndex == index &&
                                  candidateData.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(
                                          0xFFFF8A5B,
                                        ).withValues(alpha: 0.18)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
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
                    }),
                  ),
                ),
              ),
          ],
        );
      },
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
  const _FavoritesTab({required this.controller, required this.category});

  final RadioAppController controller;
  final FavoriteCategory category;

  @override
  Widget build(BuildContext context) {
    return _StationList(
      controller: controller,
      stations: controller.favoritesForCategory(category.id),
      emptyMessage:
          'No favorites in ${category.name} yet. Save stations from Stations to build this category.',
      onReorder: (oldIndex, newIndex) {
        controller.reorderFavorites(
          categoryId: category.id,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );
      },
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

    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
        child: Row(
          children: [
            if (controller.showStationIcon) ...[
              SizedBox.square(
                dimension: 36,
                child: _StationArtwork(station: station),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: _PlayerBarText(
                station: station,
                playback: playback,
                playbackStalled: controller.playbackStalled,
                playbackStallReason: controller.playbackStallReason,
                sleepTimerRemaining: controller.sleepTimerRemaining,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
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
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      else
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          onPressed: playback.isPlaying
              ? controller.pausePlayback
              : controller.resumePlayback,
          icon: Icon(
            playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
      _SleepTimerButton(controller: controller),
      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: controller.stopPlayback,
        icon: const Icon(Icons.close_rounded),
      ),
    ];
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton({required this.controller});

  static const int _customSleepTimerValue = -1;

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final remaining = controller.sleepTimerRemaining;
    final active = controller.isSleepTimerActive;
    return PopupMenuButton<int>(
      tooltip: active
          ? 'Sleep timer: ${_formatSleepTimerRemaining(remaining)}'
          : 'Sleep timer',
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
      icon: Badge(
        isLabelVisible: active,
        smallSize: 8,
        child: Icon(
          active ? Icons.timer_rounded : Icons.timer_outlined,
          color: active ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      color: const Color(0xFF111A24),
      onSelected: (minutes) async {
        if (minutes == _customSleepTimerValue) {
          final customDuration = await _showCustomSleepTimerDialog(context);
          if (customDuration != null && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.setSleepTimer(customDuration);
            });
          }
          return;
        }
        if (minutes <= 0) {
          controller.cancelSleepTimer();
          return;
        }
        controller.setSleepTimer(Duration(minutes: minutes));
      },
      itemBuilder: (context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(value: 0, enabled: active, child: const Text('Off')),
        const PopupMenuDivider(),
        ...RadioAppController.sleepTimerOptions.map(
          (duration) => PopupMenuItem<int>(
            value: duration.inMinutes,
            child: Text(_formatSleepTimerOption(duration)),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(
          value: _customSleepTimerValue,
          child: Text('Custom'),
        ),
      ],
    );
  }

  Future<Duration?> _showCustomSleepTimerDialog(BuildContext context) async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => const _CustomSleepTimerDialog(),
    );

    if (minutes == null) {
      return null;
    }
    return Duration(minutes: minutes);
  }
}

class _CustomSleepTimerDialog extends StatefulWidget {
  const _CustomSleepTimerDialog();

  @override
  State<_CustomSleepTimerDialog> createState() =>
      _CustomSleepTimerDialogState();
}

class _CustomSleepTimerDialogState extends State<_CustomSleepTimerDialog> {
  late final TextEditingController _textController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_textController.text.trim());
    if (value == null || value <= 0) {
      setState(() {
        _errorText = 'Enter a number greater than 0.';
      });
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom sleep timer'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Minutes',
          hintText: '90',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Start')),
      ],
    );
  }
}

class _PlayerBarText extends StatelessWidget {
  const _PlayerBarText({
    required this.station,
    required this.playback,
    required this.playbackStalled,
    required this.playbackStallReason,
    required this.sleepTimerRemaining,
    required this.theme,
  });

  final RadioStation station;
  final PlaybackSnapshot playback;
  final bool playbackStalled;
  final PlaybackStallReason? playbackStallReason;
  final Duration sleepTimerRemaining;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.notoSans(
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    final status = playbackStalled
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
        : 'Paused';
    final metadata = playback.isPlaying
        ? _cleanNowPlayingMetadata(playback.nowPlaying?.stationName)
        : null;
    final parts = <String>[
      station.displayName,
      status,
      if (metadata != null && metadata.isNotEmpty) metadata,
      if (sleepTimerRemaining > Duration.zero)
        'Sleep timer: ${_formatSleepTimerRemaining(sleepTimerRemaining)}',
    ];
    final message = parts.join('  •  ');

    return _ChyronText(
      text: message,
      style: textStyle.copyWith(
        color: playback.hasError ? theme.colorScheme.error : Colors.white,
      ),
    );
  }
}

String? _cleanNowPlayingMetadata(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  switch (normalized.toLowerCase()) {
    case 'no name':
    case 'noname':
    case 'unknown':
    case 'unknown station':
    case 'untitled':
      return null;
  }

  return normalized;
}

class _ChyronText extends StatefulWidget {
  const _ChyronText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_ChyronText> createState() => _ChyronTextState();
}

class _ChyronTextState extends State<_ChyronText> {
  late final ScrollController _scrollController;
  Timer? _delayTimer;
  int _animationGeneration = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didUpdateWidget(covariant _ChyronText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _animationGeneration += 1;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final generation = _animationGeneration;
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      return;
    }

    await _delay(const Duration(seconds: 2), generation);
    if (!mounted ||
        !_scrollController.hasClients ||
        generation != _animationGeneration) {
      return;
    }
    while (mounted &&
        _scrollController.hasClients &&
        generation == _animationGeneration) {
      final distance = _scrollController.position.maxScrollExtent;
      if (distance <= 0) {
        return;
      }
      await _scrollController.animateTo(
        distance,
        duration: Duration(
          milliseconds: (distance * 35).round().clamp(3500, 20000),
        ),
        curve: Curves.linear,
      );
      if (!mounted ||
          !_scrollController.hasClients ||
          generation != _animationGeneration) {
        return;
      }
      await _delay(const Duration(seconds: 1), generation);
      if (!mounted ||
          !_scrollController.hasClients ||
          generation != _animationGeneration) {
        return;
      }
      _scrollController.jumpTo(0);
      await _delay(const Duration(seconds: 1), generation);
    }
  }

  Future<void> _delay(Duration duration, int generation) {
    _delayTimer?.cancel();
    final completer = Completer<void>();
    _delayTimer = Timer(duration, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future.whenComplete(() {
      if (generation == _animationGeneration) {
        _delayTimer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ClipRect(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.text,
              maxLines: 1,
              softWrap: false,
              style: widget.style,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatSleepTimerOption(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 60) {
    return '$minutes minutes';
  }
  final hours = duration.inHours;
  final remainingMinutes = minutes.remainder(60);
  if (remainingMinutes == 0) {
    return hours == 1 ? '1 hour' : '$hours hours';
  }
  return '$hours h $remainingMinutes min';
}

String _formatSleepTimerRemaining(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds <= 0) {
    return 'less than 1 min';
  }
  final minutes = (totalSeconds / 60).ceil();
  if (minutes < 60) {
    return '$minutes min';
  }
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes.remainder(60);
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainingMinutes}m';
}
