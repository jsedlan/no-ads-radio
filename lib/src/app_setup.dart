part of 'app.dart';

class _CountrySetupPage extends StatefulWidget {
  const _CountrySetupPage({required this.controller});

  final RadioAppController controller;

  @override
  State<_CountrySetupPage> createState() => _CountrySetupPageState();
}

class _CountrySetupPageState extends State<_CountrySetupPage> {
  late String _selectedCountryCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final suggestedCode = widget.controller.suggestedCountryCode;
    _selectedCountryCode =
        _countryOptions.any((option) => option.code == suggestedCode)
        ? suggestedCode
        : '';
  }

  Future<void> _chooseCountry() async {
    final selectedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => _AddCountryPage(
          selectedCountryCodes: _selectedCountryCode.isEmpty
              ? const <String>[]
              : <String>[_selectedCountryCode],
        ),
      ),
    );
    if (selectedCode == null || !mounted) {
      return;
    }
    setState(() {
      _selectedCountryCode = selectedCode;
    });
  }

  Future<void> _continue() async {
    if (_selectedCountryCode.isEmpty || _isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    await widget.controller.completeCountrySetup(_selectedCountryCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedOption = _selectedCountryCode.isEmpty
        ? null
        : _countryOptionsForCodes(<String>[_selectedCountryCode]).first;

    return _Shell(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.l10n.chooseCountryTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.l10n.chooseCountryDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _mutedTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.moreCountriesLater,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _mutedTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        onTap: _chooseCountry,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        title: Text(
                          selectedOption?.name ?? context.l10n.selectCountry,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: selectedOption == null
                            ? null
                            : Text(selectedOption.code),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _selectedCountryCode.isEmpty || _isSaving
                            ? null
                            : _continue,
                        child: Text(
                          _isSaving
                              ? context.l10n.saving
                              : context.l10n.continueLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
