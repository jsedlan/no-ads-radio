part of 'app.dart';

class RadioHomePage extends StatefulWidget {
  const RadioHomePage({super.key, required this.controller});

  final RadioAppController controller;

  @override
  State<RadioHomePage> createState() => _RadioHomePageState();
}

class _RadioHomePageState extends State<RadioHomePage> {
  int? _categoryDropTargetIndex;
  bool _isDraggingDiscoverStation = false;

  RadioAppController get controller => widget.controller;

  void _handleCategoryDrop(RadioStation station) {
    unawaited(_addToCategoryFromDrop(station));
  }

  Future<void> _addToCategoryFromDrop(RadioStation station) async {
    final category = controller.activeStationCategory;
    if (!controller.isStationInCategory(
      station.identityKey,
      categoryId: category.id,
    )) {
      await controller.toggleStationInCategory(
        station,
        categoryId: category.id,
      );
    }
    controller.selectTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selectedIndex = controller.selectedTab > 2
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
                  isDraggingDiscoverStation: _isDraggingDiscoverStation,
                  categoryDropTargetIndex: _categoryDropTargetIndex,
                  onCategoryDropTargetChanged: (index) {
                    setState(() {
                      _categoryDropTargetIndex = index;
                    });
                  },
                  onCategoryDropAccepted: (station) {
                    setState(() {
                      _categoryDropTargetIndex = null;
                      _isDraggingDiscoverStation = false;
                    });
                    _handleCategoryDrop(station);
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
                              _categoryDropTargetIndex = null;
                            }
                          });
                        },
                      ),
                      _CategoriesTab(controller: controller),
                      _RecentTab(controller: controller),
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
    required this.isDraggingDiscoverStation,
    required this.categoryDropTargetIndex,
    required this.onCategoryDropTargetChanged,
    required this.onCategoryDropAccepted,
  });

  final RadioAppController controller;
  final int selectedIndex;
  final bool isDraggingDiscoverStation;
  final int? categoryDropTargetIndex;
  final ValueChanged<int?> onCategoryDropTargetChanged;
  final ValueChanged<RadioStation> onCategoryDropAccepted;

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
        Expanded(
          child: _CategoriesTopTabDropTarget(
            controller: controller,
            selected: selectedIndex == 1,
            highlighted:
                isDraggingDiscoverStation && categoryDropTargetIndex == 0,
            onCategoryDropTargetChanged: onCategoryDropTargetChanged,
            onCategoryDropAccepted: onCategoryDropAccepted,
          ),
        ),
        Expanded(
          child: _CompactTopTab(
            icon: Icons.history_rounded,
            selectedIcon: Icons.history_rounded,
            label: context.l10n.recent,
            selected: selectedIndex == 2,
            onTap: () => controller.selectTab(2),
          ),
        ),
      ],
    );
  }
}

class _CategoriesTopTabDropTarget extends StatelessWidget {
  const _CategoriesTopTabDropTarget({
    required this.controller,
    required this.selected,
    required this.highlighted,
    required this.onCategoryDropTargetChanged,
    required this.onCategoryDropAccepted,
  });

  final RadioAppController controller;
  final bool selected;
  final bool highlighted;
  final ValueChanged<int?> onCategoryDropTargetChanged;
  final ValueChanged<RadioStation> onCategoryDropAccepted;

  @override
  Widget build(BuildContext context) {
    final category = controller.activeStationCategory;
    final tab = _CompactTopTab(
      icon: Icons.library_music_outlined,
      selectedIcon: Icons.library_music_rounded,
      label: context.l10n.categories,
      selected: selected,
      highlighted: highlighted,
      onTap: () => controller.selectTab(1),
    );

    if (!controller.isBootstrapping && controller.stationCategories.isEmpty) {
      return tab;
    }

    return DragTarget<RadioStation>(
      onWillAcceptWithDetails: (details) {
        final canAccept = !controller.isStationInCategory(
          details.data.identityKey,
          categoryId: category.id,
        );
        onCategoryDropTargetChanged(canAccept ? 0 : null);
        return canAccept;
      },
      onLeave: (_) => onCategoryDropTargetChanged(null),
      onAcceptWithDetails: (details) {
        onCategoryDropAccepted(details.data);
      },
      builder: (context, candidateData, rejectedData) => tab,
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

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.selectedIndex,
    required this.isDraggingDiscoverStation,
    required this.categoryDropTargetIndex,
    required this.onCategoryDropTargetChanged,
    required this.onCategoryDropAccepted,
  });

  final RadioAppController controller;
  final int selectedIndex;
  final bool isDraggingDiscoverStation;
  final int? categoryDropTargetIndex;
  final ValueChanged<int?> onCategoryDropTargetChanged;
  final ValueChanged<RadioStation> onCategoryDropAccepted;

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
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: _TopTabBar(
                    controller: controller,
                    selectedIndex: selectedIndex,
                    isDraggingDiscoverStation: isDraggingDiscoverStation,
                    categoryDropTargetIndex: categoryDropTargetIndex,
                    onCategoryDropTargetChanged: onCategoryDropTargetChanged,
                    onCategoryDropAccepted: onCategoryDropAccepted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Transform.translate(
                offset: const Offset(0, -7),
                child: PopupMenuButton<_HeaderAction>(
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

enum _HeaderAction { settings, about }

class _DiscoverTab extends StatefulWidget {
  const _DiscoverTab({
    required this.controller,
    required this.onDragStateChanged,
  });

  final RadioAppController controller;
  final ValueChanged<bool> onDragStateChanged;

  @override
  State<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<_DiscoverTab> {
  late final TextEditingController _filterController;
  late final FocusNode _filterFocusNode;

  RadioAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController(text: controller.discoverFilter);
    _filterFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _DiscoverTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_filterController.text != controller.discoverFilter) {
      _filterController.text = controller.discoverFilter;
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    _filterFocusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    controller.setDiscoverFilter(value);
    _filterFocusNode.unfocus();
  }

  void _clearSearch() {
    _filterController.clear();
    controller.setDiscoverFilter('');
  }

  Widget _buildSearchControl(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _filterController,
        focusNode: _filterFocusNode,
        textInputAction: TextInputAction.search,
        onChanged: controller.setDiscoverFilter,
        onSubmitted: _submitSearch,
        decoration: InputDecoration(
          hintText: context.l10n.filter,
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: controller.discoverFilter.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: context.l10n.clearFilter,
                ),
          suffixIconConstraints: const BoxConstraints(minWidth: 40),
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    );
  }

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
      header: _buildSearchControl(context),
      isFiltered: controller.discoverFilter.trim().isNotEmpty,
      child: RefreshIndicator(
        onRefresh: controller.refreshDiscover,
        child: _StationList(
          controller: controller,
          stations: stations,
          isLoading: controller.isRefreshingDiscover,
          emptyMessage: context.l10n.noStationsAvailable,
          draggableStations: true,
          onDragStateChanged: widget.onDragStateChanged,
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final category = controller.activeStationCategory;
    final stations = controller.stationsForCategory(category.id);
    final categoryName = _localizedCategoryName(context, category.name);
    return _StationTabContent(
      stationCount: stations.length,
      header: _CategorySelector(controller: controller),
      child: _StationList(
        controller: controller,
        stations: stations,
        emptyMessage: context.l10n.noStationsInCategory(categoryName),
        onReorder: (oldIndex, newIndex) {
          controller.reorderCategoryStations(
            categoryId: category.id,
            oldIndex: oldIndex,
            newIndex: newIndex,
          );
        },
      ),
    );
  }
}

class _RecentTab extends StatelessWidget {
  const _RecentTab({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final stations = controller.recentlyPlayedStations;
    return _StationTabContent(
      stationCount: stations.length,
      statusAction: stations.isEmpty
          ? null
          : TextButton.icon(
              onPressed: controller.clearRecentlyPlayed,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              icon: Icon(
                Icons.delete_sweep_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                context.l10n.clear,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
      child: _StationList(
        controller: controller,
        stations: stations,
        emptyMessage: context.l10n.noRecentlyPlayedYet,
      ),
    );
  }
}

class _StationTabContent extends StatelessWidget {
  const _StationTabContent({
    required this.child,
    required this.stationCount,
    this.header,
    this.isFiltered = false,
    this.statusAction,
  });

  final Widget child;
  final int stationCount;
  final Widget? header;
  final bool isFiltered;
  final Widget? statusAction;

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
          if (header != null) ...[header!, const SizedBox(height: 8)],
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
            child: statusAction == null
                ? Center(child: countLabel)
                : Row(
                    children: [
                      Expanded(child: countLabel),
                      statusAction!,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.stationCategories;
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _SelectedCategoryButton(
                controller: controller,
                onTap: () => _showCategoryPicker(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _CategoriesPage(controller: controller),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: context.l10n.manageCategories,
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryPicker(BuildContext context) async {
    final selectedCategoryId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        final categories = controller.stationCategories;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(
                  context.l10n.chooseCategory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...categories.map((category) {
                final isSelected =
                    category.id == controller.activeStationCategoryId;
                final stationCount = controller
                    .stationsForCategory(category.id)
                    .length;
                return ListTile(
                  selected: isSelected,
                  leading: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                  ),
                  title: Text(_localizedCategoryName(context, category.name)),
                  subtitle: Text(context.l10n.stationCount(stationCount)),
                  onTap: () => Navigator.of(context).pop(category.id),
                );
              }),
            ],
          ),
        );
      },
    );

    if (selectedCategoryId == null) {
      return;
    }

    await controller.selectStationCategory(selectedCategoryId);
  }
}

class _SelectedCategoryButton extends StatelessWidget {
  const _SelectedCategoryButton({
    required this.controller,
    required this.onTap,
  });

  final RadioAppController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = controller.activeStationCategory;
    final categoryName = _localizedCategoryName(context, category.name);
    final foregroundColor = theme.colorScheme.onSecondaryContainer;
    final shape = StadiumBorder(
      side: BorderSide(
        color: theme.colorScheme.secondary.withValues(alpha: 0.35),
      ),
    );
    return Material(
      color: theme.colorScheme.secondaryContainer,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: foregroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
