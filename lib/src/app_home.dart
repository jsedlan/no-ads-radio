part of 'app.dart';

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
    if (!controller.isFavorite(station.identityKey, categoryId: category.id)) {
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
        if (!controller.hasCompletedCountrySetup) {
          return _CountrySetupPage(controller: controller);
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
            label: context.l10n.stations,
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
            label: _localizedCategoryName(context, category.name),
            selected: selectedIndex == tabIndex,
            highlighted:
                isDraggingDiscoverStation && favoriteDropTargetIndex == index,
            onTap: () => controller.selectTab(tabIndex),
          );

          final target = DragTarget<RadioStation>(
            onWillAcceptWithDetails: (details) {
              final canAccept = !controller.isFavorite(
                details.data.identityKey,
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
    final activeColor = theme.colorScheme.onSurface;
    final color = selected ? activeColor : _mutedTextColor(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: highlighted
              ? activeColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: highlighted
              ? Border.all(color: activeColor.withValues(alpha: 0.35))
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
      onChanged: controller.setDiscoverFilter,
      onSubmitted: _submitSearch,
      decoration: InputDecoration(
        hintText: context.l10n.filter,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: _clearSearch,
          icon: const Icon(Icons.close_rounded),
          tooltip: context.l10n.clearFilter,
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
                        tooltip: context.l10n.filterStations,
                      ),
                      PopupMenuButton<_HeaderAction>(
                        tooltip: context.l10n.more,
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
                            case _HeaderAction.about:
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => const _AboutPage(),
                                ),
                              );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<_HeaderAction>(
                            value: _HeaderAction.settings,
                            child: Text(context.l10n.settings),
                          ),
                          PopupMenuItem<_HeaderAction>(
                            value: _HeaderAction.about,
                            child: Text(context.l10n.about),
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

enum _HeaderAction { settings, about }

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

    return _StationTabContent(
      stationCount: stations.length,
      isFiltered: controller.discoverFilter.trim().isNotEmpty,
      onClearFilter: () => controller.setDiscoverFilter(''),
      child: RefreshIndicator(
        onRefresh: controller.refreshDiscover,
        child: _StationList(
          controller: controller,
          stations: stations,
          isLoading: controller.isRefreshingDiscover,
          emptyMessage: context.l10n.noStationsAvailable,
          draggableStations: true,
          onDragStateChanged: onDragStateChanged,
        ),
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
    final stations = controller.favoritesForCategory(category.id);
    final categoryName = _localizedCategoryName(context, category.name);
    return _StationTabContent(
      stationCount: stations.length,
      child: _StationList(
        controller: controller,
        stations: stations,
        emptyMessage: context.l10n.noFavoritesInCategory(categoryName),
        onReorder: (oldIndex, newIndex) {
          controller.reorderFavorites(
            categoryId: category.id,
            oldIndex: oldIndex,
            newIndex: newIndex,
          );
        },
      ),
    );
  }
}

class _StationTabContent extends StatelessWidget {
  const _StationTabContent({
    required this.child,
    required this.stationCount,
    this.isFiltered = false,
    this.onClearFilter,
  });

  final Widget child;
  final int stationCount;
  final bool isFiltered;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = Text(
      isFiltered
          ? context.l10n.filteredStationCount(stationCount)
          : context.l10n.stationCount(stationCount),
      style: theme.textTheme.labelSmall?.copyWith(
        color: _mutedTextColor(context),
        fontWeight: FontWeight.w600,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
            child: isFiltered
                ? Row(
                    children: [
                      Expanded(child: countLabel),
                      Tooltip(
                        message: context.l10n.clearFilter,
                        child: InkWell(
                          onTap: onClearFilter,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 1,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.l10n.clear,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(child: countLabel),
          ),
        ],
      ),
    );
  }
}
