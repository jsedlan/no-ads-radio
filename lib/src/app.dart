import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:no_ads_radio/l10n/app_localizations.dart';

import 'audio/audio_engine.dart';
import 'controllers/radio_app_controller.dart';
import 'models/favorite_category.dart';
import 'models/radio_station.dart';
import 'services/android_settings_launcher.dart';
import 'services/cast_service.dart';
import 'services/settings_store.dart';

part 'app_categories_page.dart';
part 'app_countries_page.dart';
part 'app_home.dart';
part 'app_about_page.dart';
part 'app_manual_stations_page.dart';
part 'app_player.dart';
part 'app_settings_pages.dart';
part 'app_version.dart';
part 'app_station_tag_translations.dart';
part 'app_setup.dart';
part 'app_station_widgets.dart';

class NoAdsRadioApp extends StatelessWidget {
  const NoAdsRadioApp({super.key, required this.controller});

  final RadioAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          locale: _appLocale(controller.languagePreference),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: _themeMode(controller.themePreference),
          theme: _buildAppTheme(Brightness.light),
          darkTheme: _buildAppTheme(Brightness.dark),
          home: RadioHomePage(controller: controller),
        );
      },
    );
  }
}

Locale? _appLocale(AppLanguagePreference preference) {
  return switch (preference) {
    AppLanguagePreference.system => null,
    AppLanguagePreference.english => const Locale('en'),
    AppLanguagePreference.serbianCyrillic => const Locale('sr'),
    AppLanguagePreference.serbianLatin => const Locale.fromSubtags(
      languageCode: 'sr',
      scriptCode: 'Latn',
    ),
  };
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

ThemeMode _themeMode(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

ThemeData _buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseTheme = ThemeData(brightness: brightness);
  final textTheme = GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme);
  final onSurface = isDark ? Colors.white : const Color(0xFF17202B);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: brightness,
    ),
    textTheme: textTheme.apply(bodyColor: onSurface, displayColor: onSurface),
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0D1117)
        : const Color(0xFFF6F1E8),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF111A24) : const Color(0xFFFFFBF4),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF162231) : const Color(0xFFFFFBF4),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        );
      }),
    ),
  );
}

Color _mutedTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);
}

Color _disabledTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
}

List<Color> _shellGradientColors(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const <Color>[Color(0xFF0D1117), Color(0xFF111827), Color(0xFF1A1025)]
      : const <Color>[Color(0xFFF6F1E8), Color(0xFFFFF7E8), Color(0xFFEAF1F5)];
}
