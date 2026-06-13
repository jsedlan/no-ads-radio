import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_category.dart';
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
  serbianLatin;

  static AppLanguagePreference fromStorage(String? value) {
    return switch (value) {
      'english' => AppLanguagePreference.english,
      'serbianLatin' => AppLanguagePreference.serbianLatin,
      _ => AppLanguagePreference.system,
    };
  }
}

class AppSettings {
  const AppSettings({
    this.themePreference = AppThemePreference.dark,
    this.languagePreference = AppLanguagePreference.system,
    this.showStationIcon = false,
    this.circleThroughFavorites = true,
    this.countryCodes = const <String>[],
    this.hasCompletedCountrySetup = true,
    this.manualStations = const <RadioStation>[],
    this.recentlyPlayedStations = const <RadioStation>[],
    this.favoriteCategories = const <FavoriteCategory>[
      FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
    ],
  });

  final AppThemePreference themePreference;
  final AppLanguagePreference languagePreference;
  final bool showStationIcon;
  final bool circleThroughFavorites;
  final List<String> countryCodes;
  final bool hasCompletedCountrySetup;
  final List<RadioStation> manualStations;
  final List<RadioStation> recentlyPlayedStations;
  final List<FavoriteCategory> favoriteCategories;

  AppSettings copyWith({
    AppThemePreference? themePreference,
    AppLanguagePreference? languagePreference,
    bool? showStationIcon,
    bool? circleThroughFavorites,
    List<String>? countryCodes,
    bool? hasCompletedCountrySetup,
    List<RadioStation>? manualStations,
    List<RadioStation>? recentlyPlayedStations,
    List<FavoriteCategory>? favoriteCategories,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      languagePreference: languagePreference ?? this.languagePreference,
      showStationIcon: showStationIcon ?? this.showStationIcon,
      circleThroughFavorites:
          circleThroughFavorites ?? this.circleThroughFavorites,
      countryCodes: countryCodes ?? this.countryCodes,
      hasCompletedCountrySetup:
          hasCompletedCountrySetup ?? this.hasCompletedCountrySetup,
      manualStations: manualStations ?? this.manualStations,
      recentlyPlayedStations:
          recentlyPlayedStations ?? this.recentlyPlayedStations,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
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
  static const String _circleThroughFavoritesKey = 'circle_through_favorites';
  static const String _countryCodesKey = 'country_codes';
  static const String _hasCompletedCountrySetupKey =
      'has_completed_country_setup';
  static const String _manualStationsKey = 'manual_stations';
  static const String _recentlyPlayedStationsKey = 'recently_played_stations';
  static const String _favoriteCategoriesKey = 'favorite_categories';

  final SharedPreferences _preferences;

  @override
  Future<AppSettings> loadSettings() async {
    final favoriteCategories = _loadFavoriteCategories();
    final countryCodes =
        _preferences.getStringList(_countryCodesKey) ?? const <String>[];
    return AppSettings(
      themePreference: AppThemePreference.fromStorage(
        _preferences.getString(_themePreferenceKey),
      ),
      languagePreference: AppLanguagePreference.fromStorage(
        _preferences.getString(_languagePreferenceKey),
      ),
      showStationIcon: _preferences.getBool(_showStationIconKey) ?? false,
      circleThroughFavorites:
          _preferences.getBool(_circleThroughFavoritesKey) ?? true,
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
      favoriteCategories: favoriteCategories,
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
      _circleThroughFavoritesKey,
      settings.circleThroughFavorites,
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
      _favoriteCategoriesKey,
      settings.favoriteCategories
          .map((category) => category.toStorage())
          .toList(growable: false),
    );
  }

  List<FavoriteCategory> _loadFavoriteCategories() {
    final rawCategories =
        _preferences.getStringList(_favoriteCategoriesKey) ??
        const <String>['Favorites'];
    final categories = <FavoriteCategory>[];

    for (var index = 0; index < rawCategories.length; index += 1) {
      final category = FavoriteCategory.fromStorage(
        rawCategories[index],
        index: index,
      );
      if (category.name.trim().isNotEmpty) {
        categories.add(category);
      }
    }

    if (categories.isEmpty) {
      return const <FavoriteCategory>[
        FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
      ];
    }

    return List<FavoriteCategory>.unmodifiable(categories);
  }
}
