part of 'app.dart';

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
                          context.l10n.manualStations,
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
                        label: Text(context.l10n.add),
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
                                context.l10n.deleteAll,
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
                              context.l10n.noManualStations,
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
                                    tooltip: context.l10n.deleteStation,
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
          title: Text(context.l10n.deleteAllManualStationsTitle),
          content: Text(context.l10n.deleteAllManualStationsDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.deleteAll),
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
                      context.l10n.addStation,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(context.l10n.done),
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
                                decoration: InputDecoration(
                                  labelText: context.l10n.stationName,
                                  hintText: context.l10n.stationNameHint,
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return context.l10n.enterStationName;
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
                                decoration: InputDecoration(
                                  labelText: context.l10n.streamUrl,
                                  hintText: 'https://example.com/stream',
                                ),
                                validator: (value) {
                                  final uri = Uri.tryParse(
                                    (value ?? '').trim(),
                                  );
                                  if (uri == null ||
                                      uri.scheme.trim().isEmpty ||
                                      uri.host.trim().isEmpty) {
                                    return context.l10n.enterValidStreamUrl;
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
