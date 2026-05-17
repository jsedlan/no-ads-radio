part of 'app.dart';

class _SettingsView extends StatefulWidget {
  const _SettingsView({required this.controller});

  final RadioAppController controller;

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView>
    with WidgetsBindingObserver {
  final AndroidSettingsLauncher _settingsLauncher =
      const AndroidSettingsLauncher();
  bool _isIgnoringBatteryOptimizations = false;

  RadioAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshBatteryOptimizationStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshBatteryOptimizationStatus());
    }
  }

  Future<void> _refreshBatteryOptimizationStatus() async {
    final isIgnoringBatteryOptimizations = await _settingsLauncher
        .isIgnoringBatteryOptimizations();
    if (!mounted) {
      return;
    }

    setState(() {
      _isIgnoringBatteryOptimizations = isIgnoringBatteryOptimizations;
    });
  }

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
        final categoriesSummary = _favoriteCategoriesSummary(
          controller.favoriteCategories,
        );

        return ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how the app should look.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _mutedTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<AppThemePreference>(
                      segments: const <ButtonSegment<AppThemePreference>>[
                        ButtonSegment<AppThemePreference>(
                          value: AppThemePreference.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text('Dark'),
                        ),
                        ButtonSegment<AppThemePreference>(
                          value: AppThemePreference.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text('Light'),
                        ),
                      ],
                      selected: <AppThemePreference>{
                        controller.themePreference,
                      },
                      onSelectionChanged: (selection) {
                        controller.setThemePreference(selection.single);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          _CategoriesPage(controller: controller),
                    ),
                  );
                },
                title: Text(
                  'Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  categoriesSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedTextColor(context),
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
                          _RecentlyPlayedPage(controller: controller),
                    ),
                  );
                },
                title: Text(
                  'Recently played',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  controller.recentlyPlayedStations.isEmpty
                      ? 'No recently played stations.'
                      : '${controller.recentlyPlayedStations.length} stations',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedTextColor(context),
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
                          _DiscoverCountriesPage(controller: controller),
                    ),
                  );
                },
                title: Text(
                  'Station countries',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  selectedCountriesSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedTextColor(context),
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
                    color: _mutedTextColor(context),
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
                onTap: () => _openBatterySettings(context),
                title: Text(
                  'Battery usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Set NoAds Radio to Unrestricted in Android settings.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _mutedTextColor(context),
                  ),
                ),
                trailing: IgnorePointer(
                  child: Switch(
                    value: _isIgnoringBatteryOptimizations,
                    onChanged: (_) {},
                  ),
                ),
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
                    color: _mutedTextColor(context),
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
                    color: canCircleThroughFavorites
                        ? null
                        : _disabledTextColor(context),
                  ),
                ),
                subtitle: Text(
                  canCircleThroughFavorites
                      ? 'When a stream fails, move to the next favorite and wrap to the start.'
                      : 'When a stream fails, move to the next favorite and wrap to the start. Add at least two favorites to enable this option.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: canCircleThroughFavorites
                        ? _mutedTextColor(context)
                        : _disabledTextColor(context),
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

  Future<void> _openBatterySettings(BuildContext context) async {
    final opened = await _settingsLauncher.openAppBatterySettings();
    if (opened || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open Android app settings on this device.'),
      ),
    );
  }
}

class _RecentlyPlayedPage extends StatelessWidget {
  const _RecentlyPlayedPage({required this.controller});

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
                          'Recently played',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (controller.recentlyPlayedStations.isNotEmpty)
                        TextButton.icon(
                          onPressed: controller.clearRecentlyPlayed,
                          icon: Icon(
                            Icons.delete_sweep_rounded,
                            color: theme.colorScheme.error,
                          ),
                          label: Text(
                            'Clear',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _StationList(
                      controller: controller,
                      stations: controller.recentlyPlayedStations,
                      emptyMessage: 'No recently played stations yet.',
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

class _CategoriesPage extends StatefulWidget {
  const _CategoriesPage({required this.controller});

  final RadioAppController controller;

  @override
  State<_CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<_CategoriesPage> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final categories = widget.controller.favoriteCategories.isEmpty
        ? const <FavoriteCategory>[
            FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
          ]
        : widget.controller.favoriteCategories;
    _controllers = categories
        .map((category) => TextEditingController(text: category.name))
        .toList(growable: true);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCategory() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  Future<void> _saveAndClose() async {
    final values = _controllers.map((controller) => controller.text).toList();
    await widget.controller.setFavoriteCategories(values);
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
                      'Categories',
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
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add as many categories as you like. Only the first 3 will be visible as tabs on the bottom.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _mutedTextColor(context),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List<Widget>.generate(_controllers.length, (
                              index,
                            ) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _controllers.length - 1
                                      ? 0
                                      : 12,
                                ),
                                child: TextField(
                                  controller: _controllers[index],
                                  textInputAction:
                                      index == _controllers.length - 1
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Category ${index + 1}',
                                    hintText: index == 0
                                        ? 'Favorites'
                                        : 'New category',
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _addCategory,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add category'),
                            ),
                          ],
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
                                color: _mutedTextColor(context),
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
                      'Station countries',
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
                          color: _mutedTextColor(context),
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
                                color: _mutedTextColor(context),
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
                                    color: _mutedTextColor(context),
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
