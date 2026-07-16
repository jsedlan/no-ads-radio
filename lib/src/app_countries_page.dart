part of 'app.dart';

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
                      context.l10n.stationCountries,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _saveAndClose,
                    child: Text(context.l10n.done),
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
                        context.l10n.atLeastOneCountry,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _mutedTextColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.l10n.diasporaCountryNote,
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
                              context.l10n.selectedCountries,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: _openAddCountryPage,
                                icon: const Icon(Icons.add_rounded),
                                label: Text(context.l10n.addCountry),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: selectedListHeight.toDouble(),
                              child: ListView.builder(
                                itemCount: selectedOptions.length,
                                itemBuilder: (context, index) {
                                  final option = selectedOptions[index];
                                  final canRemove =
                                      _selectedCountryCodes.length > 1;
                                  return Row(
                                    key: ValueKey(option.code),
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(option.name),
                                          subtitle: Text(option.code),
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
                      context.l10n.addCountry,
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
                      decoration: InputDecoration(
                        labelText: context.l10n.searchCountries,
                        hintText: context.l10n.searchCountriesHint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        child: availableOptions.isEmpty
                            ? Center(
                                child: Text(
                                  context.l10n.noCountriesAvailable,
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
