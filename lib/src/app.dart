import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/audio_engine.dart';
import 'controllers/radio_app_controller.dart';
import 'models/radio_station.dart';

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
  bool _isFavoriteDropTargetActive = false;
  bool _isDraggingDiscoverStation = false;

  RadioAppController get controller => widget.controller;

  void _handleFavoriteDrop(RadioStation station) {
    unawaited(_saveFavoriteFromDrop(station));
  }

  Future<void> _saveFavoriteFromDrop(RadioStation station) async {
    if (!controller.isFavorite(station.stationUuid)) {
      await controller.toggleFavorite(station);
    }
    controller.selectTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
                      selectedIndex: controller.selectedTab,
                      onDestinationSelected: controller.selectTab,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.explore_outlined),
                          selectedIcon: Icon(Icons.explore),
                          label: 'Discover',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.favorite_border),
                          selectedIcon: Icon(Icons.favorite),
                          label: 'Favorites',
                        ),
                      ],
                    ),
                    if (_isDraggingDiscoverStation)
                      Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        width: constraints.maxWidth / 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: DragTarget<RadioStation>(
                            onWillAcceptWithDetails: (details) {
                              final canAccept = !controller.isFavorite(
                                details.data.stationUuid,
                              );
                              setState(() {
                                _isFavoriteDropTargetActive = canAccept;
                              });
                              return canAccept;
                            },
                            onLeave: (_) {
                              setState(() {
                                _isFavoriteDropTargetActive = false;
                              });
                            },
                            onAcceptWithDetails: (details) {
                              setState(() {
                                _isFavoriteDropTargetActive = false;
                                _isDraggingDiscoverStation = false;
                              });
                              _handleFavoriteDrop(details.data);
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isActive =
                                  _isFavoriteDropTargetActive &&
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
                      index: controller.selectedTab,
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
                                _isFavoriteDropTargetActive = false;
                              }
                            });
                          },
                        ),
                        _FavoritesTab(controller: controller),
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
  const _FavoritesTab({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return _StationList(
      controller: controller,
      stations: controller.favorites,
      emptyMessage:
          'No favorites yet. Save stations from Discover to build a personal set.',
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final canCircleThroughFavorites = controller.canCircleThroughFavorites;
        final selectedCountriesSummary = _selectedCountriesSummary(
          controller.countryCodes,
        );

        return ListView(
          children: [
            Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          _DiscoverCountriesPage(controller: controller),
                    ),
                  );
                },
                title: Text(
                  'Discover countries',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  selectedCountriesSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          _ManualStationsPage(controller: controller),
                    ),
                  );
                },
                title: Text(
                  'Manual stations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  controller.manualStations.isEmpty
                      ? 'No manually added stations.'
                      : '${controller.manualStations.length} stations',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
            ),
            Card(
              child: CheckboxListTile(
                value: controller.showStationIcon,
                onChanged: (value) {
                  controller.setShowStationIcon(value ?? false);
                },
                title: Text(
                  'Show station icon',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Display station artwork in lists and the player bar.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
            ),
            Card(
              child: CheckboxListTile(
                value: controller.circleThroughFavorites,
                onChanged: canCircleThroughFavorites
                    ? (value) {
                        controller.setCircleThroughFavorites(value ?? false);
                      }
                    : null,
                title: Text(
                  'Auto-play next favorite',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: canCircleThroughFavorites ? null : Colors.white38,
                  ),
                ),
                subtitle: Text(
                  canCircleThroughFavorites
                      ? 'When a stream fails, move to the next favorite and wrap to the start.'
                      : 'When a stream fails, move to the next favorite and wrap to the start. Add at least two favorites to enable this option.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: canCircleThroughFavorites
                        ? Colors.white70
                        : Colors.white38,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ManualStationsPage extends StatelessWidget {
  const _ManualStationsPage({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        return _Shell(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manual stations',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  _AddManualStationPage(controller: controller),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      children: [
                        if (controller.manualStations.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () async {
                                final confirmed =
                                    await _confirmDeleteAllManualStations(
                                      context,
                                    );
                                if (confirmed) {
                                  await controller.removeAllManualStations();
                                }
                              },
                              icon: Icon(
                                Icons.delete_sweep_rounded,
                                color: theme.colorScheme.error,
                              ),
                              label: Text(
                                'Delete all',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                        if (controller.manualStations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No manually added stations.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          )
                        else
                          ...controller.manualStations.map(
                            (station) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                child: ListTile(
                                  title: Text(station.displayName),
                                  subtitle: Text(
                                    station.bestStreamUrl,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      await controller.removeManualStation(
                                        station.stationUuid,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: theme.colorScheme.error,
                                    ),
                                    tooltip: 'Delete station',
                                  ),
                                ),
                              ),
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

  Future<bool> _confirmDeleteAllManualStations(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete all manual stations?'),
          content: const Text('This removes all stations you added manually.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete all'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

class _AddManualStationPage extends StatefulWidget {
  const _AddManualStationPage({required this.controller});

  final RadioAppController controller;

  @override
  State<_AddManualStationPage> createState() => _AddManualStationPageState();
}

class _AddManualStationPageState extends State<_AddManualStationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _streamUrlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _streamUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streamUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.controller.addManualStation(
      name: _nameController.text,
      streamUrl: _streamUrlController.text,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Shell(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add station',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Station name',
                                  hintText: 'My station',
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Enter a station name.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _streamUrlController,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _save(),
                                decoration: const InputDecoration(
                                  labelText: 'Stream URL',
                                  hintText: 'https://example.com/stream',
                                ),
                                validator: (value) {
                                  final uri = Uri.tryParse(
                                    (value ?? '').trim(),
                                  );
                                  if (uri == null ||
                                      uri.scheme.trim().isEmpty ||
                                      uri.host.trim().isEmpty) {
                                    return 'Enter a valid stream URL.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverCountriesPage extends StatefulWidget {
  const _DiscoverCountriesPage({required this.controller});

  final RadioAppController controller;

  @override
  State<_DiscoverCountriesPage> createState() => _DiscoverCountriesPageState();
}

class _DiscoverCountriesPageState extends State<_DiscoverCountriesPage> {
  late List<String> _selectedCountryCodes;

  @override
  void initState() {
    super.initState();
    _selectedCountryCodes = List<String>.from(widget.controller.countryCodes);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveAndClose() async {
    await widget.controller.setCountryCodes(_selectedCountryCodes);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openAddCountryPage() async {
    final addedCountryCode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) =>
            _AddCountryPage(selectedCountryCodes: _selectedCountryCodes),
      ),
    );
    if (addedCountryCode == null || !mounted) {
      return;
    }

    setState(() {
      if (!_selectedCountryCodes.contains(addedCountryCode)) {
        _selectedCountryCodes.add(addedCountryCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedOptions = _countryOptionsForCodes(_selectedCountryCodes);
    final selectedListHeight = (selectedOptions.length * 72.0).clamp(
      72.0,
      220.0,
    );

    return _Shell(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Discover countries',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _saveAndClose,
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'At least one country must remain selected.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected countries',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drag to reorder',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: _openAddCountryPage,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add country'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: selectedListHeight.toDouble(),
                              child: ReorderableListView.builder(
                                buildDefaultDragHandles: false,
                                itemCount: selectedOptions.length,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) {
                                      newIndex -= 1;
                                    }
                                    final moved = _selectedCountryCodes
                                        .removeAt(oldIndex);
                                    _selectedCountryCodes.insert(
                                      newIndex,
                                      moved,
                                    );
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final option = selectedOptions[index];
                                  final canRemove =
                                      _selectedCountryCodes.length > 1;
                                  return Row(
                                    key: ValueKey(option.code),
                                    children: [
                                      Expanded(
                                        child: ReorderableDragStartListener(
                                          index: index,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(option.name),
                                            subtitle: Text(option.code),
                                            trailing: const Icon(
                                              Icons.drag_handle_rounded,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkResponse(
                                        onTap: canRemove
                                            ? () {
                                                setState(() {
                                                  _selectedCountryCodes.remove(
                                                    option.code,
                                                  );
                                                });
                                              }
                                            : null,
                                        radius: 18,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: canRemove
                                                ? theme.colorScheme.error
                                                : theme.colorScheme.error
                                                      .withValues(alpha: 0.35),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCountryPage extends StatefulWidget {
  const _AddCountryPage({required this.selectedCountryCodes});

  final List<String> selectedCountryCodes;

  @override
  State<_AddCountryPage> createState() => _AddCountryPageState();
}

class _AddCountryPageState extends State<_AddCountryPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _query = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableOptions = _availableCountryOptions(
      _countryOptions,
      widget.selectedCountryCodes,
      _query,
    );

    return _Shell(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add country',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search countries',
                        hintText: 'Serbia or RS',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        child: availableOptions.isEmpty
                            ? Center(
                                child: Text(
                                  'No countries available.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: availableOptions.length,
                                itemBuilder: (context, index) {
                                  final option = availableOptions[index];
                                  return ListTile(
                                    onTap: () {
                                      Navigator.of(context).pop(option.code);
                                    },
                                    title: Text(option.name),
                                    subtitle: Text(option.code),
                                  );
                                },
                              ),
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
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SettingsView(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugViewPage extends StatefulWidget {
  const _DebugViewPage({required this.controller});

  final RadioAppController controller;

  @override
  State<_DebugViewPage> createState() => _DebugViewPageState();
}

class _DebugViewPageState extends State<_DebugViewPage> {
  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Debug view',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _DebugView(controller: widget.controller),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugView extends StatelessWidget {
  const _DebugView({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final station = controller.currentStation;
        if (station == null) {
          return Text(
            'No station is currently playing.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          );
        }

        final payload = const JsonEncoder.withIndent(
          '  ',
        ).convert(station.toJson());
        return SingleChildScrollView(
          child: SelectableText(
            payload,
            style: GoogleFonts.notoSansMono(
              textStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        );
      },
    );
  }
}

class _StationList extends StatelessWidget {
  const _StationList({
    required this.controller,
    required this.stations,
    required this.emptyMessage,
    this.isLoading = false,
    this.draggableStations = false,
    this.onDragStateChanged,
  });

  final RadioAppController controller;
  final List<RadioStation> stations;
  final String emptyMessage;
  final bool isLoading;
  final bool draggableStations;
  final ValueChanged<bool>? onDragStateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        if (isLoading && stations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (stations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          )
        else
          ...stations.map(
            (station) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StationTile(
                station: station,
                controller: controller,
                draggable: draggableStations,
                onDragStateChanged: onDragStateChanged,
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

List<RadioStation> _filterStationsByCountryCodesInOrder(
  List<RadioStation> stations,
  List<String> countryCodes,
) {
  final normalizedCountryCodes = countryCodes
      .map((value) => value.trim().toUpperCase())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (normalizedCountryCodes.isEmpty) {
    return stations;
  }

  final stationsByCountry = <String, List<RadioStation>>{};
  for (final station in stations) {
    final stationCountryCode = station.countryCode.trim().toUpperCase();
    if (!normalizedCountryCodes.contains(stationCountryCode)) {
      continue;
    }

    stationsByCountry
        .putIfAbsent(stationCountryCode, () => <RadioStation>[])
        .add(station);
  }

  final orderedStations = <RadioStation>[];
  for (final countryCode in normalizedCountryCodes) {
    orderedStations.addAll(
      stationsByCountry[countryCode] ?? const <RadioStation>[],
    );
  }

  return orderedStations;
}

List<RadioStation> _filterDiscoverStationsByQuery(
  List<RadioStation> stations,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return stations;
  }

  return stations
      .where((station) {
        final haystack = <String>[
          station.displayName,
          station.displayLocation,
          station.displayLanguage,
          station.displayTags,
          station.country,
          station.countryCode,
          station.state,
          station.language,
          station.tags,
          station.codec,
        ].join(' ').toLowerCase();
        return haystack.contains(normalizedQuery);
      })
      .toList(growable: false);
}

class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.controller,
    this.draggable = false,
    this.onDragStateChanged,
  });

  final RadioStation station;
  final RadioAppController controller;
  final bool draggable;
  final ValueChanged<bool>? onDragStateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stationTitleStyle = GoogleFonts.notoSans(
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
    final stationSubtitleStyle = GoogleFonts.notoSans(
      textStyle: theme.textTheme.bodyMedium,
    );
    final isCurrent =
        controller.currentStation?.stationUuid == station.stationUuid;
    final isFavorite = controller.isFavorite(station.stationUuid);

    final tile = Card(
      color: isCurrent ? const Color(0xFF1A2736) : null,
      child: ListTile(
        onTap: () => controller.playStation(station),
        contentPadding: const EdgeInsets.only(
          left: 4,
          right: 0,
          top: 8,
          bottom: 8,
        ),
        minLeadingWidth: controller.showStationIcon ? 44 : 0,
        horizontalTitleGap: controller.showStationIcon ? 8 : 0,
        leading: controller.showStationIcon
            ? _StationArtwork(station: station)
            : null,
        title: Text(
          station.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: stationTitleStyle,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            [
              station.displayLocation,
              if (station.displayLanguage.isNotEmpty) station.displayLanguage,
              if (station.codec.isNotEmpty || station.bitrate > 0)
                '${station.codec}${station.bitrate > 0 ? ' • ${station.bitrate} kbps' : ''}',
              if (station.displayTags.isNotEmpty) station.displayTags,
            ].where((value) => value.trim().isNotEmpty).join('\n'),
            style: stationSubtitleStyle,
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
          onPressed: () => controller.toggleFavorite(station),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? const Color(0xFFFF8A5B) : null,
          ),
        ),
      ),
    );

    if (!draggable) {
      return tile;
    }

    return LongPressDraggable<RadioStation>(
      data: station,
      onDragStarted: () => onDragStateChanged?.call(true),
      onDragCompleted: () => onDragStateChanged?.call(false),
      onDraggableCanceled: (velocity, offset) =>
          onDragStateChanged?.call(false),
      onDragEnd: (_) => onDragStateChanged?.call(false),
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Opacity(
            opacity: 0.92,
            child: _StationDragFeedback(
              station: station,
              controller: controller,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: IgnorePointer(child: tile),
      ),
      child: tile,
    );
  }
}

class _StationDragFeedback extends StatelessWidget {
  const _StationDragFeedback({required this.station, required this.controller});

  final RadioStation station;
  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: const Color(0xFF1A2736),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.showStationIcon) ...[
              SizedBox(
                width: 40,
                height: 40,
                child: _StationArtwork(station: station),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (station.displayLocation.isNotEmpty)
                    Text(
                      station.displayLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.favorite_rounded, color: Color(0xFFFF8A5B)),
          ],
        ),
      ),
    );
  }
}

class _StationArtwork extends StatelessWidget {
  const _StationArtwork({required this.station});

  final RadioStation station;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 56,
        height: 56,
        child: station.hasArtwork
            ? Image.network(
                station.favicon,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _FallbackArtwork(theme: theme),
              )
            : _FallbackArtwork(theme: theme),
      ),
    );
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.75),
            const Color(0xFF2F4858),
          ],
        ),
      ),
      child: const Icon(Icons.multitrack_audio_rounded, color: Colors.white),
    );
  }
}

class _CountryOption {
  const _CountryOption(this.code, this.name);

  final String code;
  final String name;
}

String _selectedCountriesSummary(List<String> selectedCountryCodes) {
  final selectedOptions = _countryOptionsForCodes(selectedCountryCodes);
  if (selectedOptions.isEmpty) {
    return 'Unknown';
  }

  final names = selectedOptions.map((option) => option.name).toList();
  return names.join(', ');
}

List<_CountryOption> _countryOptionsForCodes(List<String> countryCodes) {
  final selectedCodes = countryCodes
      .map((value) => value.trim().toUpperCase())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  return selectedCodes
      .map(
        (code) => _countryOptions.firstWhere(
          (option) => option.code == code,
          orElse: () => _CountryOption(code, code),
        ),
      )
      .toList(growable: false);
}

List<_CountryOption> _filterCountryOptions(
  List<_CountryOption> allOptions,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();

  return allOptions
      .where((option) {
        if (normalizedQuery.isEmpty) {
          return true;
        }

        return option.name.toLowerCase().contains(normalizedQuery) ||
            option.code.toLowerCase().contains(normalizedQuery);
      })
      .toList(growable: false);
}

List<_CountryOption> _availableCountryOptions(
  List<_CountryOption> allOptions,
  List<String> selectedCountryCodes,
  String query,
) {
  final selectedCodes = selectedCountryCodes
      .map((value) => value.trim().toUpperCase())
      .where((value) => value.isNotEmpty)
      .toSet();

  return _filterCountryOptions(allOptions, query)
      .where((option) => !selectedCodes.contains(option.code))
      .toList(growable: false);
}

const List<_CountryOption> _countryOptions = [
  _CountryOption('AF', 'Afghanistan'),
  _CountryOption('AL', 'Albania'),
  _CountryOption('DZ', 'Algeria'),
  _CountryOption('AD', 'Andorra'),
  _CountryOption('AO', 'Angola'),
  _CountryOption('AG', 'Antigua and Barbuda'),
  _CountryOption('AR', 'Argentina'),
  _CountryOption('AM', 'Armenia'),
  _CountryOption('AU', 'Australia'),
  _CountryOption('AT', 'Austria'),
  _CountryOption('AZ', 'Azerbaijan'),
  _CountryOption('BS', 'Bahamas'),
  _CountryOption('BH', 'Bahrain'),
  _CountryOption('BD', 'Bangladesh'),
  _CountryOption('BB', 'Barbados'),
  _CountryOption('BY', 'Belarus'),
  _CountryOption('BE', 'Belgium'),
  _CountryOption('BZ', 'Belize'),
  _CountryOption('BJ', 'Benin'),
  _CountryOption('BT', 'Bhutan'),
  _CountryOption('BO', 'Bolivia'),
  _CountryOption('BA', 'Bosnia and Herzegovina'),
  _CountryOption('BW', 'Botswana'),
  _CountryOption('BR', 'Brazil'),
  _CountryOption('BN', 'Brunei'),
  _CountryOption('BG', 'Bulgaria'),
  _CountryOption('BF', 'Burkina Faso'),
  _CountryOption('BI', 'Burundi'),
  _CountryOption('CV', 'Cabo Verde'),
  _CountryOption('KH', 'Cambodia'),
  _CountryOption('CM', 'Cameroon'),
  _CountryOption('CA', 'Canada'),
  _CountryOption('CF', 'Central African Republic'),
  _CountryOption('TD', 'Chad'),
  _CountryOption('CL', 'Chile'),
  _CountryOption('CN', 'China'),
  _CountryOption('CO', 'Colombia'),
  _CountryOption('KM', 'Comoros'),
  _CountryOption('CG', 'Congo'),
  _CountryOption('CR', 'Costa Rica'),
  _CountryOption('HR', 'Croatia'),
  _CountryOption('CU', 'Cuba'),
  _CountryOption('CY', 'Cyprus'),
  _CountryOption('CZ', 'Czechia'),
  _CountryOption('CD', 'Democratic Republic of the Congo'),
  _CountryOption('DK', 'Denmark'),
  _CountryOption('DJ', 'Djibouti'),
  _CountryOption('DM', 'Dominica'),
  _CountryOption('DO', 'Dominican Republic'),
  _CountryOption('EC', 'Ecuador'),
  _CountryOption('EG', 'Egypt'),
  _CountryOption('SV', 'El Salvador'),
  _CountryOption('GQ', 'Equatorial Guinea'),
  _CountryOption('ER', 'Eritrea'),
  _CountryOption('EE', 'Estonia'),
  _CountryOption('SZ', 'Eswatini'),
  _CountryOption('ET', 'Ethiopia'),
  _CountryOption('FJ', 'Fiji'),
  _CountryOption('FI', 'Finland'),
  _CountryOption('FR', 'France'),
  _CountryOption('GA', 'Gabon'),
  _CountryOption('GM', 'Gambia'),
  _CountryOption('GE', 'Georgia'),
  _CountryOption('DE', 'Germany'),
  _CountryOption('GH', 'Ghana'),
  _CountryOption('GR', 'Greece'),
  _CountryOption('GD', 'Grenada'),
  _CountryOption('GT', 'Guatemala'),
  _CountryOption('GN', 'Guinea'),
  _CountryOption('GW', 'Guinea-Bissau'),
  _CountryOption('GY', 'Guyana'),
  _CountryOption('HT', 'Haiti'),
  _CountryOption('HN', 'Honduras'),
  _CountryOption('HU', 'Hungary'),
  _CountryOption('IS', 'Iceland'),
  _CountryOption('IN', 'India'),
  _CountryOption('ID', 'Indonesia'),
  _CountryOption('IR', 'Iran'),
  _CountryOption('IQ', 'Iraq'),
  _CountryOption('IE', 'Ireland'),
  _CountryOption('IL', 'Israel'),
  _CountryOption('IT', 'Italy'),
  _CountryOption('JM', 'Jamaica'),
  _CountryOption('JP', 'Japan'),
  _CountryOption('JO', 'Jordan'),
  _CountryOption('KZ', 'Kazakhstan'),
  _CountryOption('KE', 'Kenya'),
  _CountryOption('KI', 'Kiribati'),
  _CountryOption('KW', 'Kuwait'),
  _CountryOption('KG', 'Kyrgyzstan'),
  _CountryOption('LA', 'Laos'),
  _CountryOption('LV', 'Latvia'),
  _CountryOption('LB', 'Lebanon'),
  _CountryOption('LS', 'Lesotho'),
  _CountryOption('LR', 'Liberia'),
  _CountryOption('LY', 'Libya'),
  _CountryOption('LI', 'Liechtenstein'),
  _CountryOption('LT', 'Lithuania'),
  _CountryOption('LU', 'Luxembourg'),
  _CountryOption('MG', 'Madagascar'),
  _CountryOption('MW', 'Malawi'),
  _CountryOption('MY', 'Malaysia'),
  _CountryOption('MV', 'Maldives'),
  _CountryOption('ML', 'Mali'),
  _CountryOption('MT', 'Malta'),
  _CountryOption('MH', 'Marshall Islands'),
  _CountryOption('MR', 'Mauritania'),
  _CountryOption('MU', 'Mauritius'),
  _CountryOption('MX', 'Mexico'),
  _CountryOption('FM', 'Micronesia'),
  _CountryOption('MD', 'Moldova'),
  _CountryOption('MC', 'Monaco'),
  _CountryOption('MN', 'Mongolia'),
  _CountryOption('ME', 'Montenegro'),
  _CountryOption('MA', 'Morocco'),
  _CountryOption('MZ', 'Mozambique'),
  _CountryOption('MM', 'Myanmar'),
  _CountryOption('NA', 'Namibia'),
  _CountryOption('NR', 'Nauru'),
  _CountryOption('NP', 'Nepal'),
  _CountryOption('NL', 'Netherlands'),
  _CountryOption('NZ', 'New Zealand'),
  _CountryOption('NI', 'Nicaragua'),
  _CountryOption('NE', 'Niger'),
  _CountryOption('NG', 'Nigeria'),
  _CountryOption('KP', 'North Korea'),
  _CountryOption('MK', 'North Macedonia'),
  _CountryOption('NO', 'Norway'),
  _CountryOption('OM', 'Oman'),
  _CountryOption('PK', 'Pakistan'),
  _CountryOption('PW', 'Palau'),
  _CountryOption('PA', 'Panama'),
  _CountryOption('PG', 'Papua New Guinea'),
  _CountryOption('PY', 'Paraguay'),
  _CountryOption('PE', 'Peru'),
  _CountryOption('PH', 'Philippines'),
  _CountryOption('PL', 'Poland'),
  _CountryOption('PT', 'Portugal'),
  _CountryOption('QA', 'Qatar'),
  _CountryOption('RO', 'Romania'),
  _CountryOption('RU', 'Russia'),
  _CountryOption('RW', 'Rwanda'),
  _CountryOption('KN', 'Saint Kitts and Nevis'),
  _CountryOption('LC', 'Saint Lucia'),
  _CountryOption('VC', 'Saint Vincent and the Grenadines'),
  _CountryOption('WS', 'Samoa'),
  _CountryOption('SM', 'San Marino'),
  _CountryOption('ST', 'Sao Tome and Principe'),
  _CountryOption('SA', 'Saudi Arabia'),
  _CountryOption('SN', 'Senegal'),
  _CountryOption('RS', 'Serbia'),
  _CountryOption('SC', 'Seychelles'),
  _CountryOption('SL', 'Sierra Leone'),
  _CountryOption('SG', 'Singapore'),
  _CountryOption('SK', 'Slovakia'),
  _CountryOption('SI', 'Slovenia'),
  _CountryOption('SB', 'Solomon Islands'),
  _CountryOption('SO', 'Somalia'),
  _CountryOption('ZA', 'South Africa'),
  _CountryOption('KR', 'South Korea'),
  _CountryOption('SS', 'South Sudan'),
  _CountryOption('ES', 'Spain'),
  _CountryOption('LK', 'Sri Lanka'),
  _CountryOption('SD', 'Sudan'),
  _CountryOption('SR', 'Suriname'),
  _CountryOption('SE', 'Sweden'),
  _CountryOption('CH', 'Switzerland'),
  _CountryOption('SY', 'Syria'),
  _CountryOption('TW', 'Taiwan'),
  _CountryOption('TJ', 'Tajikistan'),
  _CountryOption('TZ', 'Tanzania'),
  _CountryOption('TH', 'Thailand'),
  _CountryOption('TL', 'Timor-Leste'),
  _CountryOption('TG', 'Togo'),
  _CountryOption('TO', 'Tonga'),
  _CountryOption('TT', 'Trinidad and Tobago'),
  _CountryOption('TN', 'Tunisia'),
  _CountryOption('TR', 'Turkey'),
  _CountryOption('TM', 'Turkmenistan'),
  _CountryOption('TV', 'Tuvalu'),
  _CountryOption('UG', 'Uganda'),
  _CountryOption('UA', 'Ukraine'),
  _CountryOption('AE', 'United Arab Emirates'),
  _CountryOption('GB', 'United Kingdom'),
  _CountryOption('US', 'United States'),
  _CountryOption('UY', 'Uruguay'),
  _CountryOption('UZ', 'Uzbekistan'),
  _CountryOption('VU', 'Vanuatu'),
  _CountryOption('VA', 'Vatican City'),
  _CountryOption('VE', 'Venezuela'),
  _CountryOption('VN', 'Vietnam'),
  _CountryOption('YE', 'Yemen'),
  _CountryOption('ZM', 'Zambia'),
  _CountryOption('ZW', 'Zimbabwe'),
];

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
