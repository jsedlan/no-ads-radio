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
          context,
          controller.countryCodes,
        );
        final categoriesSummary = _favoriteCategoriesSummary(
          context,
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
                      context.l10n.language,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.languageDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _mutedTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AppLanguagePreference>(
                      initialValue: controller.languagePreference,
                      isExpanded: true,
                      decoration: const InputDecoration(),
                      items: [
                        DropdownMenuItem<AppLanguagePreference>(
                          value: AppLanguagePreference.system,
                          child: Text(
                            context.l10n.systemDefault,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<AppLanguagePreference>(
                          value: AppLanguagePreference.english,
                          child: Text(
                            context.l10n.english,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<AppLanguagePreference>(
                          value: AppLanguagePreference.serbianCyrillic,
                          child: Text(
                            context.l10n.serbianCyrillic,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<AppLanguagePreference>(
                          value: AppLanguagePreference.serbianLatin,
                          child: Text(
                            context.l10n.serbianLatin,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setLanguagePreference(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                      context.l10n.theme,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.themeDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _mutedTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<AppThemePreference>(
                      segments: <ButtonSegment<AppThemePreference>>[
                        ButtonSegment<AppThemePreference>(
                          value: AppThemePreference.dark,
                          icon: const Icon(Icons.dark_mode_rounded),
                          label: Text(context.l10n.dark),
                        ),
                        ButtonSegment<AppThemePreference>(
                          value: AppThemePreference.light,
                          icon: const Icon(Icons.light_mode_rounded),
                          label: Text(context.l10n.light),
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
                  context.l10n.categories,
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
                  context.l10n.recentlyPlayed,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  controller.recentlyPlayedStations.isEmpty
                      ? context.l10n.noRecentlyPlayed
                      : context.l10n.stationCount(
                          controller.recentlyPlayedStations.length,
                        ),
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
                  context.l10n.stationCountries,
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
                  context.l10n.manualStations,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  controller.manualStations.isEmpty
                      ? context.l10n.noManualStations
                      : context.l10n.stationCount(
                          controller.manualStations.length,
                        ),
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
                  context.l10n.batteryUsage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  context.l10n.batteryUsageDescription,
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
                  context.l10n.showStationIcon,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  context.l10n.showStationIconDescription,
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
                  context.l10n.autoPlayNextFavorite,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: canCircleThroughFavorites
                        ? null
                        : _disabledTextColor(context),
                  ),
                ),
                subtitle: Text(
                  canCircleThroughFavorites
                      ? context.l10n.autoPlayNextFavoriteDescription
                      : context.l10n.autoPlayNextFavoriteDisabledDescription,
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
      SnackBar(content: Text(context.l10n.couldNotOpenAndroidSettings)),
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
                          context.l10n.recentlyPlayed,
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
                            context.l10n.clear,
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
                      emptyMessage: context.l10n.noRecentlyPlayedYet,
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
                    context.l10n.settings,
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
