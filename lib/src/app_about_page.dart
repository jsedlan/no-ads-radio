part of 'app.dart';

class _AboutPage extends StatelessWidget {
  const _AboutPage();

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
                    tooltip: context.l10n.back,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.about,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Image.asset(
                                'assets/images/logo.png',
                                semanticLabel: context.l10n.appTitle,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              context.l10n.appVersion(appVersion),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _mutedTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.l10n.aboutDescription,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AboutInfoTile(
                    icon: Icons.block_rounded,
                    title: context.l10n.aboutNoAdsTitle,
                    description: context.l10n.aboutNoAdsDescription,
                  ),
                  const SizedBox(height: 12),
                  _AboutInfoTile(
                    icon: Icons.public_rounded,
                    title: context.l10n.aboutStationCatalogTitle,
                    description: context.l10n.aboutStationCatalogDescription,
                  ),
                  const SizedBox(height: 12),
                  _AboutInfoTile(
                    icon: Icons.privacy_tip_outlined,
                    title: context.l10n.aboutPrivacyTitle,
                    description: context.l10n.aboutPrivacyDescription,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutInfoTile extends StatelessWidget {
  const _AboutInfoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _mutedTextColor(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
