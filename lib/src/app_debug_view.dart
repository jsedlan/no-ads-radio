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
                    context.l10n.debugView,
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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.activeSource,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _mutedTextColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.activeCatalogSource?.label ??
                    context.l10n.noSourceLoaded,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              _DuplicateStationsSection(
                duplicates: controller.duplicateStations,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.stationLoadingLog,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (controller.catalogLoadEvents.isEmpty)
                Text(
                  context.l10n.noStationLoadingEvents,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedTextColor(context),
                  ),
                )
              else
                ...controller.catalogLoadEvents.reversed.map(
                  (event) => _CatalogLoadEventRow(event: event),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DuplicateStationsSection extends StatelessWidget {
  const _DuplicateStationsSection({required this.duplicates});

  final List<DuplicateStationInfo> duplicates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.duplicateStations,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.duplicateStationCount(duplicates.length),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _mutedTextColor(context),
          ),
        ),
        if (duplicates.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...duplicates.map((duplicate) {
            return _DuplicateStationRow(duplicate: duplicate);
          }),
        ],
      ],
    );
  }
}

class _DuplicateStationRow extends StatelessWidget {
  const _DuplicateStationRow({required this.duplicate});

  final DuplicateStationInfo duplicate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reason = switch (duplicate.reason) {
      DuplicateStationReason.stationUuid => context.l10n.duplicateStationByUuid,
      DuplicateStationReason.nameLocation =>
        context.l10n.duplicateStationByNameLocation,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.content_copy_rounded,
              size: 18,
              color: _mutedTextColor(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  duplicate.station.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _duplicateStationSubtitle(duplicate.station),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _mutedTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.duplicateStationOriginal(
                    duplicate.originalStation.displayName,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _mutedTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _duplicateStationSubtitle(RadioStation station) {
  final parts = <String>[
    if (station.displayLocation.isNotEmpty) station.displayLocation,
    if (station.bestStreamUrl.isNotEmpty) station.bestStreamUrl,
  ];
  return parts.join('  •  ');
}

class _CatalogLoadEventRow extends StatelessWidget {
  const _CatalogLoadEventRow({required this.event});

  final StationCatalogLoadEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (event.status) {
      StationCatalogEventStatus.success => const Color(0xFF2E7D32),
      StationCatalogEventStatus.failure => theme.colorScheme.error,
      StationCatalogEventStatus.loading => theme.colorScheme.primary,
      StationCatalogEventStatus.info => _mutedTextColor(context),
    };
    final icon = switch (event.status) {
      StationCatalogEventStatus.success => Icons.check_circle_outline_rounded,
      StationCatalogEventStatus.failure => Icons.error_outline_rounded,
      StationCatalogEventStatus.loading => Icons.downloading_rounded,
      StationCatalogEventStatus.info => Icons.info_outline_rounded,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatCatalogLogTime(event.timestamp)}  '
                  '${event.source.label}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.message,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                if (event.stationCount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.playableStationCount(event.stationCount!),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCatalogLogTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(value.hour)}:${twoDigits(value.minute)}:'
      '${twoDigits(value.second)}';
}
