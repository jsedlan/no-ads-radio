part of 'app.dart';

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
            ).textTheme.bodyMedium?.copyWith(color: _mutedTextColor(context)),
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
    this.onReorder,
  });

  final RadioAppController controller;
  final List<RadioStation> stations;
  final String emptyMessage;
  final bool isLoading;
  final bool draggableStations;
  final ValueChanged<bool>? onDragStateChanged;
  final ReorderCallback? onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading && stations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (stations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _mutedTextColor(context),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    final reorderCallback = onReorder;
    if (reorderCallback != null) {
      return ReorderableListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: stations.length,
        onReorder: reorderCallback,
        proxyDecorator: (child, index, animation) {
          return Material(color: Colors.transparent, child: child);
        },
        footer: const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final station = stations[index];
          return Column(
            key: ValueKey(station.stationUuid),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  child: _StationTile(
                    station: station,
                    controller: controller,
                    draggable: draggableStations,
                    onDragStateChanged: onDragStateChanged,
                  ),
                ),
              ),
              const _StationDivider(),
            ],
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: stations.length + 1,
      itemBuilder: (context, index) {
        if (index == stations.length) {
          return const SizedBox(height: 24);
        }
        final station = stations[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _StationTile(
                station: station,
                controller: controller,
                draggable: draggableStations,
                onDragStateChanged: onDragStateChanged,
              ),
            ),
            const _StationDivider(),
          ],
        );
      },
    );
  }
}

class _StationDivider extends StatelessWidget {
  const _StationDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 6),
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.7),
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
      margin: EdgeInsets.zero,
      color: isCurrent ? _selectedStationTileColor(context) : null,
      child: ListTile(
        onTap: () => controller.playStation(station),
        contentPadding: const EdgeInsets.only(
          left: 8,
          right: 0,
          top: 0,
          bottom: 0,
        ),
        minTileHeight: controller.showStationIcon ? 48 : 42,
        minVerticalPadding: 0,
        minLeadingWidth: controller.showStationIcon ? 40 : 0,
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
        subtitle: Text(
          _stationSubtitle(station),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: stationSubtitleStyle,
        ),
        dense: true,
        isThreeLine: false,
        trailing: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          visualDensity: VisualDensity.compact,
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

String _stationSubtitle(RadioStation station) {
  final country = station.country.trim().isNotEmpty
      ? station.country.trim()
      : station.countryCode.trim();
  return [
    country,
    ...station.displayTags
        .split(' • ')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty),
  ].where((value) => value.trim().isNotEmpty).join(' • ');
}

class _StationDragFeedback extends StatelessWidget {
  const _StationDragFeedback({required this.station, required this.controller});

  final RadioStation station;
  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: _selectedStationTileColor(context),
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
                        color: _mutedTextColor(context),
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

Color _selectedStationTileColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.colorScheme.primaryContainer.withValues(
    alpha: theme.brightness == Brightness.dark ? 0.32 : 0.42,
  );
}

String _selectedCountriesSummary(List<String> selectedCountryCodes) {
  final selectedOptions = _countryOptionsForCodes(selectedCountryCodes);
  if (selectedOptions.isEmpty) {
    return 'Unknown';
  }

  final names = selectedOptions.map((option) => option.name).toList();
  return names.join(', ');
}

String _favoriteCategoriesSummary(List<FavoriteCategory> categories) {
  final normalized = categories
      .map((category) => category.name.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (normalized.isEmpty) {
    return 'Favorites';
  }
  return normalized.join(', ');
}

List<FavoriteCategory> _visibleCategories(List<FavoriteCategory> categories) {
  final normalized = categories
      .where((category) => category.name.trim().isNotEmpty)
      .toList(growable: false);
  if (normalized.isEmpty) {
    return const <FavoriteCategory>[
      FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
    ];
  }
  return normalized.take(3).toList(growable: false);
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
