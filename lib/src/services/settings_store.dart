import 'package:shared_preferences/shared_preferences.dart';

import '../models/station_category.dart';
import '../models/radio_station.dart';

enum AppThemePreference {
  light,
  dark;

  static AppThemePreference fromStorage(String? value) {
    return switch (value) {
      'light' => AppThemePreference.light,
      _ => AppThemePreference.dark,
    };
  }
}

enum AppLanguagePreference {
  system,
  english,
  serbianCyrillic,
  serbianLatin;

  static AppLanguagePreference fromStorage(String? value) {
    return switch (value) {
      'english' => AppLanguagePreference.english,
      'serbianCyrillic' => AppLanguagePreference.serbianCyrillic,
      'serbianLatin' => AppLanguagePreference.serbianLatin,
      _ => AppLanguagePreference.system,
    };
  }
}

class AppSettings {
  const AppSettings({
    this.themePreference = AppThemePreference.dark,
    this.languagePreference = AppLanguagePreference.system,
    this.showStationIcon = true,
    this.autoPlayNextCategoryStation = true,
    this.countryCodes = const <String>[],
    this.hasCompletedCountrySetup = true,
    this.manualStations = const <RadioStation>[],
    this.recentlyPlayedStations = const <RadioStation>[],
    this.stationCategories = const <StationCategory>[
      StationCategory(id: 'category-0-saved', name: 'Saved'),
    ],
    this.activeStationCategoryId = '',
  });

  final AppThemePreference themePreference;
  final AppLanguagePreference languagePreference;
  final bool showStationIcon;
  final bool autoPlayNextCategoryStation;
  final List<String> countryCodes;
  final bool hasCompletedCountrySetup;
  final List<RadioStation> manualStations;
  final List<RadioStation> recentlyPlayedStations;
  final List<StationCategory> stationCategories;
  final String activeStationCategoryId;

  AppSettings copyWith({
    AppThemePreference? themePreference,
    AppLanguagePreference? languagePreference,
    bool? showStationIcon,
    bool? autoPlayNextCategoryStation,
    List<String>? countryCodes,
    bool? hasCompletedCountrySetup,
    List<RadioStation>? manualStations,
    List<RadioStation>? recentlyPlayedStations,
    List<StationCategory>? stationCategories,
    String? activeStationCategoryId,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      languagePreference: languagePreference ?? this.languagePreference,
      showStationIcon: showStationIcon ?? this.showStationIcon,
      autoPlayNextCategoryStation:
          autoPlayNextCategoryStation ?? this.autoPlayNextCategoryStation,
      countryCodes: countryCodes ?? this.countryCodes,
      hasCompletedCountrySetup:
          hasCompletedCountrySetup ?? this.hasCompletedCountrySetup,
      manualStations: manualStations ?? this.manualStations,
      recentlyPlayedStations:
          recentlyPlayedStations ?? this.recentlyPlayedStations,
      stationCategories: stationCategories ?? this.stationCategories,
      activeStationCategoryId:
          activeStationCategoryId ?? this.activeStationCategoryId,
    );
  }
}

abstract class SettingsStore {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._preferences);

  static const String _showStationIconKey = 'show_station_icon';
  static const String _themePreferenceKey = 'theme_preference';
  static const String _languagePreferenceKey = 'language_preference';
  static const String _autoPlayNextCategoryStationKey =
      'auto_play_next_category_station';
  static const String _countryCodesKey = 'country_codes';
  static const String _hasCompletedCountrySetupKey =
      'has_completed_country_setup';
  static const String _manualStationsKey = 'manual_stations';
  static const String _recentlyPlayedStationsKey = 'recently_played_stations';
  static const String _stationCategoriesKey = 'station_categories';
  static const String _activeStationCategoryIdKey =
      'active_station_category_id';

  final SharedPreferences _preferences;

  @override
  Future<AppSettings> loadSettings() async {
    final stationCategories = _loadStationCategories();
    final countryCodes =
        _preferences.getStringList(_countryCodesKey) ?? const <String>[];
    return AppSettings(
      themePreference: AppThemePreference.fromStorage(
        _preferences.getString(_themePreferenceKey),
      ),
      languagePreference: AppLanguagePreference.fromStorage(
        _preferences.getString(_languagePreferenceKey),
      ),
      showStationIcon: _preferences.getBool(_showStationIconKey) ?? true,
      autoPlayNextCategoryStation:
          _preferences.getBool(_autoPlayNextCategoryStationKey) ?? true,
      countryCodes: List<String>.unmodifiable(countryCodes),
      hasCompletedCountrySetup:
          _preferences.getBool(_hasCompletedCountrySetupKey) ?? false,
      manualStations: List<RadioStation>.unmodifiable(
        (_preferences.getStringList(_manualStationsKey) ?? const <String>[])
            .map(RadioStation.fromStorage),
      ),
      recentlyPlayedStations: List<RadioStation>.unmodifiable(
        (_preferences.getStringList(_recentlyPlayedStationsKey) ??
                const <String>[])
            .map(RadioStation.fromStorage),
      ),
      stationCategories: stationCategories,
      activeStationCategoryId:
          _preferences.getString(_activeStationCategoryIdKey) ?? '',
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _preferences.setString(
      _themePreferenceKey,
      settings.themePreference.name,
    );
    await _preferences.setString(
      _languagePreferenceKey,
      settings.languagePreference.name,
    );
    await _preferences.setBool(_showStationIconKey, settings.showStationIcon);
    await _preferences.setBool(
      _autoPlayNextCategoryStationKey,
      settings.autoPlayNextCategoryStation,
    );
    await _preferences.setStringList(_countryCodesKey, settings.countryCodes);
    await _preferences.setBool(
      _hasCompletedCountrySetupKey,
      settings.hasCompletedCountrySetup,
    );
    await _preferences.setStringList(
      _manualStationsKey,
      settings.manualStations.map((station) => station.toStorage()).toList(),
    );
    await _preferences.setStringList(
      _recentlyPlayedStationsKey,
      settings.recentlyPlayedStations
          .map((station) => station.toStorage())
          .toList(),
    );
    await _preferences.setStringList(
      _stationCategoriesKey,
      settings.stationCategories
          .map((category) => category.toStorage())
          .toList(growable: false),
    );
    await _preferences.setString(
      _activeStationCategoryIdKey,
      settings.activeStationCategoryId,
    );
  }

  List<StationCategory> _loadStationCategories() {
    final rawCategories =
        _preferences.getStringList(_stationCategoriesKey) ??
        const <String>['Saved'];
    final categories = <StationCategory>[];

    for (var index = 0; index < rawCategories.length; index += 1) {
      final category = StationCategory.fromStorage(
        rawCategories[index],
        index: index,
      );
      if (category.name.trim().isNotEmpty) {
        categories.add(category);
      }
    }

    if (categories.isEmpty) {
      return const <StationCategory>[
        StationCategory(id: 'category-0-saved', name: 'Saved'),
      ];
    }

    return List<StationCategory>.unmodifiable(categories);
  }
}
