part of 'app.dart';

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final station = controller.currentStation;
    final playback = controller.playback;
    final canOpenNowPlaying =
        station != null && (playback.isPlaying || playback.isPaused);

    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFFFFBF4),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: canOpenNowPlaying
              ? () => _openNowPlayingScreen(context, controller)
              : null,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
              child: Row(
                children: [
                  if (station != null && controller.showStationIcon) ...[
                    _StationArtwork(
                      station: station,
                      size: 36,
                      borderRadius: 12,
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
                  ..._playerBarActions(
                    context,
                    playback,
                    hasStation: station != null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _playerBarActions(
    BuildContext context,
    PlaybackSnapshot playback, {
    required bool hasStation,
  }) {
    return <Widget>[
      if (controller.casting.isAvailable) _CastButton(controller: controller),
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

class _NowPlayingScreen extends StatelessWidget {
  const _NowPlayingScreen({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final station = controller.currentStation;
        final playback = controller.playback;

        return _Shell(
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(context.l10n.nowPlaying),
                leading: IconButton(
                  tooltip: context.l10n.back,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                actions: [
                  if (controller.casting.isAvailable)
                    _CastButton(controller: controller),
                ],
              ),
              body: station == null
                  ? Center(child: Text(context.l10n.nothingPlaying))
                  : _NowPlayingBody(
                      controller: controller,
                      station: station,
                      playback: playback,
                    ),
            ),
          ),
        );
      },
    );
  }
}

void _openNowPlayingScreen(
  BuildContext context,
  RadioAppController controller,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => _NowPlayingScreen(controller: controller),
    ),
  );
}

class _CastButton extends StatelessWidget {
  const _CastButton({required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    final casting = controller.casting;
    return IconButton(
      tooltip: casting.isConnected && casting.deviceName != null
          ? context.l10n.castingTo(casting.deviceName!)
          : context.l10n.cast,
      visualDensity: VisualDensity.compact,
      onPressed: () => _showCastDevices(context, controller),
      icon: Icon(
        casting.isConnected ? Icons.cast_connected_rounded : Icons.cast_rounded,
        color: casting.isConnected
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
    );
  }
}

Future<void> _showCastDevices(
  BuildContext context,
  RadioAppController controller,
) async {
  await controller.startCastDiscovery();
  if (!context.mounted) {
    return;
  }
  try {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _CastDeviceSheet(controller: controller),
    );
  } finally {
    await controller.stopCastDiscovery();
  }
}

class _CastDeviceSheet extends StatefulWidget {
  const _CastDeviceSheet({required this.controller});

  final RadioAppController controller;

  @override
  State<_CastDeviceSheet> createState() => _CastDeviceSheetState();
}

class _CastDeviceSheetState extends State<_CastDeviceSheet> {
  static const Duration _searchTimeout = Duration(seconds: 8);
  Timer? _searchTimer;
  bool _searchTimedOut = false;

  RadioAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _startSearchTimer();
  }

  void _startSearchTimer() {
    _searchTimer?.cancel();
    _searchTimedOut = false;
    _searchTimer = Timer(_searchTimeout, () {
      if (mounted && controller.casting.devices.isEmpty) {
        setState(() => _searchTimedOut = true);
      }
    });
  }

  Future<void> _searchAgain() async {
    setState(() => _searchTimedOut = false);
    await controller.stopCastDiscovery();
    await controller.startCastDiscovery();
    _startSearchTimer();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final casting = controller.casting;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.castDevices,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (casting.isConnected)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cast_connected_rounded),
                    title: Text(
                      context.l10n.castingTo(
                        casting.deviceName ?? context.l10n.unknown,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        await controller.disconnectFromCast();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(context.l10n.disconnect),
                    ),
                  )
                else if (casting.connectionStatus ==
                    CastConnectionStatus.connecting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (casting.devices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        if (!_searchTimedOut) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.searchingCastDevices,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.noCastDevices,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _mutedTextColor(context)),
                        ),
                        if (_searchTimedOut && Platform.isIOS) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.iosCastPermissionHelp,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _mutedTextColor(context)),
                          ),
                        ],
                        if (_searchTimedOut) ...[
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _searchAgain,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(context.l10n.searchAgain),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ...casting.devices.map(
                    (device) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cast_rounded),
                      title: Text(device.name),
                      subtitle: device.modelName == null
                          ? null
                          : Text(device.modelName!),
                      onTap: () =>
                          _connectToCastDevice(context, controller, device),
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

Future<void> _connectToCastDevice(
  BuildContext context,
  RadioAppController controller,
  CastDevice device,
) async {
  try {
    await controller.connectToCastDevice(device);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.castConnectionFailed)),
      );
    }
  }
}

class _NowPlayingBody extends StatelessWidget {
  const _NowPlayingBody({
    required this.controller,
    required this.station,
    required this.playback,
  });

  final RadioAppController controller;
  final RadioStation station;
  final PlaybackSnapshot playback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _playerBarStatus(
      playback: playback,
      playbackStalled: controller.playbackStalled,
      playbackStallReason: controller.playbackStallReason,
      stationName: station.displayName,
      l10n: context.l10n,
    );
    final hasInternetOutage =
        controller.playbackStalled &&
        controller.playbackStallReason == PlaybackStallReason.internetOutage;
    final title = _cleanNowPlayingMetadata(
      playback.nowPlaying?.displayTitle,
      stationName: station.displayName,
    );
    final streamStation = _cleanNowPlayingMetadata(
      playback.nowPlaying?.stationName,
      stationName: station.displayName,
    );
    final genre = _cleanNowPlayingMetadata(
      playback.nowPlaying?.genre,
      stationName: station.displayName,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Center(
          child: _StationArtwork(station: station, size: 168, borderRadius: 28),
        ),
        const SizedBox(height: 24),
        Text(
          station.displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (status != null) ...[
          const SizedBox(height: 8),
          Text(
            status,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: playback.hasError || hasInternetOutage
                  ? theme.colorScheme.error
                  : _mutedTextColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LargePlaybackButton(
              tooltip: context.l10n.previousFavorite,
              icon: Icons.skip_previous_rounded,
              onPressed: controller.canPlayAdjacentFavorite
                  ? controller.playPreviousFavorite
                  : null,
            ),
            const SizedBox(width: 18),
            _LargePlaybackButton(
              tooltip: playback.isPlaying
                  ? context.l10n.pause
                  : context.l10n.play,
              icon: playback.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              prominent: true,
              onPressed: playback.isLoading
                  ? null
                  : playback.isPlaying
                  ? controller.pausePlayback
                  : controller.resumePlayback,
            ),
            const SizedBox(width: 18),
            _LargePlaybackButton(
              tooltip: context.l10n.nextFavorite,
              icon: Icons.skip_next_rounded,
              onPressed: controller.canPlayAdjacentFavorite
                  ? controller.playNextFavorite
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 28),
        _NowPlayingInfoCard(
          children: [
            if (title != null)
              _NowPlayingInfoRow(label: context.l10n.track, value: title),
            if (streamStation != null)
              _NowPlayingInfoRow(
                label: context.l10n.stream,
                value: streamStation,
              ),
            if (genre != null)
              _NowPlayingInfoRow(label: context.l10n.genre, value: genre),
            if (station.displayLocation.isNotEmpty)
              _NowPlayingInfoRow(
                label: context.l10n.location,
                value: station.displayLocation,
              ),
            if (station.displayLanguage.isNotEmpty)
              _NowPlayingInfoRow(
                label: context.l10n.language,
                value: station.displayLanguage,
              ),
            if (station.displayTags.isNotEmpty)
              _NowPlayingInfoRow(
                label: context.l10n.tags,
                value: station.displayTags,
              ),
            if (station.codec.trim().isNotEmpty)
              _NowPlayingInfoRow(
                label: context.l10n.codec,
                value: station.codec.trim(),
              ),
            if (station.bitrate > 0)
              _NowPlayingInfoRow(
                label: context.l10n.bitrate,
                value: '${station.bitrate} kbps',
              ),
            if (controller.sleepTimerRemaining > Duration.zero)
              _NowPlayingInfoRow(
                label: context.l10n.sleepTimer,
                value: _formatSleepTimerRemaining(
                  controller.sleepTimerRemaining,
                  context.l10n,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LargePlaybackButton extends StatelessWidget {
  const _LargePlaybackButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.prominent = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      fixedSize: Size.square(prominent ? 76 : 60),
    );
    final iconWidget = Icon(icon, size: prominent ? 40 : 34);

    return prominent
        ? IconButton.filledTonal(
            tooltip: tooltip,
            style: style,
            onPressed: onPressed,
            icon: iconWidget,
          )
        : IconButton.filledTonal(
            tooltip: tooltip,
            style: style,
            onPressed: onPressed,
            icon: iconWidget,
          );
  }
}

class _NowPlayingInfoCard extends StatelessWidget {
  const _NowPlayingInfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _NowPlayingInfoRow extends StatelessWidget {
  const _NowPlayingInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: _mutedTextColor(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
          ? context.l10n.sleepTimerWithRemaining(
              _formatSleepTimerRemaining(remaining, context.l10n),
            )
          : context.l10n.sleepTimer,
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
        PopupMenuItem<int>(
          value: 0,
          enabled: active,
          child: Text(context.l10n.off),
        ),
        const PopupMenuDivider(),
        ...RadioAppController.sleepTimerOptions.map(
          (duration) => PopupMenuItem<int>(
            value: duration.inMinutes,
            child: Text(_formatSleepTimerOption(duration, context.l10n)),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<int>(
          value: _customSleepTimerValue,
          child: Text(context.l10n.custom),
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
        _errorText = context.l10n.enterPositiveNumber;
      });
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.customSleepTimer),
      content: TextField(
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: context.l10n.minutes,
          hintText: '90',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.start)),
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
      l10n: context.l10n,
    );
    final hasInternetOutage =
        playbackStalled &&
        playbackStallReason == PlaybackStallReason.internetOutage;
    final metadata = playback.isPlaying
        ? _cleanNowPlayingMetadata(
            playback.nowPlaying?.stationName,
            stationName: station.displayName,
          )
        : null;
    final displayStatus = hasInternetOutage
        ? context.l10n.offline
        : status ?? station.displayName;
    final parts = <String>[
      displayStatus,
      if (metadata != null && metadata.isNotEmpty) metadata,
      if (sleepTimerRemaining > Duration.zero)
        context.l10n.sleepTimerWithRemaining(
          _formatSleepTimerRemaining(sleepTimerRemaining, context.l10n),
        ),
    ];
    final message = parts.join('  •  ');

    return _ChyronText(
      key: ValueKey(message),
      text: message,
      style: textStyle.copyWith(
        color: playback.hasError || hasInternetOutage
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
  required AppLocalizations l10n,
}) {
  if (playbackStalled) {
    return playbackStallReason == PlaybackStallReason.internetOutage
        ? l10n.internetConnectionLost
        : playbackStallReason == PlaybackStallReason.streamFailure
        ? l10n.streamStoppedResponding
        : l10n.playbackStalled;
  }
  if (playback.hasError) {
    return playback.message ?? l10n.playbackFailed;
  }
  if (playback.isLoading) {
    return l10n.bufferingStream;
  }
  if (playback.isPlaying) {
    return _cleanNowPlayingMetadata(
      playback.nowPlaying?.displayTitle,
      stationName: stationName,
    );
  }
  return l10n.paused;
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
  const _ChyronText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_ChyronText> createState() => _ChyronTextState();
}

class _ChyronTextState extends State<_ChyronText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _cycleKey = GlobalKey();
  bool _measureScheduled = false;
  double? _cycleDistance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _ChyronText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _cycleDistance = null;
      _controller.value = 0;
      _scheduleCycleMeasure();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _scheduleCycleMeasure();
            final cycleDistance = _cycleDistance;

            if (cycleDistance == null) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      softWrap: false,
                      style: widget.style,
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: _ChyronTextCycle(
                        key: _cycleKey,
                        text: widget.text,
                        style: widget.style,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (cycleDistance <= constraints.maxWidth) {
              _controller.stop();
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.text,
                  maxLines: 1,
                  softWrap: false,
                  style: widget.style,
                ),
              );
            }

            if (!_controller.isAnimating) {
              _controller.duration = Duration(
                milliseconds: (cycleDistance * 35).round().clamp(3500, 20000),
              );
              _controller.repeat();
            }

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return OverflowBox(
                  minWidth: 0,
                  maxWidth: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(-cycleDistance * _controller.value, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ChyronTextCycle(
                          text: widget.text,
                          style: widget.style,
                        ),
                        _ChyronTextCycle(
                          text: widget.text,
                          style: widget.style,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _scheduleCycleMeasure() {
    if (_measureScheduled) {
      return;
    }
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted) {
        return;
      }
      final renderBox =
          _cycleKey.currentContext?.findRenderObject() as RenderBox?;
      final measuredWidth = renderBox?.size.width;
      if (measuredWidth == null || measuredWidth <= 0) {
        return;
      }
      if (_cycleDistance == measuredWidth) {
        return;
      }
      setState(() {
        _cycleDistance = measuredWidth;
        _controller.stop();
        _controller.value = 0;
      });
    });
  }
}

class _ChyronTextCycle extends StatelessWidget {
  const _ChyronTextCycle({super.key, required this.text, required this.style});

  static const String _separator = '  •  ';

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, maxLines: 1, softWrap: false, style: style),
        Text(_separator, maxLines: 1, softWrap: false, style: style),
      ],
    );
  }
}

String _formatSleepTimerOption(
  Duration duration,
  AppLocalizations localizations,
) {
  final minutes = duration.inMinutes;
  if (minutes < 60) {
    return localizations.durationMinutes(minutes);
  }
  final hours = duration.inHours;
  final remainingMinutes = minutes.remainder(60);
  if (remainingMinutes == 0) {
    return localizations.durationHours(hours);
  }
  return localizations.durationHoursMinutes(hours, remainingMinutes);
}

String _formatSleepTimerRemaining(
  Duration duration,
  AppLocalizations localizations,
) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds <= 0) {
    return localizations.lessThanOneMinute;
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
