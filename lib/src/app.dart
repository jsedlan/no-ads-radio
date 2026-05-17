import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/audio_engine.dart';
import 'controllers/radio_app_controller.dart';
import 'models/favorite_category.dart';
import 'models/radio_station.dart';
import 'services/android_settings_launcher.dart';
import 'services/settings_store.dart';

part 'app_settings_pages.dart';
part 'app_station_widgets.dart';

class NoAdsRadioApp extends StatelessWidget {
  const NoAdsRadioApp({super.key, required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'NoAds Radio',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode(controller.themePreference),
          theme: _buildAppTheme(Brightness.light),
          darkTheme: _buildAppTheme(Brightness.dark),
          home: RadioHomePage(controller: controller),
        );
      },
    );
  }
}

ThemeMode _themeMode(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

ThemeData _buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseTheme = ThemeData(brightness: brightness);
  final textTheme = GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme);
  final onSurface = isDark ? Colors.white : const Color(0xFF17202B);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFEF6C32),
      brightness: brightness,
    ),
    textTheme: textTheme.apply(bodyColor: onSurface, displayColor: onSurface),
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0D1117)
        : const Color(0xFFF6F1E8),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF111A24) : const Color(0xFFFFFBF4),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF162231) : const Color(0xFFFFFBF4),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        );
      }),
    ),
  );
}

Color _mutedTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);
}

Color _disabledTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
}

List<Color> _shellGradientColors(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const <Color>[Color(0xFF0D1117), Color(0xFF111827), Color(0xFF1A1025)]
      : const <Color>[Color(0xFFF6F1E8), Color(0xFFFFF7E8), Color(0xFFEAF1F5)];
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
          bottomBar: _PlayerBar(controller: controller),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child, this.bottomBar});

  final Widget child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _shellGradientColors(context),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: bottomBar,
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _CompactTopTab(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: 'Stations',
            selected: selectedIndex == 0,
            onTap: () => controller.selectTab(0),
          ),
        ),
        ...List<Widget>.generate(visibleCategories.length, (index) {
          final category = visibleCategories[index];
          final tabIndex = index + 1;
          final tab = _CompactTopTab(
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            label: category.name,
            selected: selectedIndex == tabIndex,
            highlighted:
                isDraggingDiscoverStation && favoriteDropTargetIndex == index,
            onTap: () => controller.selectTab(tabIndex),
          );

          final target = DragTarget<RadioStation>(
            onWillAcceptWithDetails: (details) {
              final canAccept = !controller.isFavorite(
                details.data.stationUuid,
                categoryId: category.id,
              );
              onFavoriteDropTargetChanged(canAccept ? index : null);
              return canAccept;
            },
            onLeave: (_) => onFavoriteDropTargetChanged(null),
            onAcceptWithDetails: (details) {
              onFavoriteDropAccepted(details.data, index);
            },
            builder: (context, candidateData, rejectedData) => tab,
          );

          return Expanded(child: isDraggingDiscoverStation ? target : tab);
        }),
      ],
    );
  }
}

class _CompactTopTab extends StatelessWidget {
  const _CompactTopTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? const Color(0xFFFF8A5B) : _mutedTextColor(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: highlighted
              ? const Color(0xFFFF8A5B).withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: highlighted
              ? Border.all(color: const Color(0xFFFF8A5B))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, size: 22, color: color),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                height: 1,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({
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
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late final TextEditingController _discoverFilterController;
  late final FocusNode _discoverFilterFocusNode;
  bool _isSearchExpanded = false;

  RadioAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _discoverFilterController = TextEditingController(
      text: controller.discoverFilter,
    );
    _discoverFilterFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSearchExpanded &&
        _discoverFilterController.text != controller.discoverFilter) {
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
    _discoverFilterFocusNode.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() {
      _isSearchExpanded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _discoverFilterFocusNode.requestFocus();
      }
    });
  }

  void _submitSearch([String? value]) {
    controller.setDiscoverFilter(value ?? _discoverFilterController.text);
    controller.selectTab(0);
    setState(() {
      _isSearchExpanded = false;
    });
    _discoverFilterFocusNode.unfocus();
  }

  void _clearSearch() {
    if (_discoverFilterController.text.isNotEmpty) {
      _discoverFilterController.clear();
      controller.setDiscoverFilter('');
      return;
    }

    _discoverFilterController.clear();
    controller.setDiscoverFilter('');
    setState(() {
      _isSearchExpanded = false;
    });
    _discoverFilterFocusNode.unfocus();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _discoverFilterController,
      focusNode: _discoverFilterFocusNode,
      textInputAction: TextInputAction.search,
      onSubmitted: _submitSearch,
      decoration: InputDecoration(
        hintText: 'Filter',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: _clearSearch,
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Clear filter',
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
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
              if (_isSearchExpanded)
                Expanded(
                  child: SizedBox(height: 48, child: _buildSearchField()),
                )
              else ...[
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
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: _TopTabBar(
                      controller: controller,
                      selectedIndex: widget.selectedIndex,
                      visibleCategories: widget.visibleCategories,
                      isDraggingDiscoverStation:
                          widget.isDraggingDiscoverStation,
                      favoriteDropTargetIndex: widget.favoriteDropTargetIndex,
                      onFavoriteDropTargetChanged:
                          widget.onFavoriteDropTargetChanged,
                      onFavoriteDropAccepted: widget.onFavoriteDropAccepted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Transform.translate(
                  offset: const Offset(0, -7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _expandSearch,
                        icon: const Icon(Icons.search_rounded),
                        tooltip: 'Filter stations',
                      ),
                      PopupMenuButton<_HeaderAction>(
                        tooltip: 'More',
                        icon: const Icon(Icons.more_vert_rounded),
                        color: theme.cardTheme.color,
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
                ),
              ],
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
    final playback = controller.playback;

    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFFFFBF4),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
            child: Row(
              children: [
                if (station != null && controller.showStationIcon) ...[
                  SizedBox.square(
                    dimension: 36,
                    child: _StationArtwork(station: station),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: station == null
                      ? const SizedBox.shrink()
                      : _PlayerBarText(
                          station: station,
                          playback: playback,
                          playbackStalled: controller.playbackStalled,
                          playbackStallReason: controller.playbackStallReason,
                          sleepTimerRemaining: controller.sleepTimerRemaining,
                          theme: theme,
                        ),
                ),
                const SizedBox(width: 8),
                ..._playerBarActions(playback, hasStation: station != null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _playerBarActions(
    PlaybackSnapshot playback, {
    required bool hasStation,
  }) {
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
          onPressed: !hasStation
              ? null
              : playback.isPlaying
              ? controller.pausePlayback
              : controller.resumePlayback,
          icon: Icon(
            playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
      _SleepTimerButton(controller: controller, enabled: hasStation),
      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: hasStation ? controller.stopPlayback : null,
        icon: const Icon(Icons.stop_rounded),
      ),
    ];
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton({required this.controller, this.enabled = true});

  static const int _customSleepTimerValue = -1;

  final RadioAppController controller;
  final bool enabled;

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
      enabled: enabled,
      icon: Badge(
        isLabelVisible: active,
        smallSize: 8,
        child: Icon(
          active ? Icons.timer_rounded : Icons.timer_outlined,
          color: !enabled
              ? Theme.of(context).disabledColor
              : active
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      color: Theme.of(context).cardTheme.color,
      onSelected: enabled
          ? (minutes) async {
              if (minutes == _customSleepTimerValue) {
                final customDuration = await _showCustomSleepTimerDialog(
                  context,
                );
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
            }
          : null,
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

    final status = _playerBarStatus(
      playback: playback,
      playbackStalled: playbackStalled,
      playbackStallReason: playbackStallReason,
      stationName: station.displayName,
    );
    final metadata = playback.isPlaying
        ? _cleanNowPlayingMetadata(
            playback.nowPlaying?.stationName,
            stationName: station.displayName,
          )
        : null;
    final parts = <String>[
      station.displayName,
      ?status,
      if (metadata != null && metadata.isNotEmpty) metadata,
      if (sleepTimerRemaining > Duration.zero)
        'Sleep timer: ${_formatSleepTimerRemaining(sleepTimerRemaining)}',
    ];
    final message = parts.join('  •  ');

    return _ChyronText(
      text: message,
      style: textStyle.copyWith(
        color: playback.hasError
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
      ),
    );
  }
}

String? _playerBarStatus({
  required PlaybackSnapshot playback,
  required bool playbackStalled,
  required PlaybackStallReason? playbackStallReason,
  required String stationName,
}) {
  if (playbackStalled) {
    return playbackStallReason == PlaybackStallReason.internetOutage
        ? 'Internet connection lost'
        : playbackStallReason == PlaybackStallReason.streamFailure
        ? 'Stream stopped responding'
        : 'Playback stalled';
  }
  if (playback.hasError) {
    return playback.message ?? 'Playback failed';
  }
  if (playback.isLoading) {
    return 'Buffering stream...';
  }
  if (playback.isPlaying) {
    return _cleanNowPlayingMetadata(
      playback.nowPlaying?.displayTitle,
      stationName: stationName,
    );
  }
  return 'Paused';
}

String? _cleanNowPlayingMetadata(String? value, {required String stationName}) {
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

  if (_isSameOrNearStationName(normalized, stationName)) {
    return null;
  }

  return normalized;
}

bool _isSameOrNearStationName(String value, String stationName) {
  final normalizedValue = _normalizeNowPlayingText(value);
  final normalizedStationName = _normalizeNowPlayingText(stationName);
  if (normalizedValue.isEmpty || normalizedStationName.isEmpty) {
    return false;
  }
  if (normalizedValue == normalizedStationName) {
    return true;
  }
  if (_normalizeNowPlayingTokens(value) ==
      _normalizeNowPlayingTokens(stationName)) {
    return true;
  }

  final shorter = normalizedValue.length < normalizedStationName.length
      ? normalizedValue
      : normalizedStationName;
  final longer = normalizedValue.length < normalizedStationName.length
      ? normalizedStationName
      : normalizedValue;

  return shorter.length >= 6 && longer.contains(shorter);
}

String _normalizeNowPlayingText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

String _normalizeNowPlayingTokens(String value) {
  final tokens =
      value
          .trim()
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((token) => token.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return tokens.join('|');
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
